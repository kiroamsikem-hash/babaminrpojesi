const express = require('express');
const Server = require('../models/Server');
const Node = require('../models/Node');
const User = require('../models/User');
const { protect, ownerOrAdmin } = require('../middleware/auth');
const { spawn } = require('child_process');
const path = require('path');
const fs = require('fs-extra');

const router = express.Router();

// Middleware to check server ownership
const checkServerOwnership = async (req, res, next) => {
  try {
    const server = await Server.findById(req.params.id);
    if (!server) {
      return res.status(404).json({
        success: false,
        message: 'Server not found'
      });
    }

    req.resourceOwner = server.owner;
    req.server = server;
    next();
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
};

// @route   GET /api/servers
// @desc    Get all servers for user
// @access  Private
router.get('/', protect, async (req, res) => {
  try {
    const servers = await Server.find({
      $or: [
        { owner: req.user._id },
        { 'sharedUsers.user': req.user._id }
      ]
    }).populate('node', 'name host status');

    res.json({
      success: true,
      count: servers.length,
      servers
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   GET /api/servers/:id
// @desc    Get single server
// @access  Private
router.get('/:id', protect, checkServerOwnership, ownerOrAdmin, async (req, res) => {
  try {
    const server = await Server.findById(req.params.id)
      .populate('owner', 'username email')
      .populate('node');

    res.json({
      success: true,
      server
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   POST /api/servers
// @desc    Create new server
// @access  Private
router.post('/', protect, async (req, res) => {
  try {
    const {
      name,
      description,
      node: nodeId,
      memory,
      disk,
      version,
      gameType
    } = req.body;

    // Find available node
    const node = nodeId ? await Node.findById(nodeId) : await Node.findOne({ status: 'online' });

    if (!node) {
      return res.status(400).json({
        success: false,
        message: 'No available nodes'
      });
    }

    // Check resource availability
    const requestedMemory = parseInt(memory) || 2048;
    const requestedDisk = parseInt(disk) || 10240;

    if (!node.canHostServer(requestedMemory, requestedDisk)) {
      return res.status(400).json({
        success: false,
        message: 'Insufficient resources on selected node'
      });
    }

    // Find available port
    const usedPorts = await Server.distinct('port');
    let port = parseInt(process.env.DEFAULT_PORT_RANGE_START) || 25565;

    while (usedPorts.includes(port)) {
      port++;
      if (port > (parseInt(process.env.DEFAULT_PORT_RANGE_END) || 25665)) {
        return res.status(400).json({
          success: false,
          message: 'No available ports'
        });
      }
    }

    // Create server directory
    const serverPath = path.join(__dirname, '../../servers', req.user._id.toString(), name.replace(/[^a-zA-Z0-9]/g, '_'));
    await fs.ensureDir(serverPath);

    // Create server
    const server = await Server.create({
      name,
      description,
      owner: req.user._id,
      node: node._id,
      memory: `${requestedMemory}M`,
      disk: requestedDisk,
      version: version || process.env.DEFAULT_MINECRAFT_VERSION,
      gameType: gameType || 'minecraft',
      port
    });

    // Update node resources
    node.usedMemory += requestedMemory;
    node.usedDisk += requestedDisk;
    node.serverCount += 1;
    await node.save();

    // Add server to user
    await User.findByIdAndUpdate(req.user._id, {
      $push: { servers: server._id }
    });

    res.status(201).json({
      success: true,
      server
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   PUT /api/servers/:id/start
// @desc    Start server
// @access  Private
router.put('/:id/start', protect, checkServerOwnership, ownerOrAdmin, async (req, res) => {
  try {
    const server = req.server;

    if (server.status === 'running') {
      return res.status(400).json({
        success: false,
        message: 'Server is already running'
      });
    }

    // Update server status
    server.status = 'starting';
    await server.save();

    // Here you would implement the actual server starting logic
    // For now, we'll simulate it
    setTimeout(async () => {
      server.status = 'running';
      server.lastStarted = new Date();
      await server.save();
    }, 5000);

    res.json({
      success: true,
      message: 'Server starting...',
      server
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   PUT /api/servers/:id/stop
// @desc    Stop server
// @access  Private
router.put('/:id/stop', protect, checkServerOwnership, ownerOrAdmin, async (req, res) => {
  try {
    const server = req.server;

    if (server.status === 'stopped') {
      return res.status(400).json({
        success: false,
        message: 'Server is already stopped'
      });
    }

    // Update server status
    server.status = 'stopping';
    await server.save();

    // Here you would implement the actual server stopping logic
    setTimeout(async () => {
      server.status = 'stopped';
      await server.save();
    }, 3000);

    res.json({
      success: true,
      message: 'Server stopping...',
      server
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   PUT /api/servers/:id
// @desc    Update server settings
// @access  Private
router.put('/:id', protect, checkServerOwnership, ownerOrAdmin, async (req, res) => {
  try {
    const {
      name,
      description,
      memory,
      version,
      serverProperties
    } = req.body;

    const updateData = {};
    if (name) updateData.name = name;
    if (description !== undefined) updateData.description = description;
    if (memory) updateData.memory = memory;
    if (version) updateData.version = version;
    if (serverProperties) updateData.serverProperties = serverProperties;

    const server = await Server.findByIdAndUpdate(
      req.params.id,
      updateData,
      { new: true, runValidators: true }
    );

    res.json({
      success: true,
      server
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   DELETE /api/servers/:id
// @desc    Delete server
// @access  Private
router.delete('/:id', protect, checkServerOwnership, ownerOrAdmin, async (req, res) => {
  try {
    const server = req.server;

    if (server.status === 'running') {
      return res.status(400).json({
        success: false,
        message: 'Cannot delete running server'
      });
    }

    // Update node resources
    const node = await Node.findById(server.node);
    node.usedMemory -= parseInt(server.memory);
    node.usedDisk -= server.disk;
    node.serverCount -= 1;
    await node.save();

    // Remove from user
    await User.findByIdAndUpdate(server.owner, {
      $pull: { servers: server._id }
    });

    // Delete server directory
    const serverPath = path.join(__dirname, '../../servers', server.owner.toString(), server.name.replace(/[^a-zA-Z0-9]/g, '_'));
    await fs.remove(serverPath);

    // Delete server
    await Server.findByIdAndDelete(req.params.id);

    res.json({
      success: true,
      message: 'Server deleted successfully'
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   POST /api/servers/:id/console
// @desc    Send console command
// @access  Private
router.post('/:id/console', protect, checkServerOwnership, ownerOrAdmin, async (req, res) => {
  try {
    const { command } = req.body;

    if (!command) {
      return res.status(400).json({
        success: false,
        message: 'Command is required'
      });
    }

    // Here you would send the command to the actual Minecraft server process
    // For now, we'll just log it
    console.log(`Server ${req.params.id} command: ${command}`);

    res.json({
      success: true,
      message: 'Command sent'
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

module.exports = router;