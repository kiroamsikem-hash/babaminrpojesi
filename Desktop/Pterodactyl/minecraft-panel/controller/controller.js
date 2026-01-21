const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const mongoose = require('mongoose');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const path = require('path');
const axios = require('axios');
require('dotenv').config({ path: '../config.env' });

class MinecraftController {
  constructor() {
    this.app = express();
    this.server = http.createServer(this.app);
    this.io = socketIo(this.server, {
      cors: {
        origin: "*",
        methods: ["GET", "POST"]
      }
    });

    this.daemons = new Map(); // Store connected daemons
    this.setupMiddleware();
    this.setupRoutes();
    this.setupSocketHandlers();
    this.connectToDaemons();
  }

  setupMiddleware() {
    this.app.use(helmet({
      contentSecurityPolicy: {
        directives: {
          defaultSrc: ["'self'"],
          styleSrc: ["'self'", "'unsafe-inline'", "https://cdn.jsdelivr.net"],
          scriptSrc: ["'self'", "https://cdn.jsdelivr.net"],
          fontSrc: ["'self'", "https://fonts.gstatic.com"],
          imgSrc: ["'self'", "data:", "https:"],
          connectSrc: ["'self'", "ws:", "wss:"]
        }
      }
    }));

    this.app.use(cors());
    this.app.use(express.json({ limit: '50mb' }));
    this.app.use(express.urlencoded({ extended: true, limit: '50mb' }));

    // Rate limiting
    const limiter = rateLimit({
      windowMs: 15 * 60 * 1000, // 15 minutes
      max: 100, // limit each IP to 100 requests per windowMs
      message: 'Too many requests from this IP, please try again later.'
    });
    this.app.use('/api/', limiter);

    // Static files
    this.app.use(express.static(path.join(__dirname, '../public')));
  }

  setupRoutes() {
    // Import routes
    const authRoutes = require('../src/routes/auth');
    const serverRoutes = require('../src/routes/servers');
    const nodeRoutes = require('../src/routes/nodes');
    const adminRoutes = require('../src/routes/admin');
    const fileRoutes = require('../src/routes/files');
    const backupRoutes = require('../src/routes/backups');

    // API routes
    this.app.use('/api/auth', authRoutes);
    this.app.use('/api/servers', serverRoutes);
    this.app.use('/api/nodes', nodeRoutes);
    this.app.use('/api/admin', adminRoutes);
    this.app.use('/api/files', fileRoutes);
    this.app.use('/api/backups', backupRoutes);

    // Daemon communication routes
    this.app.post('/daemon/register', this.registerDaemon.bind(this));
    this.app.get('/daemon/health', this.getDaemonHealth.bind(this));

    // Web routes
    this.app.get('/', (req, res) => {
      res.sendFile(path.join(__dirname, '../public/views/index.html'));
    });

    this.app.get('/dashboard', (req, res) => {
      res.sendFile(path.join(__dirname, '../public/views/dashboard.html'));
    });

    this.app.get('/admin', (req, res) => {
      res.sendFile(path.join(__dirname, '../public/views/admin.html'));
    });

    this.app.get('/server/:id', (req, res) => {
      res.sendFile(path.join(__dirname, '../public/views/server.html'));
    });

    this.app.get('/files/:serverId', (req, res) => {
      res.sendFile(path.join(__dirname, '../public/views/files.html'));
    });
  }

  setupSocketHandlers() {
    this.io.on('connection', (socket) => {
      console.log(`Web client connected: ${socket.id}`);

      socket.on('join-server', (serverId) => {
        socket.join(`server-${serverId}`);
        console.log(`Web client ${socket.id} joined server-${serverId}`);
      });

      socket.on('leave-server', (serverId) => {
        socket.leave(`server-${serverId}`);
        console.log(`Web client ${socket.id} left server-${serverId}`);
      });

      socket.on('console-command', async (data) => {
        try {
          const { serverId, command } = data;

          // Get server node
          const Server = require('../src/models/Server');
          const server = await Server.findById(serverId).populate('node');

          if (!server) {
            socket.emit('command-error', { error: 'Server not found' });
            return;
          }

          // Send command to daemon
          await this.sendCommandToDaemon(server.node.host, serverId, command);

        } catch (error) {
          console.error('Error sending console command:', error);
          socket.emit('command-error', { error: 'Failed to send command' });
        }
      });

      socket.on('disconnect', () => {
        console.log(`Web client disconnected: ${socket.id}`);
      });
    });

    // Listen for daemon events
    this.setupDaemonListeners();
  }

  setupDaemonListeners() {
    // This will be called when daemons connect via Socket.IO
    // For now, we're using HTTP for daemon communication
  }

  async registerDaemon(req, res) {
    const { nodeId, host, port, capabilities } = req.body;

    if (!nodeId || !host) {
      return res.status(400).json({ error: 'nodeId and host are required' });
    }

    this.daemons.set(nodeId, {
      host,
      port: port || 8080,
      capabilities: capabilities || {},
      lastSeen: new Date(),
      status: 'online'
    });

    console.log(`Daemon registered: ${nodeId} at ${host}:${port}`);

    res.json({
      success: true,
      message: 'Daemon registered successfully'
    });
  }

  async getDaemonHealth(req, res) {
    const health = [];

    for (const [nodeId, daemon] of this.daemons) {
      try {
        const response = await axios.get(`http://${daemon.host}:${daemon.port}/health`, {
          timeout: 5000
        });

        health.push({
          nodeId,
          status: 'online',
          health: response.data
        });
      } catch (error) {
        health.push({
          nodeId,
          status: 'offline',
          error: error.message
        });
      }
    }

    res.json({ daemons: health });
  }

  async sendCommandToDaemon(daemonHost, serverId, command) {
    const daemon = Array.from(this.daemons.values()).find(d => d.host === daemonHost);

    if (!daemon) {
      throw new Error('Daemon not found for server');
    }

    const response = await axios.post(
      `http://${daemon.host}:${daemon.port}/servers/${serverId}/command`,
      { command },
      { timeout: 10000 }
    );

    return response.data;
  }

  async startServerOnDaemon(daemonHost, serverId, config) {
    const daemon = Array.from(this.daemons.values()).find(d => d.host === daemonHost);

    if (!daemon) {
      throw new Error('Daemon not found for server');
    }

    const response = await axios.post(
      `http://${daemon.host}:${daemon.port}/servers/${serverId}/start`,
      config,
      { timeout: 30000 }
    );

    return response.data;
  }

  async connectToDaemons() {
    // Connect to known daemons on startup
    const Node = require('../src/models/Node');

    try {
      const nodes = await Node.find({ status: 'online' });

      for (const node of nodes) {
        try {
          await axios.post('http://localhost:8080/daemon/register', {
            nodeId: node._id,
            host: node.host,
            port: 8080,
            capabilities: {
              docker: true,
              screen: true,
              cgroups: true
            }
          });
        } catch (error) {
          console.warn(`Failed to connect to daemon at ${node.host}:`, error.message);
        }
      }
    } catch (error) {
      console.error('Error connecting to daemons:', error);
    }
  }

  start(port = 3000) {
    // Database connection
    mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost/minecraft-panel')
      .then(() => console.log('MongoDB connected'))
      .catch(err => console.error('MongoDB connection error:', err));

    this.server.listen(port, () => {
      console.log(`Minecraft Controller running on port ${port}`);
      console.log(`Web interface available at http://localhost:${port}`);
    });
  }
}

// Export for use in other modules
module.exports = MinecraftController;

// Start controller if run directly
if (require.main === module) {
  const controller = new MinecraftController();
  controller.start(process.env.PORT || 3000);
}