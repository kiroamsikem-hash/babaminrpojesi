const express = require('express');
const Node = require('../models/Node');
const Server = require('../models/Server');
const { protect, authorize } = require('../middleware/auth');

const router = express.Router();

// @route   GET /api/nodes
// @desc    Get all nodes
// @access  Private (Admin only)
router.get('/', protect, authorize('admin'), async (req, res) => {
  try {
    const nodes = await Node.find().sort({ createdAt: -1 });

    res.json({
      success: true,
      count: nodes.length,
      nodes
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   GET /api/nodes/:id
// @desc    Get single node
// @access  Private (Admin only)
router.get('/:id', protect, authorize('admin'), async (req, res) => {
  try {
    const node = await Node.findById(req.params.id);

    if (!node) {
      return res.status(404).json({
        success: false,
        message: 'Node not found'
      });
    }

    // Get server count for this node
    const serverCount = await Server.countDocuments({ node: req.params.id });

    res.json({
      success: true,
      node: {
        ...node.toObject(),
        currentServerCount: serverCount
      }
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   POST /api/nodes
// @desc    Create new node
// @access  Private (Admin only)
router.post('/', protect, authorize('admin'), async (req, res) => {
  try {
    const {
      name,
      description,
      host,
      port,
      username,
      password,
      location,
      maxMemory,
      maxDisk,
      maxServers,
      portRangeStart,
      portRangeEnd
    } = req.body;

    // Validation
    if (!name || !host || !username || !password || !maxMemory || !maxDisk || !maxServers) {
      return res.status(400).json({
        success: false,
        message: 'Please provide all required fields'
      });
    }

    // Check if node name already exists
    const existingNode = await Node.findOne({ name });
    if (existingNode) {
      return res.status(400).json({
        success: false,
        message: 'Node with this name already exists'
      });
    }

    // Create node
    const node = await Node.create({
      name,
      description,
      host,
      port: port || 22,
      username,
      password,
      location,
      maxMemory: parseInt(maxMemory),
      maxDisk: parseInt(maxDisk),
      maxServers: parseInt(maxServers),
      portRange: {
        start: parseInt(portRangeStart) || 25565,
        end: parseInt(portRangeEnd) || 25665
      }
    });

    res.status(201).json({
      success: true,
      node
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   PUT /api/nodes/:id
// @desc    Update node
// @access  Private (Admin only)
router.put('/:id', protect, authorize('admin'), async (req, res) => {
  try {
    const {
      name,
      description,
      host,
      port,
      username,
      password,
      location,
      maxMemory,
      maxDisk,
      maxServers,
      status,
      portRangeStart,
      portRangeEnd
    } = req.body;

    const updateData = {};
    if (name) updateData.name = name;
    if (description !== undefined) updateData.description = description;
    if (host) updateData.host = host;
    if (port) updateData.port = port;
    if (username) updateData.username = username;
    if (password) updateData.password = password;
    if (location) updateData.location = location;
    if (maxMemory) updateData.maxMemory = parseInt(maxMemory);
    if (maxDisk) updateData.maxDisk = parseInt(maxDisk);
    if (maxServers) updateData.maxServers = parseInt(maxServers);
    if (status) updateData.status = status;

    if (portRangeStart || portRangeEnd) {
      updateData.portRange = {
        start: parseInt(portRangeStart) || updateData.portRange?.start,
        end: parseInt(portRangeEnd) || updateData.portRange?.end
      };
    }

    const node = await Node.findByIdAndUpdate(
      req.params.id,
      updateData,
      { new: true, runValidators: true }
    );

    if (!node) {
      return res.status(404).json({
        success: false,
        message: 'Node not found'
      });
    }

    res.json({
      success: true,
      node
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   DELETE /api/nodes/:id
// @desc    Delete node
// @access  Private (Admin only)
router.delete('/:id', protect, authorize('admin'), async (req, res) => {
  try {
    const node = await Node.findById(req.params.id);

    if (!node) {
      return res.status(404).json({
        success: false,
        message: 'Node not found'
      });
    }

    // Check if node has servers
    const serverCount = await Server.countDocuments({ node: req.params.id });
    if (serverCount > 0) {
      return res.status(400).json({
        success: false,
        message: 'Cannot delete node with active servers'
      });
    }

    await Node.findByIdAndDelete(req.params.id);

    res.json({
      success: true,
      message: 'Node deleted successfully'
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   GET /api/nodes/:id/ping
// @desc    Ping node to check connectivity
// @access  Private (Admin only)
router.get('/:id/ping', protect, authorize('admin'), async (req, res) => {
  try {
    const node = await Node.findById(req.params.id);

    if (!node) {
      return res.status(404).json({
        success: false,
        message: 'Node not found'
      });
    }

    // Here you would implement actual node pinging logic
    // For now, we'll simulate it
    const isOnline = Math.random() > 0.2; // 80% chance of being online

    node.status = isOnline ? 'online' : 'offline';
    node.lastPing = new Date();
    await node.save();

    res.json({
      success: true,
      online: isOnline,
      node
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   GET /api/nodes/:id/servers
// @desc    Get servers on node
// @access  Private (Admin only)
router.get('/:id/servers', protect, authorize('admin'), async (req, res) => {
  try {
    const servers = await Server.find({ node: req.params.id })
      .populate('owner', 'username email')
      .sort({ createdAt: -1 });

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

module.exports = router;