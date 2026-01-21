import { Server as SftpServer } from 'sftp-server';
import { PrismaClient } from '@prisma/client';
import path from 'path';
import fs from 'fs-extra';
import crypto from 'crypto-js';

const prisma = new PrismaClient();

export class SFTPServerService {
  private sftpServer: SftpServer;
  private port: number;

  constructor(port: number = 2022) {
    this.port = port;
    this.sftpServer = new SftpServer({
      port: this.port,
      hostKeys: [this.generateHostKey()],
      auth: this.authenticate.bind(this),
      filesystem: this.createFilesystem.bind(this)
    });
  }

  private generateHostKey(): Buffer {
    // Generate a new RSA key pair for SFTP server
    // In production, this should be stored securely
    const { publicKey } = crypto.generateKeyPairSync('rsa', {
      modulusLength: 2048,
      publicKeyEncoding: {
        type: 'spki',
        format: 'pem'
      },
      privateKeyEncoding: {
        type: 'pkcs8',
        format: 'pem'
      }
    });

    return Buffer.from(publicKey);
  }

  private async authenticate(username: string, password: string): Promise<boolean> {
    try {
      const user = await prisma.user.findFirst({
        where: {
          OR: [
            { username },
            { email: username }
          ]
        }
      });

      if (!user || !user.isActive) {
        return false;
      }

      // Verify password
      const bcrypt = require('bcryptjs');
      return await bcrypt.compare(password, user.password);
    } catch (error) {
      console.error('SFTP authentication error:', error);
      return false;
    }
  }

  private createFilesystem(username: string) {
    return {
      readdir: async (path: string) => {
        try {
          const user = await prisma.user.findFirst({
            where: {
              OR: [
                { username },
                { email: username }
              ]
            },
            include: {
              servers: true
            }
          });

          if (!user) {
            throw new Error('User not found');
          }

          // If path is root, list user's servers
          if (path === '/' || path === '.') {
            const serverDirs = user.servers.map(server => ({
              filename: server.name,
              longname: `drwxr-xr-x 2 ${username} ${username} 4096 ${new Date(server.createdAt).toISOString().split('T')[0]} ${server.name}`,
              attrs: {
                mode: 0o755,
                uid: 1000,
                gid: 1000,
                size: 4096,
                atime: server.createdAt.getTime() / 1000,
                mtime: server.lastStarted?.getTime() / 1000 || server.createdAt.getTime() / 1000
              }
            }));

            return serverDirs;
          }

          // Parse server path
          const pathParts = path.split('/').filter(p => p);
          if (pathParts.length === 0) {
            throw new Error('Invalid path');
          }

          const serverName = pathParts[0];
          const server = user.servers.find(s => s.name === serverName);

          if (!server) {
            throw new Error('Server not found');
          }

          // Build server directory path
          const serverPath = path.join(process.cwd(), 'servers', server.id);
          const relativePath = pathParts.slice(1).join('/') || '.';
          const fullPath = path.join(serverPath, relativePath);

          // Security check - prevent directory traversal
          const resolvedPath = path.resolve(fullPath);
          const resolvedServerPath = path.resolve(serverPath);

          if (!resolvedPath.startsWith(resolvedServerPath)) {
            throw new Error('Access denied');
          }

          const items = await fs.readdir(fullPath);
          const fileList = [];

          for (const item of items) {
            const itemPath = path.join(fullPath, item);
            const stats = await fs.stat(itemPath);

            fileList.push({
              filename: item,
              longname: `${stats.isDirectory() ? 'd' : '-'}rwxr-xr-x 1 ${username} ${username} ${stats.size} ${new Date(stats.mtime).toISOString().split('T')[0]} ${item}`,
              attrs: {
                mode: stats.isDirectory() ? 0o755 : 0o644,
                uid: 1000,
                gid: 1000,
                size: stats.size,
                atime: stats.atime.getTime() / 1000,
                mtime: stats.mtime.getTime() / 1000
              }
            });
          }

          return fileList;
        } catch (error) {
          console.error('SFTP readdir error:', error);
          throw error;
        }
      },

      stat: async (path: string) => {
        try {
          const user = await this.getUserFromPath(path);
          const fullPath = await this.resolveServerPath(path, user);

          const stats = await fs.stat(fullPath);

          return {
            mode: stats.isDirectory() ? 0o755 : 0o644,
            uid: 1000,
            gid: 1000,
            size: stats.size,
            atime: stats.atime.getTime() / 1000,
            mtime: stats.mtime.getTime() / 1000
          };
        } catch (error) {
          console.error('SFTP stat error:', error);
          throw error;
        }
      },

      readFile: async (path: string, options: any) => {
        try {
          const user = await this.getUserFromPath(path);
          const fullPath = await this.resolveServerPath(path, user);

          // Security check
          await this.checkFileAccess(fullPath, user);

          const stream = fs.createReadStream(fullPath, options);
          return stream;
        } catch (error) {
          console.error('SFTP readFile error:', error);
          throw error;
        }
      },

      writeFile: async (path: string, data: Buffer | string) => {
        try {
          const user = await this.getUserFromPath(path);
          const fullPath = await this.resolveServerPath(path, user);

          // Security check
          await this.checkFileAccess(path.dirname(fullPath), user);

          // Only allow writing to certain file types for security
          const allowedExtensions = ['.txt', '.yml', '.yaml', '.json', '.properties', '.cfg', '.config'];
          const ext = path.extname(fullPath).toLowerCase();

          if (!allowedExtensions.includes(ext)) {
            throw new Error('File type not allowed for writing');
          }

          await fs.writeFile(fullPath, data);
        } catch (error) {
          console.error('SFTP writeFile error:', error);
          throw error;
        }
      },

      mkdir: async (path: string) => {
        try {
          const user = await this.getUserFromPath(path);
          const fullPath = await this.resolveServerPath(path, user);

          // Only allow creating directories in plugins/mods folders
          const relativePath = path.relative(await this.getServerBasePath(path, user), fullPath);
          if (!relativePath.startsWith('plugins') && !relativePath.startsWith('mods')) {
            throw new Error('Directory creation not allowed in this location');
          }

          await fs.ensureDir(fullPath);
        } catch (error) {
          console.error('SFTP mkdir error:', error);
          throw error;
        }
      },

      rmdir: async (path: string) => {
        try {
          const user = await this.getUserFromPath(path);
          const fullPath = await this.resolveServerPath(path, user);

          // Only allow removing directories in plugins/mods folders
          const relativePath = path.relative(await this.getServerBasePath(path, user), fullPath);
          if (!relativePath.startsWith('plugins') && !relativePath.startsWith('mods')) {
            throw new Error('Directory removal not allowed in this location');
          }

          await fs.remove(fullPath);
        } catch (error) {
          console.error('SFTP rmdir error:', error);
          throw error;
        }
      },

      unlink: async (path: string) => {
        try {
          const user = await this.getUserFromPath(path);
          const fullPath = await this.resolveServerPath(path, user);

          // Security check
          await this.checkFileAccess(path.dirname(fullPath), user);

          // Don't allow deleting critical files
          const fileName = path.basename(fullPath);
          const criticalFiles = ['server.jar', 'server.properties', 'bukkit.yml', 'spigot.yml'];

          if (criticalFiles.includes(fileName.toLowerCase())) {
            throw new Error('Cannot delete critical server files');
          }

          await fs.unlink(fullPath);
        } catch (error) {
          console.error('SFTP unlink error:', error);
          throw error;
        }
      }
    };
  }

  private async getUserFromPath(clientPath: string): Promise<any> {
    // Extract username from client path (this is a simplified implementation)
    // In a real implementation, this would come from the authenticated session
    const pathParts = clientPath.split('/').filter(p => p);
    if (pathParts.length === 0) {
      throw new Error('Invalid path');
    }

    // This is a placeholder - in real implementation, username would come from auth
    const username = 'current_user'; // This should come from the SFTP session

    const user = await prisma.user.findFirst({
      where: {
        OR: [
          { username },
          { email: username }
        ]
      },
      include: {
        servers: true
      }
    });

    if (!user) {
      throw new Error('User not found');
    }

    return user;
  }

  private async resolveServerPath(clientPath: string, user: any): Promise<string> {
    const pathParts = clientPath.split('/').filter(p => p);

    if (pathParts.length === 0) {
      throw new Error('Invalid path');
    }

    const serverName = pathParts[0];
    const server = user.servers.find((s: any) => s.name === serverName);

    if (!server) {
      throw new Error('Server not found');
    }

    const serverPath = path.join(process.cwd(), 'servers', server.id);
    const relativePath = pathParts.slice(1).join('/') || '.';

    return path.join(serverPath, relativePath);
  }

  private async getServerBasePath(clientPath: string, user: any): Promise<string> {
    const pathParts = clientPath.split('/').filter(p => p);

    if (pathParts.length === 0) {
      throw new Error('Invalid path');
    }

    const serverName = pathParts[0];
    const server = user.servers.find((s: any) => s.name === serverName);

    if (!server) {
      throw new Error('Server not found');
    }

    return path.join(process.cwd(), 'servers', server.id);
  }

  private async checkFileAccess(filePath: string, user: any): Promise<void> {
    // Check if user has access to this server
    const serverId = path.basename(path.dirname(filePath));
    const hasAccess = user.servers.some((s: any) => s.id === serverId);

    if (!hasAccess) {
      throw new Error('Access denied');
    }
  }

  public async start(): Promise<void> {
    try {
      await this.sftpServer.listen();
      console.log(`🔐 SFTP Server running on port ${this.port}`);
    } catch (error) {
      console.error('Failed to start SFTP server:', error);
      throw error;
    }
  }

  public async stop(): Promise<void> {
    try {
      await this.sftpServer.close();
      console.log('🔐 SFTP Server stopped');
    } catch (error) {
      console.error('Error stopping SFTP server:', error);
    }
  }
}