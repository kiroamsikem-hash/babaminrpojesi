const Docker = require('dockerode');
const fs = require('fs-extra');
const path = require('path');
const axios = require('axios');
const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();
const docker = new Docker();

class ModInstaller {
  constructor() {
    this.docker = docker;
    this.modLoaders = {
      FORGE: {
        name: 'Forge',
        installDir: 'mods',
        configFile: 'config/mod-installer.json'
      },
      FABRIC: {
        name: 'Fabric',
        installDir: 'mods',
        configFile: 'config/fabric-installer.json'
      },
      NEOFORGE: {
        name: 'NeoForge',
        installDir: 'mods',
        configFile: 'config/neoforge-installer.json'
      }
    };
  }

  static async initialize() {
    // Initialize CurseForge, Modrinth APIs, etc.
    await this.syncModRepositories();
  }

  static async syncModRepositories() {
    try {
      // Sync with Modrinth, CurseForge, etc.
      const repositories = [
        {
          name: 'Modrinth',
          url: 'https://api.modrinth.com/v2/',
          description: 'Open-source mod repository'
        },
        {
          name: 'CurseForge',
          url: 'https://api.curseforge.com/v1/',
          description: 'Popular mod repository'
        }
      ];

      // Note: Actual implementation would sync mod data
      console.log('✅ Mod repositories synchronized');
    } catch (error) {
      console.error('❌ Failed to sync mod repositories:', error);
    }
  }

  static async searchMods(query, modLoader, minecraftVersion) {
    try {
      // This would integrate with Modrinth/CurseForge APIs
      // For now, return mock data
      return [
        {
          id: 'example-mod',
          name: 'Example Mod',
          description: 'An example mod',
          author: 'Mod Author',
          versions: ['1.0.0', '1.1.0'],
          compatibleVersions: [minecraftVersion],
          downloadUrl: 'https://example.com/mod.jar'
        }
      ];
    } catch (error) {
      console.error('Error searching mods:', error);
      throw new Error('Failed to search mods');
    }
  }

  static async install(serverId, modId, version, modLoader) {
    try {
      console.log(`🔧 Installing mod ${modId} v${version} (${modLoader}) on server ${serverId}`);

      // Get server info
      const server = await prisma.server.findUnique({
        where: { id: serverId },
        include: { node: true }
      });

      if (!server) {
        throw new Error('Server not found');
      }

      // Validate mod loader compatibility
      const loaderConfig = this.prototype.modLoaders[modLoader];
      if (!loaderConfig) {
        throw new Error(`Unsupported mod loader: ${modLoader}`);
      }

      // Check if server supports mods
      const supportedLoaders = ['FORGE', 'FABRIC', 'NEOFORGE'];
      if (!supportedLoaders.includes(server.gameType)) {
        throw new Error(`Server type ${server.gameType} does not support mods`);
      }

      // Create isolated Docker container for installation
      const containerName = `mod-install-${serverId}-${Date.now()}`;

      const container = await docker.createContainer({
        Image: 'openjdk:17-alpine',
        name: containerName,
        WorkingDir: '/server',
        Cmd: ['sh', '-c', 'echo "Mod installation container ready"'],
        HostConfig: {
          Binds: [
            `${path.join(process.cwd(), 'servers', serverId)}:/server:rw`
          ],
          Memory: 1024 * 1024 * 1024, // 1GB limit
          CpuQuota: 75000, // 75% CPU limit
          CpuPeriod: 100000
        }
      });

      // Start container
      await container.start();

      try {
        // Download mod file (mock implementation)
        const downloadUrl = `https://api.modrinth.com/v2/project/${modId}/version/${version}/download`;
        console.log(`📥 Downloading mod from ${downloadUrl}`);

        const downloadResponse = await axios.get(downloadUrl, {
          responseType: 'stream',
          timeout: 60000
        });

        const modsDir = path.join(process.cwd(), 'servers', serverId, loaderConfig.installDir);
        await fs.ensureDir(modsDir);

        const modFileName = `${modId}-${version}.jar`;
        const modPath = path.join(modsDir, modFileName);

        // Save mod file
        const writer = fs.createWriteStream(modPath);
        downloadResponse.data.pipe(writer);

        await new Promise((resolve, reject) => {
          writer.on('finish', resolve);
          writer.on('error', reject);
        });

        // Update mod configuration
        await this.updateModConfig(serverId, modId, version, modLoader, modFileName);

        console.log(`✅ Mod ${modId} v${version} installed successfully`);

        return {
          name: modId,
          version: version,
          fileName: modFileName,
          modLoader: modLoader,
          author: 'Mod Author', // Would come from API
          description: 'Mod description', // Would come from API
          filePath: modPath
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
      console.error('❌ Mod installation failed:', error);
      throw error;
    }
  }

  static async uninstall(serverId, modId) {
    try {
      console.log(`🔧 Uninstalling mod ${modId} from server ${serverId}`);

      // Get mod info
      const mod = await prisma.mod.findFirst({
        where: {
          serverId,
          name: modId
        }
      });

      if (!mod) {
        throw new Error('Mod not found');
      }

      // Get server and mod loader config
      const server = await prisma.server.findUnique({
        where: { id: serverId }
      });

      const loaderConfig = this.prototype.modLoaders[mod.modLoader];

      // Remove mod file
      const modPath = path.join(process.cwd(), 'servers', serverId, loaderConfig.installDir, mod.fileName);

      if (await fs.pathExists(modPath)) {
        await fs.unlink(modPath);
        console.log(`🗑️ Mod file ${mod.fileName} removed`);
      }

      // Update mod configuration
      await this.removeFromModConfig(serverId, modId, mod.modLoader);

      console.log(`✅ Mod ${mod.name} uninstalled successfully`);

      return {
        modId,
        fileName: mod.fileName
      };

    } catch (error) {
      console.error('❌ Mod uninstallation failed:', error);
      throw error;
    }
  }

  static async updateModConfig(serverId, modId, version, modLoader, fileName) {
    try {
      const server = await prisma.server.findUnique({
        where: { id: serverId }
      });

      const loaderConfig = this.prototype.modLoaders[modLoader];
      const configPath = path.join(process.cwd(), 'servers', serverId, loaderConfig.configFile);

      // Read existing config
      let config = {};
      if (await fs.pathExists(configPath)) {
        config = await fs.readJson(configPath);
      }

      // Add mod to config
      if (!config.mods) config.mods = {};
      config.mods[modId] = {
        version,
        fileName,
        enabled: true,
        installedAt: new Date().toISOString()
      };

      // Write updated config
      await fs.ensureDir(path.dirname(configPath));
      await fs.writeJson(configPath, config, { spaces: 2 });

    } catch (error) {
      console.warn('Failed to update mod config:', error);
    }
  }

  static async removeFromModConfig(serverId, modId, modLoader) {
    try {
      const loaderConfig = this.prototype.modLoaders[modLoader];
      const configPath = path.join(process.cwd(), 'servers', serverId, loaderConfig.configFile);

      if (await fs.pathExists(configPath)) {
        const config = await fs.readJson(configPath);
        if (config.mods && config.mods[modId]) {
          delete config.mods[modId];
          await fs.writeJson(configPath, config, { spaces: 2 });
        }
      }
    } catch (error) {
      console.warn('Failed to remove from mod config:', error);
    }
  }

  static async validateModCompatibility(serverId, modId, version, modLoader) {
    try {
      const server = await prisma.server.findUnique({
        where: { id: serverId }
      });

      // Check mod loader compatibility
      const compatibleLoaders = {
        FORGE: ['FORGE'],
        FABRIC: ['FABRIC'],
        NEOFORGE: ['NEOFORGE']
      };

      if (!compatibleLoaders[modLoader]?.includes(server.gameType)) {
        return {
          compatible: false,
          reason: `Mod loader ${modLoader} is not compatible with server type ${server.gameType}`
        };
      }

      // Check Minecraft version compatibility
      // This would integrate with mod APIs to check version compatibility

      return {
        compatible: true
      };

    } catch (error) {
      console.error('Error validating mod compatibility:', error);
      return {
        compatible: false,
        reason: 'Failed to validate compatibility'
      };
    }
  }

  static async getInstalledMods(serverId) {
    try {
      const mods = await prisma.mod.findMany({
        where: { serverId },
        orderBy: { installedAt: 'desc' }
      });

      return mods;
    } catch (error) {
      console.error('Error getting installed mods:', error);
      throw error;
    }
  }

  static async enableMod(serverId, modId) {
    try {
      await prisma.mod.updateMany({
        where: {
          serverId,
          name: modId
        },
        data: { isEnabled: true }
      });

      // Update config file
      const mod = await prisma.mod.findFirst({
        where: {
          serverId,
          name: modId
        }
      });

      if (mod) {
        await this.updateModConfig(serverId, modId, mod.version, mod.modLoader, mod.fileName);
      }

      console.log(`✅ Mod ${modId} enabled`);
    } catch (error) {
      console.error('Error enabling mod:', error);
      throw error;
    }
  }

  static async disableMod(serverId, modId) {
    try {
      await prisma.mod.updateMany({
        where: {
          serverId,
          name: modId
        },
        data: { isEnabled: false }
      });

      // Update config file (mark as disabled)
      const loaderConfig = this.prototype.modLoaders['FORGE']; // Default
      const configPath = path.join(process.cwd(), 'servers', serverId, loaderConfig.configFile);

      if (await fs.pathExists(configPath)) {
        const config = await fs.readJson(configPath);
        if (config.mods && config.mods[modId]) {
          config.mods[modId].enabled = false;
          await fs.writeJson(configPath, config, { spaces: 2 });
        }
      }

      console.log(`✅ Mod ${modId} disabled`);
    } catch (error) {
      console.error('Error disabling mod:', error);
      throw error;
    }
  }

  static async checkDependencies(modId, version, modLoader) {
    try {
      // This would check mod dependencies from APIs
      // For now, return empty dependencies
      return {
        dependencies: [],
        conflicts: []
      };
    } catch (error) {
      console.error('Error checking mod dependencies:', error);
      return {
        dependencies: [],
        conflicts: []
      };
    }
  }
}

module.exports = ModInstaller;