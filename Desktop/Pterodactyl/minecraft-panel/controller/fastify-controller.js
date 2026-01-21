const fastify = require('fastify')({
  logger: true,
  disableRequestLogging: process.env.NODE_ENV === 'production'
});

const path = require('path');
const fs = require('fs-extra');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const { PrismaClient } = require('@prisma/client');
const Redis = require('ioredis');

// Import services
const PluginInstaller = require('../src/services/plugin-installer');
const ModInstaller = require('../src/services/mod-installer');
const UserDataManager = require('../src/services/user-data-manager');

// Initialize clients
const prisma = new PrismaClient();
const redis = new Redis(process.env.REDIS_URL || 'redis://localhost:6379');

// Register plugins
async function registerPlugins() {
  // CORS
  await fastify.register(require('@fastify/cors'), {
    origin: true,
    credentials: true
  });

  // Helmet (Security headers)
  await fastify.register(require('@fastify/helmet'), {
    contentSecurityPolicy: {
      directives: {
        defaultSrc: ["'self'"],
        styleSrc: ["'self'", "'unsafe-inline'", "https://cdn.jsdelivr.net", "https://fonts.googleapis.com"],
        scriptSrc: ["'self'", "https://cdn.jsdelivr.net", "https://unpkg.com"],
        fontSrc: ["'self'", "https://fonts.gstatic.com"],
        imgSrc: ["'self'", "data:", "https://*"],
        connectSrc: ["'self'", "ws:", "wss:", "https:"]
      }
    }
  });

  // Rate limiting
  await fastify.register(require('@fastify/rate-limit'), {
    max: 100,
    timeWindow: '1 minute',
    skipOnError: true
  });

  // Multipart (File uploads)
  await fastify.register(require('@fastify/multipart'), {
    limits: {
      fileSize: parseInt(process.env.MAX_FILE_SIZE) || 100 * 1024 * 1024 // 100MB
    }
  });

  // WebSocket support
  await fastify.register(require('fastify-socket.io'), {
    cors: {
      origin: "*",
      methods: ["GET", "POST"]
    }
  });
}

// Authentication middleware
async function authenticate(request, reply) {
  try {
    const token = request.headers.authorization?.replace('Bearer ', '');

    if (!token) {
      return reply.code(401).send({ error: 'No token provided' });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const user = await prisma.user.findUnique({
      where: { id: decoded.id },
      include: {
        playerData: true,
        inventory: true,
        skins: true,
        servers: {
          include: {
            node: true,
            plugins: true,
            mods: true,
            stats: true
          }
        }
      }
    });

    if (!user || !user.isActive) {
      return reply.code(401).send({ error: 'Invalid token' });
    }

    request.user = user;
  } catch (error) {
    return reply.code(401).send({ error: 'Invalid token' });
  }
}

// Authorization middleware
function authorize(roles = []) {
  return async (request, reply) => {
    if (!request.user) {
      return reply.code(401).send({ error: 'Authentication required' });
    }

    if (roles.length > 0 && !roles.includes(request.user.role)) {
      return reply.code(403).send({ error: 'Insufficient permissions' });
    }
  };
}

// Routes
async function registerRoutes() {
  // Health check
  fastify.get('/health', async () => {
    return {
      status: 'ok',
      timestamp: new Date().toISOString(),
      version: process.env.npm_package_version || '1.0.0'
    };
  });

  // Authentication routes
  fastify.post('/api/auth/register', async (request, reply) => {
    const { username, email, password } = request.body;

    try {
      const hashedPassword = await bcrypt.hash(password, 12);

      const user = await prisma.user.create({
        data: {
          username,
          email,
          password: hashedPassword,
          playerData: {
            create: {}
          }
        }
      });

      const token = jwt.sign(
        { id: user.id, username: user.username },
        process.env.JWT_SECRET,
        { expiresIn: process.env.JWT_EXPIRES_IN || '24h' }
      );

      return {
        success: true,
        token,
        user: {
          id: user.id,
          username: user.username,
          email: user.email,
          role: user.role
        }
      };
    } catch (error) {
      if (error.code === 'P2002') {
        return reply.code(400).send({ error: 'Username or email already exists' });
      }
      throw error;
    }
  });

  fastify.post('/api/auth/login', async (request, reply) => {
    const { username, password } = request.body;

    const user = await prisma.user.findFirst({
      where: {
        OR: [
          { username },
          { email: username }
        ]
      },
      include: {
        playerData: true,
        inventory: true,
        skins: true
      }
    });

    if (!user || !await bcrypt.compare(password, user.password)) {
      return reply.code(401).send({ error: 'Invalid credentials' });
    }

    if (!user.isActive) {
      return reply.code(401).send({ error: 'Account is deactivated' });
    }

    // Update last login
    await prisma.user.update({
      where: { id: user.id },
      data: { lastLogin: new Date() }
    });

    const token = jwt.sign(
      { id: user.id, username: user.username },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN || '24h' }
    );

    return {
      success: true,
      token,
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        role: user.role,
        playerData: user.playerData,
        inventory: user.inventory,
        skins: user.skins
      }
    };
  });

  // Protected routes
  fastify.addHook('preHandler', authenticate);

  // User profile routes
  fastify.get('/api/user/profile', async (request) => {
    return {
      success: true,
      user: request.user
    };
  });

  fastify.put('/api/user/profile', async (request) => {
    const { username, email } = request.body;

    const user = await prisma.user.update({
      where: { id: request.user.id },
      data: { username, email },
      include: {
        playerData: true,
        inventory: true,
        skins: true
      }
    });

    return {
      success: true,
      user
    };
  });

  // Inventory routes
  fastify.get('/api/user/inventory', async (request) => {
    const inventory = await prisma.inventoryItem.findMany({
      where: { userId: request.user.id },
      orderBy: { createdAt: 'desc' }
    });

    return {
      success: true,
      inventory
    };
  });

  fastify.post('/api/user/inventory', async (request) => {
    const { itemId, itemType, itemName, quantity, durability, enchantments, customName, lore, slot } = request.body;

    const item = await prisma.inventoryItem.create({
      data: {
        userId: request.user.id,
        itemId,
        itemType,
        itemName,
        quantity: quantity || 1,
        durability,
        enchantments,
        customName,
        lore,
        slot
      }
    });

    // Update Redis cache for real-time sync
    await redis.set(`inventory:${request.user.id}:${item.id}`, JSON.stringify(item));

    return {
      success: true,
      item
    };
  });

  fastify.put('/api/user/inventory/:itemId', async (request) => {
    const { itemId } = request.params;
    const updateData = request.body;

    const item = await prisma.inventoryItem.update({
      where: {
        id: itemId,
        userId: request.user.id
      },
      data: updateData
    });

    // Update Redis cache
    await redis.set(`inventory:${request.user.id}:${item.id}`, JSON.stringify(item));

    return {
      success: true,
      item
    };
  });

  // Skin routes
  fastify.get('/api/user/skins', async (request) => {
    const skins = await prisma.skin.findMany({
      where: { userId: request.user.id },
      orderBy: { createdAt: 'desc' }
    });

    return {
      success: true,
      skins
    };
  });

  fastify.post('/api/user/skins', async (request) => {
    const { name, type, imageUrl } = request.body;

    const skin = await prisma.skin.create({
      data: {
        userId: request.user.id,
        name,
        type,
        imageUrl
      }
    });

    return {
      success: true,
      skin
    };
  });

  fastify.put('/api/user/skins/:skinId/activate', async (request) => {
    const { skinId } = request.params;

    // Deactivate all skins first
    await prisma.skin.updateMany({
      where: { userId: request.user.id },
      data: { isActive: false }
    });

    // Activate selected skin
    const skin = await prisma.skin.update({
      where: {
        id: skinId,
        userId: request.user.id
      },
      data: { isActive: true }
    });

    return {
      success: true,
      skin
    };
  });

  // Player data routes (real-time health, etc.)
  fastify.get('/api/user/player-data', async (request) => {
    const playerData = await prisma.playerData.findUnique({
      where: { userId: request.user.id }
    });

    return {
      success: true,
      playerData
    };
  });

  fastify.put('/api/user/player-data', async (request) => {
    const updateData = request.body;

    const playerData = await prisma.playerData.update({
      where: { userId: request.user.id },
      data: updateData
    });

    // Update Redis cache for real-time sync
    await redis.set(`playerData:${request.user.id}`, JSON.stringify(playerData));

    // Emit real-time update via Socket.IO
    fastify.io.to(`user-${request.user.id}`).emit('player-data-update', playerData);

    return {
      success: true,
      playerData
    };
  });

  // Server routes
  fastify.get('/api/servers', async (request) => {
    const servers = await prisma.server.findMany({
      where: { ownerId: request.user.id },
      include: {
        node: true,
        plugins: true,
        mods: true,
        stats: true,
        players: {
          where: { leftAt: null },
          orderBy: { joinedAt: 'desc' }
        }
      }
    });

    return {
      success: true,
      servers
    };
  });

  fastify.get('/api/servers/:id', async (request) => {
    const { id } = request.params;

    const server = await prisma.server.findFirst({
      where: {
        id,
        ownerId: request.user.id
      },
      include: {
        node: true,
        plugins: true,
        mods: true,
        stats: true,
        players: {
          orderBy: { joinedAt: 'desc' },
          take: 20
        },
        backups: {
          orderBy: { createdAt: 'desc' }
        }
      }
    });

    if (!server) {
      return reply.code(404).send({ error: 'Server not found' });
    }

    return {
      success: true,
      server
    };
  });

  fastify.post('/api/servers', async (request) => {
    const { name, description, nodeId, memory, disk, version, gameType } = request.body;

    // Find available node
    const node = nodeId ?
      await prisma.node.findUnique({ where: { id: nodeId } }) :
      await prisma.node.findFirst({ where: { status: 'ONLINE' } });

    if (!node) {
      return reply.code(400).send({ error: 'No available nodes' });
    }

    // Check resource availability
    const requestedMemory = parseInt(memory) || 2048;
    const requestedDisk = parseInt(disk) || 10240;

    if (node.usedMemory + requestedMemory > node.maxMemory ||
        node.usedDisk + requestedDisk > node.maxDisk ||
        node.serverCount >= node.maxServers) {
      return reply.code(400).send({ error: 'Insufficient resources' });
    }

    // Find available port
    const usedPorts = await prisma.server.findMany({
      select: { port: true }
    });
    const portRange = node.portRange as any;
    let port = portRange.start;

    while (usedPorts.some(s => s.port === port)) {
      port++;
      if (port > portRange.end) {
        return reply.code(400).send({ error: 'No available ports' });
      }
    }

    // Create server
    const server = await prisma.server.create({
      data: {
        name,
        description,
        ownerId: request.user.id,
        nodeId: node.id,
        memory: `${requestedMemory}M`,
        disk: requestedDisk,
        version: version || '1.20.1',
        gameType: gameType || 'MINECRAFT_JAVA',
        port
      },
      include: {
        node: true
      }
    });

    // Update node resources
    await prisma.node.update({
      where: { id: node.id },
      data: {
        usedMemory: { increment: requestedMemory },
        usedDisk: { increment: requestedDisk },
        serverCount: { increment: 1 }
      }
    });

    return {
      success: true,
      server
    };
  });

  // Plugin routes
  fastify.get('/api/servers/:serverId/plugins', async (request) => {
    const { serverId } = request.params;

    // Check server ownership
    const server = await prisma.server.findFirst({
      where: { id: serverId, ownerId: request.user.id }
    });

    if (!server) {
      return reply.code(404).send({ error: 'Server not found' });
    }

    const plugins = await prisma.plugin.findMany({
      where: { serverId },
      orderBy: { installedAt: 'desc' }
    });

    return {
      success: true,
      plugins
    };
  });

  fastify.post('/api/servers/:serverId/plugins/install', async (request) => {
    const { serverId } = request.params;
    const { pluginId, version } = request.body;

    try {
      const result = await PluginInstaller.install(serverId, pluginId, version);

      // Record in database
      await prisma.plugin.create({
        data: {
          serverId,
          name: result.name,
          version: result.version,
          fileName: result.fileName,
          author: result.author,
          description: result.description
        }
      });

      return {
        success: true,
        message: 'Plugin installed successfully',
        plugin: result
      };
    } catch (error) {
      return reply.code(500).send({ error: error.message });
    }
  });

  fastify.delete('/api/servers/:serverId/plugins/:pluginId', async (request) => {
    const { serverId, pluginId } = request.params;

    try {
      const result = await PluginInstaller.uninstall(serverId, pluginId);

      // Remove from database
      await prisma.plugin.delete({
        where: { id: pluginId }
      });

      return {
        success: true,
        message: 'Plugin uninstalled successfully'
      };
    } catch (error) {
      return reply.code(500).send({ error: error.message });
    }
  });

  // Mod routes
  fastify.get('/api/servers/:serverId/mods', async (request) => {
    const { serverId } = request.params;

    const server = await prisma.server.findFirst({
      where: { id: serverId, ownerId: request.user.id }
    });

    if (!server) {
      return reply.code(404).send({ error: 'Server not found' });
    }

    const mods = await prisma.mod.findMany({
      where: { serverId },
      orderBy: { installedAt: 'desc' }
    });

    return {
      success: true,
      mods
    };
  });

  fastify.post('/api/servers/:serverId/mods/install', async (request) => {
    const { serverId } = request.params;
    const { modId, version, modLoader } = request.body;

    try {
      const result = await ModInstaller.install(serverId, modId, version, modLoader);

      await prisma.mod.create({
        data: {
          serverId,
          name: result.name,
          version: result.version,
          fileName: result.fileName,
          modLoader: result.modLoader,
          author: result.author,
          description: result.description
        }
      });

      return {
        success: true,
        message: 'Mod installed successfully',
        mod: result
      };
    } catch (error) {
      return reply.code(500).send({ error: error.message });
    }
  });

  // File manager routes
  fastify.get('/api/servers/:serverId/files', async (request) => {
    const { serverId } = request.params;
    const { path: filePath = '' } = request.query;

    // Forward to daemon
    try {
      const response = await fastify.inject({
        method: 'GET',
        url: `http://localhost:8080/servers/${serverId}/files?path=${encodeURIComponent(filePath)}`
      });

      return JSON.parse(response.body);
    } catch (error) {
      return reply.code(500).send({ error: 'Failed to connect to daemon' });
    }
  });

  // Backup routes
  fastify.post('/api/servers/:serverId/backups', async (request) => {
    const { serverId } = request.params;
    const { name } = request.body;

    try {
      const response = await fastify.inject({
        method: 'POST',
        url: `http://localhost:8080/servers/${serverId}/backup`,
        payload: { name }
      });

      const result = JSON.parse(response.body);

      if (result.success) {
        await prisma.backup.create({
          data: {
            serverId,
            name: name || `Backup ${new Date().toISOString()}`,
            fileName: result.backup.backupId + '.zip',
            size: result.backup.size
          }
        });
      }

      return result;
    } catch (error) {
      return reply.code(500).send({ error: 'Failed to create backup' });
    }
  });

  // Admin routes
  fastify.addHook('preHandler', authorize(['ADMIN']));

  fastify.get('/api/admin/stats', async (request) => {
    const [
      totalUsers,
      totalServers,
      totalNodes,
      onlineServers
    ] = await Promise.all([
      prisma.user.count(),
      prisma.server.count(),
      prisma.node.count(),
      prisma.server.count({ where: { status: 'RUNNING' } })
    ]);

    return {
      success: true,
      stats: {
        totalUsers,
        totalServers,
        totalNodes,
        onlineServers
      }
    };
  });

  fastify.get('/api/admin/users', async (request) => {
    const { page = 1, limit = 10 } = request.query;
    const skip = (page - 1) * limit;

    const users = await prisma.user.findMany({
      skip,
      take: parseInt(limit),
      orderBy: { createdAt: 'desc' },
      include: {
        servers: true,
        playerData: true
      }
    });

    const total = await prisma.user.count();

    return {
      success: true,
      users,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / limit)
      }
    };
  });
}

// Socket.IO handlers
function setupSocketHandlers() {
  fastify.io.on('connection', (socket) => {
    console.log(`Web client connected: ${socket.id}`);

    socket.on('join-server', (serverId) => {
      socket.join(`server-${serverId}`);
      console.log(`Web client ${socket.id} joined server-${serverId}`);
    });

    socket.on('join-user', (userId) => {
      socket.join(`user-${userId}`);
      console.log(`Web client ${socket.id} joined user-${userId}`);
    });

    socket.on('console-command', async (data) => {
      try {
        const { serverId, command } = data;

        // Get server node
        const server = await prisma.server.findUnique({
          where: { id: serverId },
          include: { node: true }
        });

        if (!server) {
          socket.emit('command-error', { error: 'Server not found' });
          return;
        }

        // Send command to daemon
        try {
          const response = await fastify.inject({
            method: 'POST',
            url: `http://localhost:8080/servers/${serverId}/command`,
            payload: { command }
          });

          const result = JSON.parse(response.body);
          if (!result.success) {
            socket.emit('command-error', { error: result.message });
          }
        } catch (error) {
          socket.emit('command-error', { error: 'Failed to send command' });
        }

      } catch (error) {
        console.error('Error sending console command:', error);
        socket.emit('command-error', { error: 'Failed to send command' });
      }
    });

    socket.on('disconnect', () => {
      console.log(`Web client disconnected: ${socket.id}`);
    });
  });
}

// Initialize services
async function initializeServices() {
  await PluginInstaller.initialize();
  await ModInstaller.initialize();
  await UserDataManager.initialize();
}

// Start server
async function start() {
  try {
    // Register plugins
    await registerPlugins();

    // Initialize services
    await initializeServices();

    // Register routes
    await registerRoutes();

    // Setup Socket.IO
    setupSocketHandlers();

    // Static files
    fastify.register(require('@fastify/static'), {
      root: path.join(__dirname, '../public'),
      prefix: '/'
    });

    // Web routes
    fastify.get('/', (request, reply) => {
      return reply.sendFile('views/index.html');
    });

    fastify.get('/dashboard', (request, reply) => {
      return reply.sendFile('views/dashboard.html');
    });

    fastify.get('/admin', (request, reply) => {
      return reply.sendFile('views/admin.html');
    });

    fastify.get('/server/:id', (request, reply) => {
      return reply.sendFile('views/server.html');
    });

    fastify.get('/files/:serverId', (request, reply) => {
      return reply.sendFile('views/files.html');
    });

    // Start server
    const port = process.env.PORT || 3000;
    await fastify.listen({ port, host: '0.0.0.0' });

    console.log(`🚀 Minecraft Ultra Panel running on port ${port}`);
    console.log(`🌐 Web interface: http://localhost:${port}`);
    console.log(`🔧 Admin panel: http://localhost:${port}/admin`);

  } catch (err) {
    fastify.log.error(err);
    process.exit(1);
  }
}

// Graceful shutdown
process.on('SIGINT', async () => {
  console.log('Shutting down gracefully...');
  await prisma.$disconnect();
  await redis.quit();
  process.exit(0);
});

process.on('SIGTERM', async () => {
  console.log('Shutting down gracefully...');
  await prisma.$disconnect();
  await redis.quit();
  process.exit(0);
});

module.exports = { start };