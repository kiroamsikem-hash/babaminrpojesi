const { PrismaClient } = require('@prisma/client');
const Redis = require('ioredis');
const crypto = require('crypto-js');

const prisma = new PrismaClient();
const redis = new Redis(process.env.REDIS_URL || 'redis://localhost:6379');

class UserDataManager {
  constructor() {
    this.encryptionKey = process.env.DATA_ENCRYPTION_KEY || 'default-encryption-key-change-in-production';
  }

  static async initialize() {
    console.log('🔐 User Data Manager initialized');
  }

  // Player Data Management
  static async updatePlayerHealth(userId, health, maxHealth = 20.0) {
    try {
      const playerData = await prisma.playerData.upsert({
        where: { userId },
        update: {
          health,
          maxHealth,
          lastSeen: new Date()
        },
        create: {
          userId,
          health,
          maxHealth
        }
      });

      // Cache in Redis
      await redis.set(`playerData:${userId}`, JSON.stringify(playerData), 'EX', 3600); // 1 hour

      // Emit real-time update
      const io = require('../../controller/fastify-controller').io;
      if (io) {
        io.to(`user-${userId}`).emit('player-data-update', {
          health,
          maxHealth,
          timestamp: new Date().toISOString()
        });
      }

      return playerData;
    } catch (error) {
      console.error('Error updating player health:', error);
      throw error;
    }
  }

  static async updatePlayerStats(userId, stats) {
    try {
      const updateData = {};

      // Map stats to database fields
      if (stats.x !== undefined && stats.y !== undefined && stats.z !== undefined) {
        updateData.x = stats.x;
        updateData.y = stats.y;
        updateData.z = stats.z;
        updateData.world = stats.world;
      }

      if (stats.hunger !== undefined) updateData.hunger = stats.hunger;
      if (stats.experience !== undefined) updateData.experience = stats.experience;
      if (stats.level !== undefined) updateData.level = stats.level;
      if (stats.gameMode !== undefined) updateData.gameMode = stats.gameMode;

      const playerData = await prisma.playerData.update({
        where: { userId },
        data: updateData
      });

      // Update Redis cache
      await redis.set(`playerData:${userId}`, JSON.stringify(playerData), 'EX', 3600);

      return playerData;
    } catch (error) {
      console.error('Error updating player stats:', error);
      throw error;
    }
  }

  // Inventory Management
  static async addInventoryItem(userId, itemData) {
    try {
      // Check if item already exists and stackable
      const existingItem = await prisma.inventoryItem.findFirst({
        where: {
          userId,
          itemId: itemData.itemId,
          durability: itemData.durability || null
        }
      });

      let item;

      if (existingItem && this.isStackable(itemData.itemType)) {
        // Stack items
        item = await prisma.inventoryItem.update({
          where: { id: existingItem.id },
          data: {
            quantity: { increment: itemData.quantity || 1 },
            updatedAt: new Date()
          }
        });
      } else {
        // Create new item
        item = await prisma.inventoryItem.create({
          data: {
            userId,
            ...itemData,
            quantity: itemData.quantity || 1
          }
        });
      }

      // Update Redis cache
      await redis.set(`inventory:${userId}:${item.id}`, JSON.stringify(item), 'EX', 3600);

      // Emit real-time update
      const io = require('../../controller/fastify-controller').io;
      if (io) {
        io.to(`user-${userId}`).emit('inventory-update', {
          action: 'add',
          item,
          timestamp: new Date().toISOString()
        });
      }

      return item;
    } catch (error) {
      console.error('Error adding inventory item:', error);
      throw error;
    }
  }

  static async removeInventoryItem(userId, itemId, quantity = 1) {
    try {
      const item = await prisma.inventoryItem.findFirst({
        where: { id: itemId, userId }
      });

      if (!item) {
        throw new Error('Item not found');
      }

      if (item.quantity <= quantity) {
        // Remove item completely
        await prisma.inventoryItem.delete({
          where: { id: itemId }
        });

        // Remove from Redis
        await redis.del(`inventory:${userId}:${itemId}`);

        // Emit real-time update
        const io = require('../../controller/fastify-controller').io;
        if (io) {
          io.to(`user-${userId}`).emit('inventory-update', {
            action: 'remove',
            itemId,
            timestamp: new Date().toISOString()
          });
        }

        return null;
      } else {
        // Reduce quantity
        const updatedItem = await prisma.inventoryItem.update({
          where: { id: itemId },
          data: {
            quantity: { decrement: quantity },
            updatedAt: new Date()
          }
        });

        // Update Redis cache
        await redis.set(`inventory:${userId}:${itemId}`, JSON.stringify(updatedItem), 'EX', 3600);

        return updatedItem;
      }
    } catch (error) {
      console.error('Error removing inventory item:', error);
      throw error;
    }
  }

  static async updateInventorySlot(userId, itemId, slot) {
    try {
      const item = await prisma.inventoryItem.update({
        where: {
          id: itemId,
          userId
        },
        data: { slot }
      });

      // Update Redis cache
      await redis.set(`inventory:${userId}:${itemId}`, JSON.stringify(item), 'EX', 3600);

      return item;
    } catch (error) {
      console.error('Error updating inventory slot:', error);
      throw error;
    }
  }

  // Skin Management
  static async createSkin(userId, skinData) {
    try {
      const skin = await prisma.skin.create({
        data: {
          userId,
          ...skinData
        }
      });

      return skin;
    } catch (error) {
      console.error('Error creating skin:', error);
      throw error;
    }
  }

  static async activateSkin(userId, skinId) {
    try {
      // Deactivate all skins
      await prisma.skin.updateMany({
        where: { userId },
        data: { isActive: false }
      });

      // Activate selected skin
      const skin = await prisma.skin.update({
        where: {
          id: skinId,
          userId
        },
        data: { isActive: true }
      });

      // Emit real-time update
      const io = require('../../controller/fastify-controller').io;
      if (io) {
        io.to(`user-${userId}`).emit('skin-update', {
          activeSkin: skin,
          timestamp: new Date().toISOString()
        });
      }

      return skin;
    } catch (error) {
      console.error('Error activating skin:', error);
      throw error;
    }
  }

  // Data Encryption/Decryption
  static encryptData(data) {
    return crypto.AES.encrypt(JSON.stringify(data), this.encryptionKey).toString();
  }

  static decryptData(encryptedData) {
    try {
      const bytes = crypto.AES.decrypt(encryptedData, this.encryptionKey);
      return JSON.parse(bytes.toString(crypto.enc.Utf8));
    } catch (error) {
      console.error('Error decrypting data:', error);
      return null;
    }
  }

  // Real-time Data Synchronization
  static async syncPlayerData(userId, minecraftData) {
    try {
      // Update player data from Minecraft server
      const playerData = await this.updatePlayerStats(userId, minecraftData);

      // Sync inventory if provided
      if (minecraftData.inventory) {
        await this.syncInventory(userId, minecraftData.inventory);
      }

      return playerData;
    } catch (error) {
      console.error('Error syncing player data:', error);
      throw error;
    }
  }

  static async syncInventory(userId, minecraftInventory) {
    try {
      // Clear existing inventory
      await prisma.inventoryItem.deleteMany({
        where: { userId }
      });

      // Add new inventory items
      const inventoryItems = [];
      for (const [slot, item] of Object.entries(minecraftInventory)) {
        if (item && item.id) {
          const inventoryItem = await prisma.inventoryItem.create({
            data: {
              userId,
              itemId: item.id,
              itemType: item.type || 'item',
              itemName: item.name || item.id,
              quantity: item.count || 1,
              durability: item.durability,
              enchantments: item.enchantments,
              slot: parseInt(slot)
            }
          });
          inventoryItems.push(inventoryItem);
        }
      }

      // Cache in Redis
      for (const item of inventoryItems) {
        await redis.set(`inventory:${userId}:${item.id}`, JSON.stringify(item), 'EX', 3600);
      }

      return inventoryItems;
    } catch (error) {
      console.error('Error syncing inventory:', error);
      throw error;
    }
  }

  // Utility methods
  static isStackable(itemType) {
    // Define which item types are stackable
    const nonStackable = ['sword', 'pickaxe', 'axe', 'shovel', 'hoe', 'helmet', 'chestplate', 'leggings', 'boots'];
    return !nonStackable.includes(itemType);
  }

  static async getUserFullProfile(userId) {
    try {
      // Try Redis cache first
      const cached = await redis.get(`userProfile:${userId}`);
      if (cached) {
        return JSON.parse(cached);
      }

      // Fetch from database
      const user = await prisma.user.findUnique({
        where: { id: userId },
        include: {
          playerData: true,
          inventory: {
            orderBy: { slot: 'asc' }
          },
          skins: true,
          servers: {
            include: {
              node: true,
              plugins: true,
              mods: true
            }
          }
        }
      });

      if (!user) return null;

      // Cache for 30 minutes
      await redis.set(`userProfile:${userId}`, JSON.stringify(user), 'EX', 1800);

      return user;
    } catch (error) {
      console.error('Error getting user full profile:', error);
      throw error;
    }
  }

  static async cleanupExpiredData() {
    try {
      // Remove inactive player data (older than 30 days)
      const thirtyDaysAgo = new Date();
      thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

      await prisma.playerData.updateMany({
        where: {
          lastSeen: {
            lt: thirtyDaysAgo
          }
        },
        data: {
          isOnline: false
        }
      });

      console.log('✅ Expired player data cleaned up');
    } catch (error) {
      console.error('Error cleaning up expired data:', error);
    }
  }

  // Scheduled cleanup (should be called periodically)
  static startCleanupScheduler() {
    setInterval(() => {
      this.cleanupExpiredData();
    }, 24 * 60 * 60 * 1000); // Daily
  }
}

module.exports = UserDataManager;