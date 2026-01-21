const express = require('express');
const axios = require('axios');
const { protect } = require('../middleware/auth');
const Server = require('../models/Server');

const router = express.Router();

// Middleware to check server access
const checkServerAccess = async (req, res, next) => {
  try {
    const server = await Server.findById(req.params.serverId);

    if (!server) {
      return res.status(404).json({
        success: false,
        message: 'Server not found'
      });
    }

    // Check if user owns the server or is admin
    if (server.owner.toString() !== req.user._id.toString() && req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Access denied'
      });
    }

    req.server = server;
    next();
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
};

// @route   GET /api/files/:serverId
// @desc    List server files
// @access  Private
router.get('/:serverId', protect, checkServerAccess, async (req, res) => {
  try {
    const { serverId } = req.params;
    const { path: filePath = '' } = req.query;

    // Forward request to daemon
    const daemonUrl = `http://${req.server.node.host}:8080/servers/${serverId}/files?path=${encodeURIComponent(filePath)}`;

    const response = await axios.get(daemonUrl, { timeout: 10000 });

    res.json({
      success: true,
      files: response.data.files
    });
  } catch (error) {
    console.error('Error listing files:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to list files'
    });
  }
});

// @route   GET /api/files/:serverId/*
// @desc    Read file content
// @access  Private
router.get('/:serverId/*', protect, checkServerAccess, async (req, res) => {
  try {
    const { serverId } = req.params;
    const filePath = req.params[0]; // Catch-all parameter

    // Forward request to daemon
    const daemonUrl = `http://${req.server.node.host}:8080/servers/${serverId}/files/${filePath}`;

    const response = await axios.get(daemonUrl, { timeout: 10000 });

    res.json({
      success: true,
      content: response.data.content
    });
  } catch (error) {
    console.error('Error reading file:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to read file'
    });
  }
});

// @route   POST /api/files/:serverId/*
// @desc    Write file content
// @access  Private
router.post('/:serverId/*', protect, checkServerAccess, async (req, res) => {
  try {
    const { serverId } = req.params;
    const filePath = req.params[0];
    const { content } = req.body;

    if (!content) {
      return res.status(400).json({
        success: false,
        message: 'Content is required'
      });
    }

    // Forward request to daemon
    const daemonUrl = `http://${req.server.node.host}:8080/servers/${serverId}/files/${filePath}`;

    await axios.post(daemonUrl, { content }, {
      timeout: 10000,
      headers: { 'Content-Type': 'application/json' }
    });

    res.json({
      success: true,
      message: 'File saved successfully'
    });
  } catch (error) {
    console.error('Error writing file:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to save file'
    });
  }
});

// @route   DELETE /api/files/:serverId/*
// @desc    Delete file or directory
// @access  Private
router.delete('/:serverId/*', protect, checkServerAccess, async (req, res) => {
  try {
    const { serverId } = req.params;
    const filePath = req.params[0];

    // Forward request to daemon
    const daemonUrl = `http://${req.server.node.host}:8080/servers/${serverId}/files/${filePath}`;

    await axios.delete(daemonUrl, { timeout: 10000 });

    res.json({
      success: true,
      message: 'File deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting file:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete file'
    });
  }
});

// @route   POST /api/files/:serverId/upload
// @desc    Upload file to server
// @access  Private
router.post('/:serverId/upload', protect, checkServerAccess, async (req, res) => {
  try {
    const { serverId } = req.params;
    const { filePath, content, base64 } = req.body;

    if (!filePath) {
      return res.status(400).json({
        success: false,
        message: 'File path is required'
      });
    }

    let fileContent = content;
    if (base64) {
      fileContent = Buffer.from(base64, 'base64').toString('utf8');
    }

    if (!fileContent) {
      return res.status(400).json({
        success: false,
        message: 'File content is required'
      });
    }

    // Forward request to daemon
    const daemonUrl = `http://${req.server.node.host}:8080/servers/${serverId}/files/${filePath}`;

    await axios.post(daemonUrl, { content: fileContent }, {
      timeout: 30000,
      headers: { 'Content-Type': 'application/json' }
    });

    res.json({
      success: true,
      message: 'File uploaded successfully'
    });
  } catch (error) {
    console.error('Error uploading file:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to upload file'
    });
  }
});

module.exports = router;