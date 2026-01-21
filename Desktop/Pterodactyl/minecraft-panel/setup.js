// Setup script for creating initial admin user
const mongoose = require('mongoose');
const User = require('./src/models/User');
require('dotenv').config({ path: './config.env' });

async function setup() {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost/minecraft-panel');
    console.log('Connected to MongoDB');

    // Check if admin user already exists
    const existingAdmin = await User.findOne({ role: 'admin' });
    if (existingAdmin) {
      console.log('Admin user already exists:', existingAdmin.username);
      process.exit(0);
    }

    // Create admin user
    const adminData = {
      username: process.env.ADMIN_USERNAME || 'admin',
      email: process.env.ADMIN_EMAIL || 'admin@localhost',
      password: process.env.ADMIN_PASSWORD || 'changeme123',
      role: 'admin'
    };

    const admin = await User.create(adminData);
    console.log('Admin user created successfully!');
    console.log('Username:', admin.username);
    console.log('Email:', admin.email);
    console.log('Password:', adminData.password);
    console.log('\n⚠️  IMPORTANT: Change the default password immediately!');

    process.exit(0);
  } catch (error) {
    console.error('Setup failed:', error);
    process.exit(1);
  }
}

setup();