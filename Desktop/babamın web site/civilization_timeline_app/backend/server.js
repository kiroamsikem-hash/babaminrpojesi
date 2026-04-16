const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));

// MongoDB Connection
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/civilization_timeline';

mongoose.connect(MONGODB_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
.then(() => console.log('✅ MongoDB connected'))
.catch(err => console.error('❌ MongoDB connection error:', err));

// Models
const CivilizationSchema = new mongoose.Schema({
  name: { type: String, required: true },
  region: { type: String, required: true },
  colorValue: { type: Number, required: true },
  description: String,
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
});

const EventSchema = new mongoose.Schema({
  startYear: { type: Number, required: true },
  endYear: Number,
  title: { type: String, required: true },
  description: String,
  civilizationId: { type: mongoose.Schema.Types.ObjectId, ref: 'Civilization' },
  period: String,
  gridX: Number,
  gridY: Number,
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
});

const ConnectionSchema = new mongoose.Schema({
  sourceId: { type: mongoose.Schema.Types.ObjectId, required: true },
  targetId: { type: mongoose.Schema.Types.ObjectId, required: true },
  sourceType: { type: String, required: true },
  targetType: { type: String, required: true },
  connectionType: { type: String, required: true },
  label: String,
  description: String,
  strength: Number,
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
});

const Civilization = mongoose.model('Civilization', CivilizationSchema);
const Event = mongoose.model('Event', EventSchema);
const Connection = mongoose.model('Connection', ConnectionSchema);

// Routes

// Health check
app.get('/', (req, res) => {
  res.json({ 
    status: 'ok', 
    message: 'Civilization Timeline API',
    version: '1.0.0'
  });
});

// Civilizations
app.get('/api/civilizations', async (req, res) => {
  try {
    const civilizations = await Civilization.find().sort({ name: 1 });
    res.json(civilizations);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/civilizations', async (req, res) => {
  try {
    const civilization = new Civilization(req.body);
    await civilization.save();
    res.status(201).json(civilization);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

app.put('/api/civilizations/:id', async (req, res) => {
  try {
    const civilization = await Civilization.findByIdAndUpdate(
      req.params.id,
      { ...req.body, updatedAt: Date.now() },
      { new: true }
    );
    res.json(civilization);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

app.delete('/api/civilizations/:id', async (req, res) => {
  try {
    await Civilization.findByIdAndDelete(req.params.id);
    res.json({ message: 'Civilization deleted' });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// Events
app.get('/api/events', async (req, res) => {
  try {
    const events = await Event.find()
      .populate('civilizationId')
      .sort({ startYear: 1 });
    res.json(events);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/events', async (req, res) => {
  try {
    const event = new Event(req.body);
    await event.save();
    res.status(201).json(event);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

app.put('/api/events/:id', async (req, res) => {
  try {
    const event = await Event.findByIdAndUpdate(
      req.params.id,
      { ...req.body, updatedAt: Date.now() },
      { new: true }
    );
    res.json(event);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

app.delete('/api/events/:id', async (req, res) => {
  try {
    await Event.findByIdAndDelete(req.params.id);
    res.json({ message: 'Event deleted' });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// Connections
app.get('/api/connections', async (req, res) => {
  try {
    const connections = await Connection.find();
    res.json(connections);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/connections', async (req, res) => {
  try {
    const connection = new Connection(req.body);
    await connection.save();
    res.status(201).json(connection);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

app.delete('/api/connections/:id', async (req, res) => {
  try {
    await Connection.findByIdAndDelete(req.params.id);
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
        await Civilization.findOneAndUpdate(
          { _id: civ._id },
          civ,
          { upsert: true, new: true }
        );
        results.civilizations++;
      }
    }

    if (events) {
      for (const event of events) {
        await Event.findOneAndUpdate(
          { _id: event._id },
          event,
          { upsert: true, new: true }
        );
        results.events++;
      }
    }

    if (connections) {
      for (const conn of connections) {
        await Connection.findOneAndUpdate(
          { _id: conn._id },
          conn,
          { upsert: true, new: true }
        );
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

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`📡 API: http://localhost:${PORT}/api`);
});
