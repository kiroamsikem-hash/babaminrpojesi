const mongoose = require('mongoose');

const nodeSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    unique: true,
    trim: true,
    maxlength: 50
  },
  description: {
    type: String,
    maxlength: 500
  },
  host: {
    type: String,
    required: true
  },
  port: {
    type: Number,
    default: 22
  },
  username: {
    type: String,
    required: true
  },
  password: {
    type: String,
    required: true
  },
  sshKey: {
    type: String // Optional SSH key instead of password
  },
  status: {
    type: String,
    enum: ['online', 'offline', 'maintenance'],
    default: 'offline'
  },
  location: {
    type: String,
    trim: true
  },
  // Resource limits
  maxMemory: {
    type: Number, // MB
    required: true
  },
  maxDisk: {
    type: Number, // MB
    required: true
  },
  maxServers: {
    type: Number,
    required: true
  },
  // Current usage
  usedMemory: {
    type: Number,
    default: 0
  },
  usedDisk: {
    type: Number,
    default: 0
  },
  serverCount: {
    type: Number,
    default: 0
  },
  // System info
  systemInfo: {
    os: String,
    cpu: String,
    memory: Number,
    disk: Number,
    uptime: Number
  },
  // Port range for servers
  portRange: {
    start: {
      type: Number,
      required: true
    },
    end: {
      type: Number,
      required: true
    }
  },
  // Minecraft specific settings
  javaVersions: [{
    version: String,
    path: String,
    default: Boolean
  }],
  minecraftVersions: [{
    version: String,
    url: String,
    type: {
      type: String,
      enum: ['vanilla', 'paper', 'spigot', 'bukkit', 'forge', 'fabric'],
      default: 'vanilla'
    }
  }],
  createdAt: {
    type: Date,
    default: Date.now
  },
  lastPing: {
    type: Date,
    default: Date.now
  }
});

// Index for faster queries
nodeSchema.index({ status: 1 });
nodeSchema.index({ host: 1 });

// Virtual for available memory
nodeSchema.virtual('availableMemory').get(function() {
  return this.maxMemory - this.usedMemory;
});

// Virtual for available disk
nodeSchema.virtual('availableDisk').get(function() {
  return this.maxDisk - this.usedDisk;
});

// Virtual for available server slots
nodeSchema.virtual('availableServers').get(function() {
  return this.maxServers - this.serverCount;
});

// Check if node can host a server with given requirements
nodeSchema.methods.canHostServer = function(memory, disk) {
  return this.availableMemory >= memory && this.availableDisk >= disk && this.availableServers > 0;
};

module.exports = mongoose.model('Node', nodeSchema);