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

// @route   POST /api/backups/:serverId
// @desc    Create server backup
// @access  Private
router.post('/:serverId', protect, checkServerAccess, async (req, res) => {
  try {
    const { serverId } = req.params;

    // Forward request to daemon
    const daemonUrl = `http://${req.server.node.host}:8080/servers/${serverId}/backup`;

    const response = await axios.post(daemonUrl, {}, { timeout: 300000 }); // 5 minutes timeout

    res.json({
      success: true,
      backup: response.data,
      message: 'Backup created successfully'
    });
  } catch (error) {
    console.error('Error creating backup:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create backup'
    });
  }
});

// @route   GET /api/backups/:serverId
// @desc    List server backups
// @access  Private
router.get('/:serverId', protect, checkServerAccess, async (req, res) => {
  try {
    const { serverId } = req.params;

    // Forward request to daemon
    const daemonUrl = `http://${req.server.node.host}:8080/servers/${serverId}/backups`;

    const response = await axios.get(daemonUrl, { timeout: 10000 });

    res.json({
      success: true,
      backups: response.data.backups
    });
  } catch (error) {
    console.error('Error listing backups:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to list backups'
    });
  }
});

// @route   POST /api/backups/:serverId/:backupId/restore
// @desc    Restore server backup
// @access  Private
router.post('/:serverId/:backupId/restore', protect, checkServerAccess, async (req, res) => {
  try {
    const { serverId, backupId } = req.params;

    // Forward request to daemon
    const daemonUrl = `http://${req.server.node.host}:8080/servers/${serverId}/backups/${backupId}/restore`;

    const response = await axios.post(daemonUrl, {}, { timeout: 300000 }); // 5 minutes timeout

    res.json({
      success: true,
      message: response.data.message || 'Backup restored successfully'
    });
  } catch (error) {
    console.error('Error restoring backup:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to restore backup'
    });
  }
});

// @route   DELETE /api/backups/:serverId/:backupId
// @desc    Delete server backup
// @access  Private
router.delete('/:serverId/:backupId', protect, checkServerAccess, async (req, res) => {
  try {
    const { serverId, backupId } = req.params;

    // Forward request to daemon
    const daemonUrl = `http://${req.server.node.host}:8080/servers/${serverId}/backups/${backupId}`;

    await axios.delete(daemonUrl, { timeout: 10000 });

    res.json({
      success: true,
      message: 'Backup deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting backup:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete backup'
    });
  }
});

// @route   GET /api/backups/:serverId/:backupId/download
// @desc    Download server backup
// @access  Private
router.get('/:serverId/:backupId/download', protect, checkServerAccess, async (req, res) => {
  try {
    const { serverId, backupId } = req.params;

    // Forward request to daemon
    const daemonUrl = `http://${req.server.node.host}:8080/servers/${serverId}/backups/${backupId}/download`;

    const response = await axios.get(daemonUrl, {
      timeout: 300000,
      responseType: 'stream'
    });

    // Set headers for file download
    res.setHeader('Content-Disposition', `attachment; filename="${backupId}.zip"`);
    res.setHeader('Content-Type', 'application/zip');

    // Pipe the response stream to the client
    response.data.pipe(res);

  } catch (error) {
    console.error('Error downloading backup:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to download backup'
    });
  }
});

module.exports = router;