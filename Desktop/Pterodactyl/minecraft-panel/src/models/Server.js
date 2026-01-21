const mongoose = require('mongoose');

const serverSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true,
    maxlength: 50
  },
  description: {
    type: String,
    maxlength: 500
  },
  owner: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  node: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Node',
    required: true
  },
  gameType: {
    type: String,
    enum: ['minecraft', 'minecraft-bedrock'],
    default: 'minecraft'
  },
  version: {
    type: String,
    default: '1.20.1'
  },
  status: {
    type: String,
    enum: ['stopped', 'starting', 'running', 'stopping', 'error'],
    default: 'stopped'
  },
  port: {
    type: Number,
    required: true,
    unique: true
  },
  memory: {
    type: String,
    default: '2048M'
  },
  cpu: {
    type: Number,
    default: 100, // percentage
    min: 1,
    max: 100
  },
  disk: {
    type: Number,
    default: 10240 // MB
  },
  jarFile: {
    type: String,
    default: 'server.jar'
  },
  javaArgs: {
    type: String,
    default: ''
  },
  serverProperties: {
    type: mongoose.Schema.Types.Mixed,
    default: {}
  },
  plugins: [{
    name: String,
    version: String,
    file: String,
    enabled: {
      type: Boolean,
      default: true
    }
  }],
  mods: [{
    name: String,
    version: String,
    file: String,
    enabled: {
      type: Boolean,
      default: true
    }
  }],
  players: {
    online: {
      type: Number,
      default: 0
    },
    max: {
      type: Number,
      default: 20
    },
    list: [{
      name: String,
      uuid: String,
      joinedAt: Date
    }]
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  lastStarted: {
    type: Date
  },
  uptime: {
    type: Number,
    default: 0 // seconds
  },
  stats: {
    cpuUsage: {
      type: Number,
      default: 0
    },
    memoryUsage: {
      type: Number,
      default: 0
    },
    networkIn: {
      type: Number,
      default: 0
    },
    networkOut: {
      type: Number,
      default: 0
    }
  }
});

// Index for faster queries
serverSchema.index({ owner: 1 });
serverSchema.index({ node: 1 });
serverSchema.index({ status: 1 });

module.exports = mongoose.model('Server', serverSchema);