import { PrismaClient } from '@prisma/client';
import Redis from 'ioredis';

// Setup test environment
process.env.NODE_ENV = 'test';
process.env.DATABASE_URL = 'postgresql://test:test@localhost:5432/test_db';
process.env.REDIS_URL = 'redis://localhost:6379/1';
process.env.JWT_SECRET = 'test-jwt-secret';
process.env.DATA_ENCRYPTION_KEY = 'test-encryption-key';

// Global test utilities
global.testPrisma = new PrismaClient({
  datasources: {
    db: {
      url: process.env.DATABASE_URL
    }
  }
});

global.testRedis = new Redis(process.env.REDIS_URL);

// Cleanup after each test
afterEach(async () => {
  // Clean up database
  if (global.testPrisma) {
    await global.testPrisma.$disconnect();
  }

  // Clean up Redis
  if (global.testRedis) {
    await global.testRedis.flushdb();
    global.testRedis.disconnect();
  }
});

// Cleanup after all tests
afterAll(async () => {
  if (global.testPrisma) {
    await global.testPrisma.$disconnect();
  }

  if (global.testRedis) {
    global.testRedis.disconnect();
  }
});