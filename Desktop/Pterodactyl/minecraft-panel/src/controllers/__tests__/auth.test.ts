import request from 'supertest';
import { FastifyInstance } from 'fastify';
import { createTestApp } from '../../tests/test-app';

describe('Authentication Routes', () => {
  let app: FastifyInstance;

  beforeAll(async () => {
    app = await createTestApp();
  });

  afterAll(async () => {
    await app.close();
  });

  describe('POST /api/auth/register', () => {
    it('should register a new user successfully', async () => {
      const response = await request(app.server)
        .post('/api/auth/register')
        .send({
          username: 'testuser',
          email: 'test@example.com',
          password: 'password123'
        })
        .expect(201);

      expect(response.body.success).toBe(true);
      expect(response.body.user).toHaveProperty('id');
      expect(response.body.user.username).toBe('testuser');
      expect(response.body.user.email).toBe('test@example.com');
      expect(response.body.token).toBeDefined();
    });

    it('should return error for duplicate username', async () => {
      // First register a user
      await request(app.server)
        .post('/api/auth/register')
        .send({
          username: 'duplicateuser',
          email: 'duplicate@example.com',
          password: 'password123'
        });

      // Try to register again with same username
      const response = await request(app.server)
        .post('/api/auth/register')
        .send({
          username: 'duplicateuser',
          email: 'another@example.com',
          password: 'password123'
        })
        .expect(400);

      expect(response.body.error).toContain('already exists');
    });

    it('should validate required fields', async () => {
      const response = await request(app.server)
        .post('/api/auth/register')
        .send({
          username: 'testuser2'
          // Missing email and password
        })
        .expect(400);

      expect(response.body.error).toBeDefined();
    });
  });

  describe('POST /api/auth/login', () => {
    beforeAll(async () => {
      // Create a test user for login tests
      await request(app.server)
        .post('/api/auth/register')
        .send({
          username: 'logintest',
          email: 'login@example.com',
          password: 'password123'
        });
    });

    it('should login successfully with correct credentials', async () => {
      const response = await request(app.server)
        .post('/api/auth/login')
        .send({
          username: 'logintest',
          password: 'password123'
        })
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.user).toHaveProperty('id');
      expect(response.body.token).toBeDefined();
    });

    it('should return error for invalid credentials', async () => {
      const response = await request(app.server)
        .post('/api/auth/login')
        .send({
          username: 'logintest',
          password: 'wrongpassword'
        })
        .expect(401);

      expect(response.body.error).toBe('Invalid credentials');
    });

    it('should return error for non-existent user', async () => {
      const response = await request(app.server)
        .post('/api/auth/login')
        .send({
          username: 'nonexistent',
          password: 'password123'
        })
        .expect(401);

      expect(response.body.error).toBe('Invalid credentials');
    });
  });

  describe('Protected routes', () => {
    let token: string;

    beforeAll(async () => {
      // Create and login a test user
      const registerResponse = await request(app.server)
        .post('/api/auth/register')
        .send({
          username: 'protectedtest',
          email: 'protected@example.com',
          password: 'password123'
        });

      token = registerResponse.body.token;
    });

    it('should allow access with valid token', async () => {
      const response = await request(app.server)
        .get('/api/user/profile')
        .set('Authorization', `Bearer ${token}`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.user.username).toBe('protectedtest');
    });

    it('should deny access without token', async () => {
      const response = await request(app.server)
        .get('/api/user/profile')
        .expect(401);

      expect(response.body.error).toBe('No token provided');
    });

    it('should deny access with invalid token', async () => {
      const response = await request(app.server)
        .get('/api/user/profile')
        .set('Authorization', 'Bearer invalid-token')
        .expect(401);

      expect(response.body.error).toBe('Invalid token');
    });
  });
});