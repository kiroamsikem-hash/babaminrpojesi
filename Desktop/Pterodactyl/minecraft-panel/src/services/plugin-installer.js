const Docker = require('dockerode');
const fs = require('fs-extra');
const path = require('path');
const axios = require('axios');
const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();
const docker = new Docker();

class PluginInstaller {
  constructor() {
    this.docker = docker;
    this.pluginCache = new Map();
  }

  static async initialize() {
    // Initialize plugin repositories
    await this.syncPluginRepositories();
  }

  static async syncPluginRepositories() {
    try {
      // Sync with SpigotMC, Bukkit, etc.
      const repositories = [
        {
          name: 'SpigotMC',
          url: 'https://api.spigotmc.org/legacy/update.php?resource=',
          description: 'Official SpigotMC plugin repository'
        },
        {
          name: 'BukkitDev',
          url: 'https://dev.bukkit.org/bukkit-plugins/',
          description: 'Bukkit plugin repository'
        },
        {
          name: 'Hangar',
          url: 'https://hangar.papermc.io/api/v1/projects/',
          description: 'PaperMC plugin repository'
        }
      ];

      for (const repo of repositories) {
        await prisma.pluginRepository.upsert({
          where: { name: repo.name },
          update: {
            url: repo.url,
            description: repo.description,
            lastSync: new Date()
          },
          create: {
            name: repo.name,
            url: repo.url,
            description: repo.description,
            isActive: true,
            lastSync: new Date()
          }
        });
      }

      console.log('✅ Plugin repositories synchronized');
    } catch (error) {
      console.error('❌ Failed to sync plugin repositories:', error);
    }
  }

  static async searchPlugins(query, serverType = 'spigot') {
    try {
      const plugins = await prisma.pluginInfo.findMany({
        where: {
          name: {
            contains: query,
            mode: 'insensitive'
          }
        },
        include: {
          versions: {
            orderBy: { version: 'desc' },
            take: 5
          }
        },
        take: 20
      });

      return plugins;
    } catch (error) {
      console.error('Error searching plugins:', error);
      throw new Error('Failed to search plugins');
    }
  }

  static async install(serverId, pluginId, version) {
    try {
      console.log(`🔌 Installing plugin ${pluginId} v${version} on server ${serverId}`);

      // Get server info
      const server = await prisma.server.findUnique({
        where: { id: serverId },
        include: { node: true }
      });

      if (!server) {
        throw new Error('Server not found');
      }

      // Get plugin info
      const pluginInfo = await prisma.pluginInfo.findUnique({
        where: { id: pluginId },
        include: {
          versions: {
            where: { version }
          }
        }
      });

      if (!pluginInfo || !pluginInfo.versions[0]) {
        throw new Error('Plugin version not found');
      }

      const pluginVersion = pluginInfo.versions[0];

      // Check compatibility
      if (!pluginVersion.minecraftVersions.includes(server.version)) {
        throw new Error(`Plugin is not compatible with Minecraft ${server.version}`);
      }

      // Create isolated Docker container for installation
      const containerName = `plugin-install-${serverId}-${Date.now()}`;

      const container = await docker.createContainer({
        Image: 'openjdk:17-alpine',
        name: containerName,
        WorkingDir: '/server',
        Cmd: ['sh', '-c', 'echo "Plugin installation container ready"'],
        HostConfig: {
          Binds: [
            `${path.join(process.cwd(), 'servers', serverId)}:/server:rw`
          ],
          Memory: 512 * 1024 * 1024, // 512MB limit
          CpuQuota: 50000, // 50% CPU limit
          CpuPeriod: 100000
        }
      });

      // Start container
      await container.start();

      try {
        // Download plugin file
        console.log(`📥 Downloading plugin from ${pluginVersion.downloadUrl}`);

        const downloadResponse = await axios.get(pluginVersion.downloadUrl, {
          responseType: 'stream',
          timeout: 30000
        });

        const pluginsDir = path.join(process.cwd(), 'servers', serverId, 'plugins');
        await fs.ensureDir(pluginsDir);

        const pluginFileName = `${pluginInfo.name}-${version}.jar`;
        const pluginPath = path.join(pluginsDir, pluginFileName);

        // Save plugin file
        const writer = fs.createWriteStream(pluginPath);
        downloadResponse.data.pipe(writer);

        await new Promise((resolve, reject) => {
          writer.on('finish', resolve);
          writer.on('error', reject);
        });

        // Verify file integrity
        if (pluginVersion.checksum) {
          const crypto = require('crypto');
          const fileBuffer = await fs.readFile(pluginPath);
          const hash = crypto.createHash('sha256').update(fileBuffer).digest('hex');

          if (hash !== pluginVersion.checksum) {
            await fs.unlink(pluginPath);
            throw new Error('Plugin file checksum verification failed');
          }
        }

        console.log(`✅ Plugin ${pluginInfo.name} v${version} installed successfully`);

        return {
          name: pluginInfo.name,
          version: version,
          fileName: pluginFileName,
          author: pluginInfo.author,
          description: pluginInfo.description,
          filePath: pluginPath
        };

      } finally {
        // Clean up container
        try {
          await container.stop({ t: 10 });
          await container.remove();
        } catch (error) {
          console.warn('Failed to clean up installation container:', error);
        }
      }

    } catch (error) {
      console.error('❌ Plugin installation failed:', error);
      throw error;
    }
  }

  static async uninstall(serverId, pluginId) {
    try {
      console.log(`🔌 Uninstalling plugin ${pluginId} from server ${serverId}`);

      // Get plugin info
      const plugin = await prisma.plugin.findUnique({
        where: { id: pluginId }
      });

      if (!plugin) {
        throw new Error('Plugin not found');
      }

      // Remove plugin file
      const pluginPath = path.join(process.cwd(), 'servers', serverId, 'plugins', plugin.fileName);

      if (await fs.pathExists(pluginPath)) {
        await fs.unlink(pluginPath);
        console.log(`🗑️ Plugin file ${plugin.fileName} removed`);
      }

      // Remove from database (this is done in the route handler)

      console.log(`✅ Plugin ${plugin.name} uninstalled successfully`);

      return {
        pluginId,
        fileName: plugin.fileName
      };

    } catch (error) {
      console.error('❌ Plugin uninstallation failed:', error);
      throw error;
    }
  }

  static async update(serverId, pluginId, newVersion) {
    try {
      console.log(`🔄 Updating plugin ${pluginId} to v${newVersion} on server ${serverId}`);

      // First uninstall old version
      await this.uninstall(serverId, pluginId);

      // Then install new version
      const result = await this.install(serverId, pluginId, newVersion);

      console.log(`✅ Plugin ${result.name} updated to v${newVersion}`);

      return result;

    } catch (error) {
      console.error('❌ Plugin update failed:', error);
      throw error;
    }
  }

  static async getInstalledPlugins(serverId) {
    try {
      const plugins = await prisma.plugin.findMany({
        where: { serverId },
        orderBy: { installedAt: 'desc' }
      });

      return plugins;
    } catch (error) {
      console.error('Error getting installed plugins:', error);
      throw error;
    }
  }

  static async enablePlugin(serverId, pluginId) {
    try {
      await prisma.plugin.update({
        where: { id: pluginId },
        data: { isEnabled: true }
      });

      // Send command to server to enable plugin
      await this.sendServerCommand(serverId, `plugman enable ${pluginId}`);

      console.log(`✅ Plugin ${pluginId} enabled`);
    } catch (error) {
      console.error('Error enabling plugin:', error);
      throw error;
    }
  }

  static async disablePlugin(serverId, pluginId) {
    try {
      await prisma.plugin.update({
        where: { id: pluginId },
        data: { isEnabled: false }
      });

      // Send command to server to disable plugin
      await this.sendServerCommand(serverId, `plugman disable ${pluginId}`);

      console.log(`✅ Plugin ${pluginId} disabled`);
    } catch (error) {
      console.error('Error disabling plugin:', error);
      throw error;
    }
  }

  static async sendServerCommand(serverId, command) {
    try {
      // This would communicate with the daemon
      const axios = require('axios');
      await axios.post(`http://localhost:8080/servers/${serverId}/command`, {
        command
      });
    } catch (error) {
      console.warn('Failed to send command to server:', error);
    }
  }

  static async validatePluginSecurity(pluginPath) {
    try {
      const fs = require('fs-extra');
      const crypto = require('crypto');

      // Read plugin file
      const pluginBuffer = await fs.readFile(pluginPath);

      // Basic security checks
      const securityIssues = [];

      // Check file size (reasonable limit)
      if (pluginBuffer.length > 50 * 1024 * 1024) { // 50MB
        securityIssues.push('Plugin file is too large');
      }

      // Check for suspicious code patterns (basic)
      const pluginContent = pluginBuffer.toString('utf8', 0, 1024); // First 1KB

      const dangerousPatterns = [
        /Runtime\.exec/i,
        /ProcessBuilder/i,
        /File\./i,
        /System\./i,
        /eval\(/i,
        /execute\(/i
      ];

      for (const pattern of dangerousPatterns) {
        if (pattern.test(pluginContent)) {
          securityIssues.push(`Potentially dangerous code pattern detected: ${pattern}`);
        }
      }

      return {
        isSafe: securityIssues.length === 0,
        issues: securityIssues
      };

    } catch (error) {
      console.error('Error validating plugin security:', error);
      return {
        isSafe: false,
        issues: ['Failed to validate plugin security']
      };
    }
  }
}

module.exports = PluginInstaller;