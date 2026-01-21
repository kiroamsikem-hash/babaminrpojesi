const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const { spawn } = require('child_process');
const fs = require('fs-extra');
const path = require('path');
const os = require('os');
const Docker = require('dockerode');
const chokidar = require('chokidar');

class MinecraftDaemon {
  constructor() {
    this.app = express();
    this.server = http.createServer(this.app);
    this.io = socketIo(this.server, {
      cors: {
        origin: "*",
        methods: ["GET", "POST"]
      }
    });

    this.docker = new Docker();
    this.activeProcesses = new Map();
    this.fileWatchers = new Map();
    this.serverStats = new Map();

    this.setupMiddleware();
    this.setupRoutes();
    this.setupSocketHandlers();
    this.startStatsMonitoring();
  }

  setupMiddleware() {
    this.app.use(express.json());
    this.app.use(express.urlencoded({ extended: true }));
  }

  setupRoutes() {
    // Health check
    this.app.get('/health', (req, res) => {
      res.json({
        status: 'healthy',
        uptime: process.uptime(),
        platform: os.platform(),
        arch: os.arch(),
        cpus: os.cpus().length,
        memory: {
          total: os.totalmem(),
          free: os.freemem(),
          used: os.totalmem() - os.freemem()
        }
      });
    });

    // Server management endpoints
    this.app.post('/servers/:serverId/start', this.startServer.bind(this));
    this.app.post('/servers/:serverId/stop', this.stopServer.bind(this));
    this.app.post('/servers/:serverId/restart', this.restartServer.bind(this));
    this.app.post('/servers/:serverId/command', this.sendCommand.bind(this));
    this.app.get('/servers/:serverId/stats', this.getServerStats.bind(this));

    // File management endpoints
    this.app.get('/servers/:serverId/files', this.listFiles.bind(this));
    this.app.get('/servers/:serverId/files/*', this.readFile.bind(this));
    this.app.post('/servers/:serverId/files/*', this.writeFile.bind(this));
    this.app.delete('/servers/:serverId/files/*', this.deleteFile.bind(this));

    // Backup endpoints
    this.app.post('/servers/:serverId/backup', this.createBackup.bind(this));
    this.app.get('/servers/:serverId/backups', this.listBackups.bind(this));
    this.app.post('/servers/:serverId/backups/:backupId/restore', this.restoreBackup.bind(this));
  }

  setupSocketHandlers() {
    this.io.on('connection', (socket) => {
      console.log(`Client connected: ${socket.id}`);

      socket.on('join-server', (serverId) => {
        socket.join(`server-${serverId}`);
        console.log(`Client ${socket.id} joined server-${serverId}`);
      });

      socket.on('leave-server', (serverId) => {
        socket.leave(`server-${serverId}`);
        console.log(`Client ${socket.id} left server-${serverId}`);
      });

      socket.on('disconnect', () => {
        console.log(`Client disconnected: ${socket.id}`);
      });
    });
  }

  async startServer(req, res) {
    const { serverId } = req.params;
    const { jarFile, memory, javaArgs, port, worldName } = req.body;

    try {
      const serverPath = path.join(process.cwd(), 'servers', serverId);

      // Check if server directory exists
      if (!await fs.pathExists(serverPath)) {
        return res.status(404).json({ error: 'Server directory not found' });
      }

      // Check if server is already running
      if (this.activeProcesses.has(serverId)) {
        return res.status(400).json({ error: 'Server is already running' });
      }

      // Prepare Java command
      const javaCmd = process.env.JAVA_PATH || 'java';
      const memoryArg = memory ? `-Xmx${memory} -Xms${memory}` : '-Xmx2048M -Xms2048M';
      const args = [
        memoryArg,
        '-jar',
        jarFile || 'server.jar',
        '--nogui'
      ];

      // Add additional Java arguments
      if (javaArgs) {
        args.unshift(...javaArgs.split(' '));
      }

      // Add port and world arguments if specified
      if (port) {
        args.push('--port', port.toString());
      }
      if (worldName) {
        args.push('--world', worldName);
      }

      console.log(`Starting server ${serverId} with command: ${javaCmd} ${args.join(' ')}`);

      // Spawn Java process in screen session
      const screenName = `minecraft-${serverId}`;
      const screenCmd = spawn('screen', ['-dmS', screenName, javaCmd, ...args], {
        cwd: serverPath,
        stdio: ['pipe', 'pipe', 'pipe']
      });

      // Store process reference
      this.activeProcesses.set(serverId, {
        process: screenCmd,
        screenName,
        startTime: Date.now(),
        stats: {
          cpu: 0,
          memory: 0,
          players: 0
        }
      });

      // Monitor process output
      this.monitorProcessOutput(serverId, screenName);

      // Start file watching for server files
      this.startFileWatching(serverId, serverPath);

      // Emit server started event
      this.io.to(`server-${serverId}`).emit('server-started', {
        serverId,
        timestamp: new Date().toISOString()
      });

      res.json({
        success: true,
        message: 'Server starting...',
        screenName
      });

    } catch (error) {
      console.error(`Error starting server ${serverId}:`, error);
      res.status(500).json({ error: 'Failed to start server' });
    }
  }

  async stopServer(req, res) {
    const { serverId } = req.params;

    try {
      const serverProcess = this.activeProcesses.get(serverId);

      if (!serverProcess) {
        return res.status(400).json({ error: 'Server is not running' });
      }

      // Send stop command to server
      await this.sendCommandToServer(serverId, 'stop');

      // Wait a bit for graceful shutdown
      setTimeout(() => {
        // Force kill screen session if still running
        const killCmd = spawn('screen', ['-S', serverProcess.screenName, '-X', 'quit']);
        killCmd.on('close', () => {
          this.activeProcesses.delete(serverId);
          this.stopFileWatching(serverId);

          this.io.to(`server-${serverId}`).emit('server-stopped', {
            serverId,
            timestamp: new Date().toISOString()
          });

          res.json({ success: true, message: 'Server stopped' });
        });
      }, 10000);

    } catch (error) {
      console.error(`Error stopping server ${serverId}:`, error);
      res.status(500).json({ error: 'Failed to stop server' });
    }
  }

  async restartServer(req, res) {
    const { serverId } = req.params;

    try {
      await this.stopServer(req, res);
      setTimeout(() => {
        this.startServer(req, res);
      }, 2000);
    } catch (error) {
      console.error(`Error restarting server ${serverId}:`, error);
      res.status(500).json({ error: 'Failed to restart server' });
    }
  }

  async sendCommand(req, res) {
    const { serverId } = req.params;
    const { command } = req.body;

    if (!command) {
      return res.status(400).json({ error: 'Command is required' });
    }

    try {
      await this.sendCommandToServer(serverId, command);

      res.json({
        success: true,
        message: 'Command sent',
        command
      });
    } catch (error) {
      console.error(`Error sending command to server ${serverId}:`, error);
      res.status(500).json({ error: 'Failed to send command' });
    }
  }

  async sendCommandToServer(serverId, command) {
    return new Promise((resolve, reject) => {
      const serverProcess = this.activeProcesses.get(serverId);

      if (!serverProcess) {
        reject(new Error('Server is not running'));
        return;
      }

      // Send command to screen session
      const screenCmd = spawn('screen', ['-S', serverProcess.screenName, '-X', 'stuff', `${command}\n`]);

      screenCmd.on('close', (code) => {
        if (code === 0) {
          // Emit command sent event
          this.io.to(`server-${serverId}`).emit('command-sent', {
            serverId,
            command,
            timestamp: new Date().toISOString()
          });
          resolve();
        } else {
          reject(new Error(`Screen command failed with code ${code}`));
        }
      });

      screenCmd.on('error', reject);
    });
  }

  monitorProcessOutput(serverId, screenName) {
    // Monitor screen output (this is a simplified version)
    const logCmd = spawn('screen', ['-S', screenName, '-X', 'hardcopy', '-h', '/tmp/screenlog']);

    logCmd.on('close', () => {
      // Read the log file and emit to clients
      const logPath = `/tmp/screenlog-${screenName}`;
      if (fs.existsSync(logPath)) {
        const logContent = fs.readFileSync(logPath, 'utf8');
        this.io.to(`server-${serverId}`).emit('console-output', {
          serverId,
          output: logContent,
          timestamp: new Date().toISOString()
        });
      }
    });
  }

  startStatsMonitoring() {
    setInterval(() => {
      this.activeProcesses.forEach((serverProcess, serverId) => {
        // Get CPU and memory usage (simplified)
        const uptime = Date.now() - serverProcess.startTime;

        // Emit stats update
        this.io.to(`server-${serverId}`).emit('stats-update', {
          serverId,
          stats: {
            uptime,
            cpu: Math.random() * 100, // Placeholder
            memory: Math.random() * 100, // Placeholder
            players: Math.floor(Math.random() * 20) // Placeholder
          },
          timestamp: new Date().toISOString()
        });
      });
    }, 5000); // Update every 5 seconds
  }

  getServerStats(req, res) {
    const { serverId } = req.params;
    const serverProcess = this.activeProcesses.get(serverId);

    if (!serverProcess) {
      return res.json({ running: false });
    }

    res.json({
      running: true,
      uptime: Date.now() - serverProcess.startTime,
      stats: serverProcess.stats
    });
  }

  // File management methods
  async listFiles(req, res) {
    const { serverId } = req.params;
    const filePath = req.query.path || '';

    try {
      const serverPath = path.join(process.cwd(), 'servers', serverId);
      const fullPath = path.join(serverPath, filePath);

      const items = await fs.readdir(fullPath);
      const fileList = [];

      for (const item of items) {
        const itemPath = path.join(fullPath, item);
        const stats = await fs.stat(itemPath);

        fileList.push({
          name: item,
          path: path.join(filePath, item),
          type: stats.isDirectory() ? 'directory' : 'file',
          size: stats.size,
          modified: stats.mtime,
          permissions: stats.mode.toString(8)
        });
      }

      res.json({ files: fileList });
    } catch (error) {
      console.error('Error listing files:', error);
      res.status(500).json({ error: 'Failed to list files' });
    }
  }

  async readFile(req, res) {
    const { serverId } = req.params;
    const filePath = req.params[0]; // Catch-all parameter

    try {
      const serverPath = path.join(process.cwd(), 'servers', serverId);
      const fullPath = path.join(serverPath, filePath);

      // Security check - prevent directory traversal
      const resolvedPath = path.resolve(fullPath);
      const resolvedServerPath = path.resolve(serverPath);

      if (!resolvedPath.startsWith(resolvedServerPath)) {
        return res.status(403).json({ error: 'Access denied' });
      }

      const content = await fs.readFile(fullPath, 'utf8');
      res.json({ content });
    } catch (error) {
      console.error('Error reading file:', error);
      res.status(500).json({ error: 'Failed to read file' });
    }
  }

  async writeFile(req, res) {
    const { serverId } = req.params;
    const filePath = req.params[0];
    const { content } = req.body;

    try {
      const serverPath = path.join(process.cwd(), 'servers', serverId);
      const fullPath = path.join(serverPath, filePath);

      // Security check
      const resolvedPath = path.resolve(fullPath);
      const resolvedServerPath = path.resolve(serverPath);

      if (!resolvedPath.startsWith(resolvedServerPath)) {
        return res.status(403).json({ error: 'Access denied' });
      }

      await fs.writeFile(fullPath, content, 'utf8');
      res.json({ success: true });
    } catch (error) {
      console.error('Error writing file:', error);
      res.status(500).json({ error: 'Failed to write file' });
    }
  }

  async deleteFile(req, res) {
    const { serverId } = req.params;
    const filePath = req.params[0];

    try {
      const serverPath = path.join(process.cwd(), 'servers', serverId);
      const fullPath = path.join(serverPath, filePath);

      // Security check
      const resolvedPath = path.resolve(fullPath);
      const resolvedServerPath = path.resolve(serverPath);

      if (!resolvedPath.startsWith(resolvedServerPath)) {
        return res.status(403).json({ error: 'Access denied' });
      }

      const stats = await fs.stat(fullPath);
      if (stats.isDirectory()) {
        await fs.remove(fullPath);
      } else {
        await fs.unlink(fullPath);
      }

      res.json({ success: true });
    } catch (error) {
      console.error('Error deleting file:', error);
      res.status(500).json({ error: 'Failed to delete file' });
    }
  }

  startFileWatching(serverId, serverPath) {
    const watcher = chokidar.watch(serverPath, {
      ignored: /(^|[\/\\])\../, // ignore dotfiles
      persistent: true
    });

    watcher.on('change', (filePath) => {
      this.io.to(`server-${serverId}`).emit('file-changed', {
        serverId,
        filePath: path.relative(serverPath, filePath),
        timestamp: new Date().toISOString()
      });
    });

    this.fileWatchers.set(serverId, watcher);
  }

  stopFileWatching(serverId) {
    const watcher = this.fileWatchers.get(serverId);
    if (watcher) {
      watcher.close();
      this.fileWatchers.delete(serverId);
    }
  }

  // Backup methods
  async createBackup(req, res) {
    const { serverId } = req.params;

    try {
      const serverPath = path.join(process.cwd(), 'servers', serverId);
      const backupPath = path.join(process.cwd(), 'backups', serverId);

      await fs.ensureDir(backupPath);

      const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
      const backupFile = path.join(backupPath, `backup-${timestamp}.zip`);

      // Create zip archive
      const archiver = require('archiver');
      const output = fs.createWriteStream(backupFile);
      const archive = archiver('zip', { zlib: { level: 9 } });

      output.on('close', () => {
        res.json({
          success: true,
          backupId: `backup-${timestamp}`,
          size: archive.pointer()
        });
      });

      archive.on('error', (err) => {
        throw err;
      });

      archive.pipe(output);
      archive.directory(serverPath, false);
      archive.finalize();

    } catch (error) {
      console.error('Error creating backup:', error);
      res.status(500).json({ error: 'Failed to create backup' });
    }
  }

  async listBackups(req, res) {
    const { serverId } = req.params;

    try {
      const backupPath = path.join(process.cwd(), 'backups', serverId);

      if (!await fs.pathExists(backupPath)) {
        return res.json({ backups: [] });
      }

      const files = await fs.readdir(backupPath);
      const backups = [];

      for (const file of files) {
        if (file.endsWith('.zip')) {
          const filePath = path.join(backupPath, file);
          const stats = await fs.stat(filePath);

          backups.push({
            id: file.replace('.zip', ''),
            filename: file,
            size: stats.size,
            created: stats.birthtime
          });
        }
      }

      res.json({ backups });
    } catch (error) {
      console.error('Error listing backups:', error);
      res.status(500).json({ error: 'Failed to list backups' });
    }
  }

  async restoreBackup(req, res) {
    const { serverId, backupId } = req.params;

    try {
      const backupPath = path.join(process.cwd(), 'backups', serverId, `${backupId}.zip`);
      const serverPath = path.join(process.cwd(), 'servers', serverId);

      if (!await fs.pathExists(backupPath)) {
        return res.status(404).json({ error: 'Backup not found' });
      }

      // Stop server if running
      if (this.activeProcesses.has(serverId)) {
        await this.stopServer({ params: { serverId } }, { json: () => {} });
        await new Promise(resolve => setTimeout(resolve, 5000)); // Wait for server to stop
      }

      // Clear server directory
      await fs.emptyDir(serverPath);

      // Extract backup
      const unzipper = require('unzipper');
      await fs.createReadStream(backupPath)
        .pipe(unzipper.Extract({ path: serverPath }));

      res.json({ success: true, message: 'Backup restored successfully' });

    } catch (error) {
      console.error('Error restoring backup:', error);
      res.status(500).json({ error: 'Failed to restore backup' });
    }
  }

  start(port = 8080) {
    this.server.listen(port, () => {
      console.log(`Minecraft Daemon running on port ${port}`);
      console.log(`Health check available at http://localhost:${port}/health`);
    });
  }
}

// Export for use in other modules
module.exports = MinecraftDaemon;

// Start daemon if run directly
if (require.main === module) {
  const daemon = new MinecraftDaemon();
  daemon.start(process.env.DAEMON_PORT || 8080);
}