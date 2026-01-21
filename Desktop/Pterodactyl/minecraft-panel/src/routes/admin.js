const express = require('express');
const User = require('../models/User');
const Server = require('../models/Server');
const Node = require('../models/Node');
const { protect, authorize } = require('../middleware/auth');

const router = express.Router();

// @route   GET /api/admin/stats
// @desc    Get admin dashboard stats
// @access  Private (Admin only)
router.get('/stats', protect, authorize('admin'), async (req, res) => {
  try {
    const [
      totalUsers,
      totalServers,
      totalNodes,
      onlineServers,
      offlineNodes
    ] = await Promise.all([
      User.countDocuments(),
      Server.countDocuments(),
      Node.countDocuments(),
      Server.countDocuments({ status: 'running' }),
      Node.countDocuments({ status: 'offline' })
    ]);

    // Get resource usage
    const nodes = await Node.find();
    const totalMemory = nodes.reduce((sum, node) => sum + node.maxMemory, 0);
    const usedMemory = nodes.reduce((sum, node) => sum + node.usedMemory, 0);
    const totalDisk = nodes.reduce((sum, node) => sum + node.maxDisk, 0);
    const usedDisk = nodes.reduce((sum, node) => sum + node.usedDisk, 0);

    res.json({
      success: true,
      stats: {
        totalUsers,
        totalServers,
        totalNodes,
        onlineServers,
        offlineNodes,
        memoryUsage: {
          used: usedMemory,
          total: totalMemory,
          percentage: totalMemory > 0 ? Math.round((usedMemory / totalMemory) * 100) : 0
        },
        diskUsage: {
          used: usedDisk,
          total: totalDisk,
          percentage: totalDisk > 0 ? Math.round((usedDisk / totalDisk) * 100) : 0
        }
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

// @route   GET /api/admin/users
// @desc    Get all users
// @access  Private (Admin only)
router.get('/users', protect, authorize('admin'), async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const skip = (page - 1) * limit;

    const users = await User.find()
      .select('-password')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit);

    const total = await User.countDocuments();

    res.json({
      success: true,
      users,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit)
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

// @route   PUT /api/admin/users/:id
// @desc    Update user (admin)
// @access  Private (Admin only)
router.put('/users/:id', protect, authorize('admin'), async (req, res) => {
  try {
    const { username, email, role, isActive } = req.body;

    const updateData = {};
    if (username) updateData.username = username;
    if (email) updateData.email = email;
    if (role) updateData.role = role;
    if (isActive !== undefined) updateData.isActive = isActive;

    const user = await User.findByIdAndUpdate(
      req.params.id,
      updateData,
      { new: true, runValidators: true }
    ).select('-password');

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    res.json({
      success: true,
      user
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   DELETE /api/admin/users/:id
// @desc    Delete user
// @access  Private (Admin only)
router.delete('/users/:id', protect, authorize('admin'), async (req, res) => {
  try {
    const user = await User.findById(req.params.id);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    // Check if user has servers
    const serverCount = await Server.countDocuments({ owner: req.params.id });
    if (serverCount > 0) {
      return res.status(400).json({
        success: false,
        message: 'Cannot delete user with active servers'
      });
    }

    await User.findByIdAndDelete(req.params.id);

    res.json({
      success: true,
      message: 'User deleted successfully'
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   GET /api/admin/servers
// @desc    Get all servers (admin)
// @access  Private (Admin only)
router.get('/servers', protect, authorize('admin'), async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const skip = (page - 1) * limit;

    const servers = await Server.find()
      .populate('owner', 'username email')
      .populate('node', 'name host')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit);

    const total = await Server.countDocuments();

    res.json({
      success: true,
      servers,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit)
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

// @route   POST /api/admin/create-admin
// @desc    Create admin user (one-time setup)
// @access  Public (only if no admin exists)
router.post('/create-admin', async (req, res) => {
  try {
    // Check if any admin exists
    const adminExists = await User.findOne({ role: 'admin' });

    if (adminExists) {
      return res.status(400).json({
        success: false,
        message: 'Admin user already exists'
      });
    }

    const { username, email, password } = req.body;

    if (!username || !email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Please provide username, email, and password'
      });
    }

    const admin = await User.create({
      username,
      email,
      password,
      role: 'admin'
    });

    res.status(201).json({
      success: true,
      message: 'Admin user created successfully',
      admin: {
        id: admin._id,
        username: admin.username,
        email: admin.email,
        role: admin.role
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

module.exports = router;