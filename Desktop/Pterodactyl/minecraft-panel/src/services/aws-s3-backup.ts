import AWS from 'aws-sdk';
import fs from 'fs-extra';
import path from 'path';
import { PrismaClient } from '@prisma/client';
import archiver from 'archiver';
import { pipeline } from 'stream/promises';

const prisma = new PrismaClient();

export class AWSS3BackupService {
  private s3: AWS.S3;
  private bucketName: string;

  constructor() {
    this.s3 = new AWS.S3({
      accessKeyId: process.env.AWS_ACCESS_KEY_ID,
      secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
      region: process.env.AWS_REGION || 'us-east-1'
    });

    this.bucketName = process.env.AWS_S3_BUCKET_NAME || 'minecraft-panel-backups';

    this.ensureBucket();
  }

  private async ensureBucket(): Promise<void> {
    try {
      await this.s3.createBucket({
        Bucket: this.bucketName,
        CreateBucketConfiguration: {
          LocationConstraint: process.env.AWS_REGION || 'us-east-1'
        }
      }).promise();
      console.log(`✅ S3 bucket '${this.bucketName}' created or already exists`);
    } catch (error: any) {
      if (error.code !== 'BucketAlreadyOwnedByYou') {
        console.error('❌ Error creating S3 bucket:', error);
      }
    }
  }

  public async createBackup(serverId: string, backupName?: string): Promise<any> {
    try {
      console.log(`📦 Creating S3 backup for server ${serverId}`);

      // Get server info
      const server = await prisma.server.findUnique({
        where: { id: serverId }
      });

      if (!server) {
        throw new Error('Server not found');
      }

      const serverPath = path.join(process.cwd(), 'servers', serverId);
      const backupNameFinal = backupName || `backup-${server.name}-${new Date().toISOString().replace(/[:.]/g, '-')}`;
      const localBackupPath = path.join(process.cwd(), 'temp', `${backupNameFinal}.zip`);

      // Ensure temp directory exists
      await fs.ensureDir(path.dirname(localBackupPath));

      // Create zip archive
      const output = fs.createWriteStream(localBackupPath);
      const archive = archiver('zip', { zlib: { level: 9 } });

      return new Promise(async (resolve, reject) => {
        output.on('close', async () => {
          try {
            // Upload to S3
            const s3Key = `backups/${serverId}/${backupNameFinal}.zip`;
            const fileStream = fs.createReadStream(localBackupPath);

            const uploadResult = await this.s3.upload({
              Bucket: this.bucketName,
              Key: s3Key,
              Body: fileStream,
              ContentType: 'application/zip',
              Metadata: {
                serverId,
                serverName: server.name,
                createdAt: new Date().toISOString()
              }
            }).promise();

            // Record backup in database
            const backup = await prisma.backup.create({
              data: {
                serverId,
                name: backupNameFinal,
                fileName: `${backupNameFinal}.zip`,
                size: archive.pointer(),
                checksum: await this.calculateChecksum(localBackupPath)
              }
            });

            // Clean up local file
            await fs.unlink(localBackupPath);

            console.log(`✅ Backup uploaded to S3: ${uploadResult.Location}`);
            resolve({
              success: true,
              backup,
              s3Location: uploadResult.Location
            });

          } catch (error) {
            reject(error);
          }
        });

        archive.on('error', reject);

        archive.pipe(output);
        archive.directory(serverPath, false);
        archive.finalize();
      });

    } catch (error) {
      console.error('❌ Backup creation failed:', error);
      throw error;
    }
  }

  public async restoreBackup(serverId: string, backupId: string): Promise<any> {
    try {
      console.log(`📦 Restoring S3 backup ${backupId} for server ${serverId}`);

      // Get backup info
      const backup = await prisma.backup.findFirst({
        where: {
          id: backupId,
          serverId
        }
      });

      if (!backup) {
        throw new Error('Backup not found');
      }

      // Get server info
      const server = await prisma.server.findUnique({
        where: { id: serverId }
      });

      if (!server) {
        throw new Error('Server not found');
      }

      const s3Key = `backups/${serverId}/${backup.fileName}`;
      const localBackupPath = path.join(process.cwd(), 'temp', backup.fileName);
      const serverPath = path.join(process.cwd(), 'servers', serverId);

      // Ensure temp directory exists
      await fs.ensureDir(path.dirname(localBackupPath));

      // Download from S3
      const downloadStream = this.s3.getObject({
        Bucket: this.bucketName,
        Key: s3Key
      }).createReadStream();

      const writeStream = fs.createWriteStream(localBackupPath);
      await pipeline(downloadStream, writeStream);

      // Verify checksum if available
      if (backup.checksum) {
        const calculatedChecksum = await this.calculateChecksum(localBackupPath);
        if (calculatedChecksum !== backup.checksum) {
          await fs.unlink(localBackupPath);
          throw new Error('Backup file checksum verification failed');
        }
      }

      // Stop server if running (this would call the daemon)
      console.log('Stopping server for restore...');
      // await this.stopServer(serverId);

      // Clear server directory
      await fs.emptyDir(serverPath);

      // Extract backup
      const unzipper = require('unzipper');
      await fs.createReadStream(localBackupPath)
        .pipe(unzipper.Extract({ path: serverPath }));

      // Clean up
      await fs.unlink(localBackupPath);

      console.log(`✅ Backup ${backupId} restored successfully`);
      return {
        success: true,
        message: 'Backup restored successfully'
      };

    } catch (error) {
      console.error('❌ Backup restoration failed:', error);
      throw error;
    }
  }

  public async listBackups(serverId: string): Promise<any[]> {
    try {
      const backups = await prisma.backup.findMany({
        where: { serverId },
        orderBy: { createdAt: 'desc' }
      });

      // Check if files exist in S3
      for (const backup of backups) {
        try {
          await this.s3.headObject({
            Bucket: this.bucketName,
            Key: `backups/${serverId}/${backup.fileName}`
          }).promise();
          (backup as any).exists = true;
        } catch (error) {
          (backup as any).exists = false;
        }
      }

      return backups;
    } catch (error) {
      console.error('Error listing backups:', error);
      throw error;
    }
  }

  public async deleteBackup(serverId: string, backupId: string): Promise<any> {
    try {
      // Get backup info
      const backup = await prisma.backup.findFirst({
        where: {
          id: backupId,
          serverId
        }
      });

      if (!backup) {
        throw new Error('Backup not found');
      }

      // Delete from S3
      const s3Key = `backups/${serverId}/${backup.fileName}`;
      await this.s3.deleteObject({
        Bucket: this.bucketName,
        Key: s3Key
      }).promise();

      // Delete from database
      await prisma.backup.delete({
        where: { id: backupId }
      });

      console.log(`🗑️ Backup ${backupId} deleted successfully`);
      return {
        success: true,
        message: 'Backup deleted successfully'
      };

    } catch (error) {
      console.error('Error deleting backup:', error);
      throw error;
    }
  }

  public async downloadBackup(serverId: string, backupId: string): Promise<any> {
    try {
      const backup = await prisma.backup.findFirst({
        where: {
          id: backupId,
          serverId
        }
      });

      if (!backup) {
        throw new Error('Backup not found');
      }

      const s3Key = `backups/${serverId}/${backup.fileName}`;

      // Generate signed URL for download
      const signedUrl = await this.s3.getSignedUrlPromise('getObject', {
        Bucket: this.bucketName,
        Key: s3Key,
        Expires: 3600 // 1 hour
      });

      return {
        success: true,
        downloadUrl: signedUrl,
        filename: backup.fileName
      };

    } catch (error) {
      console.error('Error generating download URL:', error);
      throw error;
    }
  }

  public async cleanupOldBackups(serverId: string, retentionDays: number = 30): Promise<any> {
    try {
      const cutoffDate = new Date();
      cutoffDate.setDate(cutoffDate.getDate() - retentionDays);

      const oldBackups = await prisma.backup.findMany({
        where: {
          serverId,
          createdAt: {
            lt: cutoffDate
          }
        }
      });

      let deletedCount = 0;

      for (const backup of oldBackups) {
        try {
          await this.deleteBackup(serverId, backup.id);
          deletedCount++;
        } catch (error) {
          console.warn(`Failed to delete old backup ${backup.id}:`, error);
        }
      }

      console.log(`🧹 Cleaned up ${deletedCount} old backups for server ${serverId}`);
      return {
        success: true,
        deletedCount
      };

    } catch (error) {
      console.error('Error cleaning up old backups:', error);
      throw error;
    }
  }

  public async getStorageUsage(): Promise<any> {
    try {
      // List all objects in bucket
      const objects = await this.s3.listObjectsV2({
        Bucket: this.bucketName
      }).promise();

      let totalSize = 0;
      let backupCount = 0;

      if (objects.Contents) {
        for (const obj of objects.Contents) {
          if (obj.Size) {
            totalSize += obj.Size;
          }
          if (obj.Key?.includes('backups/')) {
            backupCount++;
          }
        }
      }

      return {
        totalSize,
        totalSizeFormatted: this.formatBytes(totalSize),
        backupCount
      };

    } catch (error) {
      console.error('Error getting storage usage:', error);
      throw error;
    }
  }

  private async calculateChecksum(filePath: string): Promise<string> {
    const crypto = require('crypto');
    const fileBuffer = await fs.readFile(filePath);
    return crypto.createHash('sha256').update(fileBuffer).digest('hex');
  }

  private formatBytes(bytes: number): string {
    if (bytes === 0) return '0 Bytes';

    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));

    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
  }

  public async scheduleAutomaticBackups(): Promise<void> {
    // This would be called by a cron job scheduler
    const servers = await prisma.server.findMany({
      where: { status: 'RUNNING' }
    });

    for (const server of servers) {
      try {
        const backupName = `auto-backup-${new Date().toISOString().split('T')[0]}`;
        await this.createBackup(server.id, backupName);

        // Cleanup old backups
        await this.cleanupOldBackups(server.id);
      } catch (error) {
        console.error(`Failed to create automatic backup for server ${server.id}:`, error);
      }
    }
  }
}