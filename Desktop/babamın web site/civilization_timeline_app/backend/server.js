const express = require('express');
const cors = require('cors');
const { PrismaClient } = require('@prisma/client');
require('dotenv').config();

const app = express();
const prisma = new PrismaClient();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));

// Health check
app.get('/', (req, res) => {
  res.json({ 
    status: 'ok', 
    message: 'Civilization Timeline API (PostgreSQL + NeonDB)',
    version: '1.0.0'
  });
});

// Civilizations
app.get('/api/civilizations', async (req, res) => {
  try {
    const civilizations = await prisma.civilization.findMany({
      orderBy: { name: 'asc' }
    });
    res.json(civilizations);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/civilizations', async (req, res) => {
  try {
    const civilization = await prisma.civilization.create({
      data: req.body
    });
    res.status(201).json(civilization);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

app.put('/api/civilizations/:id', async (req, res) => {
  try {
    const civilization = await prisma.civilization.update({
      where: { id: parseInt(req.params.id) },
      data: req.body
    });
    res.json(civilization);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

app.delete('/api/civilizations/:id', async (req, res) => {
  try {
    await prisma.civilization.delete({
      where: { id: parseInt(req.params.id) }
    });
    res.json({ message: 'Civilization deleted' });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// Events
app.get('/api/events', async (req, res) => {
  try {
    const events = await prisma.event.findMany({
      include: { civilization: true },
      orderBy: { startYear: 'asc' }
    });
    res.json(events);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/events', async (req, res) => {
  try {
    const event = await prisma.event.create({
      data: req.body
    });
    res.status(201).json(event);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

app.put('/api/events/:id', async (req, res) => {
  try {
    const event = await prisma.event.update({
      where: { id: parseInt(req.params.id) },
      data: req.body
    });
    res.json(event);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

app.delete('/api/events/:id', async (req, res) => {
  try {
    await prisma.event.delete({
      where: { id: parseInt(req.params.id) }
    });
    res.json({ message: 'Event deleted' });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// Connections
app.get('/api/connections', async (req, res) => {
  try {
    const connections = await prisma.connection.findMany();
    res.json(connections);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/connections', async (req, res) => {
  try {
    const connection = await prisma.connection.create({
      data: req.body
    });
    res.status(201).json(connection);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

app.delete('/api/connections/:id', async (req, res) => {
  try {
    await prisma.connection.delete({
      where: { id: parseInt(req.params.id) }
    });
    res.json({ message: 'Connection deleted' });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// Sync endpoint (bulk operations)
app.post('/api/sync', async (req, res) => {
  try {
    const { civilizations, events, connections } = req.body;
    
    const results = {
      civilizations: 0,
      events: 0,
      connections: 0
    };

    if (civilizations) {
      for (const civ of civilizations) {
        await prisma.civilization.upsert({
          where: { id: civ.id || 0 },
          update: civ,
          create: civ
        });
        results.civilizations++;
      }
    }

    if (events) {
      for (const event of events) {
        await prisma.event.upsert({
          where: { id: event.id || 0 },
          update: event,
          create: event
        });
        results.events++;
      }
    }

    if (connections) {
      for (const conn of connections) {
        await prisma.connection.upsert({
          where: { id: conn.id || 0 },
          update: conn,
          create: conn
        });
        results.connections++;
      }
    }

    res.json({ message: 'Sync completed', results });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Error handling
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something went wrong!' });
});

// Graceful shutdown
process.on('SIGINT', async () => {
  await prisma.$disconnect();
  process.exit(0);
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`📡 API: http://localhost:${PORT}/api`);
  console.log(`🐘 PostgreSQL (NeonDB) connected`);
});
