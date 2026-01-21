import Fastify from 'fastify';
import { FastifyInstance } from 'fastify';
import { PrismaClient } from '@prisma/client';
import Redis from 'ioredis';

// Test application factory
export async function createTestApp(): Promise<FastifyInstance> {
  const app = Fastify({
    logger: false, // Disable logging in tests
  });

  // Setup test database connections
  const prisma = new PrismaClient({
    datasources: {
      db: {
        url: process.env.DATABASE_URL || 'postgresql://test:test@localhost:5432/test_db'
      }
    }
  });

  const redis = new Redis(process.env.REDIS_URL || 'redis://localhost:6379/1');

  // Register test globals
  (global as any).prisma = prisma;
  (global as any).redis = redis;

  // Register plugins
  await app.register(require('@fastify/cors'));
  await app.register(require('@fastify/helmet'));
  await app.register(require('@fastify/rate-limit'), {
    max: 1000, // Higher limit for tests
    timeWindow: '1 minute'
  });

  // Register routes (import your actual routes here)
  // app.register(require('../controllers/auth'));

  // Health check for tests
  app.get('/health', async () => {
    return { status: 'ok', environment: 'test' };
  });

  // Mock auth middleware for tests
  app.decorate('authenticate', async (request: any, reply: any) => {
    // Mock authentication for tests
    request.user = {
      id: 'test-user-id',
      username: 'testuser',
      email: 'test@example.com',
      role: 'USER'
    };
  });

  // Apply auth to protected routes
  app.addHook('preHandler', app.authenticate);

  await app.ready();

  return app;
}

// Cleanup helper
export async function cleanupTestData(): Promise<void> {
  if ((global as any).prisma) {
    // Clean up test data
    await (global as any).prisma.user.deleteMany();
    await (global as any).prisma.server.deleteMany();
    // Add other cleanup as needed
  }

  if ((global as any).redis) {
    await (global as any).redis.flushdb();
  }
}