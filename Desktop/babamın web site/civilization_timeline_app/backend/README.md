# 🚀 Civilization Timeline Backend API

REST API backend for Civilization Timeline App - Alternative to Firebase.

## 🎯 Features

- ✅ RESTful API
- ✅ MongoDB database
- ✅ CORS enabled
- ✅ Bulk sync endpoint
- ✅ Ready for Render.com deployment

## 📦 Installation

```bash
cd backend
npm install
```

## 🔧 Configuration

Create `.env` file:

```env
PORT=3000
MONGODB_URI=mongodb://localhost:27017/civilization_timeline
```

## 🚀 Run Locally

```bash
# Development
npm run dev

# Production
npm start
```

## 📡 API Endpoints

### Civilizations

- `GET /api/civilizations` - Get all civilizations
- `POST /api/civilizations` - Create civilization
- `PUT /api/civilizations/:id` - Update civilization
- `DELETE /api/civilizations/:id` - Delete civilization

### Events

- `GET /api/events` - Get all events
- `POST /api/events` - Create event
- `PUT /api/events/:id` - Update event
- `DELETE /api/events/:id` - Delete event

### Connections

- `GET /api/connections` - Get all connections
- `POST /api/connections` - Create connection
- `DELETE /api/connections/:id` - Delete connection

### Sync

- `POST /api/sync` - Bulk sync (upsert multiple items)

## 🌐 Deploy to Render.com

### 1. Create MongoDB Atlas Database

1. Go to [MongoDB Atlas](https://www.mongodb.com/cloud/atlas)
2. Create free cluster
3. Get connection string
4. Whitelist all IPs (0.0.0.0/0)

### 2. Deploy to Render

1. Go to [Render.com](https://render.com)
2. New > Web Service
3. Connect GitHub repo: `kiroamsikem-hash/babaminrpojesi`
4. Settings:
   - **Name**: civilization-timeline-api
   - **Root Directory**: `civilization_timeline_app/backend`
   - **Environment**: Node
   - **Build Command**: `npm install`
   - **Start Command**: `npm start`
   - **Plan**: Free

5. Environment Variables:
   - `MONGODB_URI`: Your MongoDB Atlas connection string
   - `PORT`: 3000 (optional, Render provides this)

6. Click "Create Web Service"

### 3. Get API URL

After deployment, you'll get a URL like:
```
https://civilization-timeline-api.onrender.com
```

## 📱 Flutter Integration

Update Flutter app to use REST API instead of Firebase:

```dart
// lib/core/api/api_service.dart
class ApiService {
  static const String baseUrl = 'https://civilization-timeline-api.onrender.com/api';
  
  Future<List<Event>> getEvents() async {
    final response = await http.get(Uri.parse('$baseUrl/events'));
    // Parse and return
  }
  
  Future<void> saveEvent(Event event) async {
    await http.post(
      Uri.parse('$baseUrl/events'),
      body: jsonEncode(event.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
  }
}
```

## 🔄 Sync Strategy

### Option 1: REST API Only

Replace Firebase with REST API:
- Remove Firebase dependencies
- Use HTTP requests
- Implement polling for updates

### Option 2: Hybrid (Firebase + REST API)

Use both:
- Firebase for real-time sync
- REST API as backup/alternative
- Switch based on availability

### Option 3: REST API + WebSocket

Add real-time updates:
- Install `socket.io`
- Emit events on changes
- Flutter listens to WebSocket

## 💰 Cost

### Render.com Free Tier
- ✅ 750 hours/month
- ✅ Automatic deploys
- ⚠️ Spins down after 15 min inactivity
- ⚠️ Cold start ~30 seconds

### MongoDB Atlas Free Tier
- ✅ 512MB storage
- ✅ Shared cluster
- ✅ Enough for single user

## 🔧 Troubleshooting

### "Cannot connect to MongoDB"

- Check MongoDB Atlas IP whitelist
- Verify connection string
- Check network access

### "API not responding"

- Render free tier spins down
- First request takes ~30 seconds
- Consider paid tier for always-on

### "CORS error"

- CORS is enabled by default
- Check if origin is allowed
- Add specific origins if needed

## 📊 Monitoring

Render Dashboard shows:
- Deployment logs
- Request metrics
- Error logs
- Resource usage

## 🎉 Done!

Your backend is now deployed and ready to use!

API URL: `https://civilization-timeline-api.onrender.com`
