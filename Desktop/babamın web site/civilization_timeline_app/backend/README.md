# 🚀 Civilization Timeline Backend

REST API backend with Node.js + Express + Prisma + PostgreSQL (NeonDB)

## 🎯 Features

- ✅ REST API endpoints
- ✅ PostgreSQL database (NeonDB)
- ✅ Prisma ORM
- ✅ CORS enabled
- ✅ Bulk sync endpoint
- ✅ Production ready

## 📦 Tech Stack

- **Runtime:** Node.js 18+
- **Framework:** Express.js
- **Database:** PostgreSQL (NeonDB)
- **ORM:** Prisma
- **Hosting:** Render.com

## 🔧 Local Development

### Prerequisites

- Node.js 18+
- PostgreSQL (or use NeonDB)

### Setup

```bash
# Install dependencies
npm install

# Setup environment
cp .env.example .env
# Edit .env and add your DATABASE_URL

# Generate Prisma client
npm run prisma:generate

# Push schema to database
npm run prisma:push

# Start server
npm run dev
```

Server runs on http://localhost:3000

## 🌐 API Endpoints

### Health Check
```
GET /
```

### Civilizations
```
GET    /api/civilizations      # Get all
POST   /api/civilizations      # Create
PUT    /api/civilizations/:id  # Update
DELETE /api/civilizations/:id  # Delete
```

### Events
```
GET    /api/events             # Get all
POST   /api/events             # Create
PUT    /api/events/:id         # Update
DELETE /api/events/:id         # Delete
```

### Connections
```
GET    /api/connections        # Get all
POST   /api/connections        # Create
DELETE /api/connections/:id    # Delete
```

### Sync (Bulk Operations)
```
POST   /api/sync               # Bulk upsert
```

Request body:
```json
{
  "civilizations": [...],
  "events": [...],
  "connections": [...]
}
```

## 🚀 Deployment (Render.com)

See `../RENDER_DEPLOYMENT.md` for detailed instructions.

Quick steps:

1. Push to GitHub
2. Create Web Service on Render.com
3. Set environment variables:
   - `DATABASE_URL`: Your NeonDB connection string
4. Deploy!

Build command:
```bash
npm install && npx prisma generate && npx prisma db push
```

Start command:
```bash
npm start
```

## 🗄️ Database Schema

### Civilization
- id (auto)
- name
- region
- colorValue
- description
- createdAt
- updatedAt

### Event
- id (auto)
- startYear
- endYear
- title
- description
- civilizationId (FK)
- period
- gridX, gridY
- createdAt
- updatedAt

### Connection
- id (auto)
- sourceId
- targetId
- sourceType
- targetType
- connectionType
- label
- description
- strength
- createdAt
- updatedAt

## 📝 Scripts

```bash
npm start              # Start production server
npm run dev            # Start development server (nodemon)
npm run prisma:generate # Generate Prisma client
npm run prisma:push    # Push schema to database
```

## 🔒 Environment Variables

```env
PORT=3000
DATABASE_URL=postgresql://user:password@host:5432/database?schema=public
```

## 🐛 Troubleshooting

### Database connection error
- Check DATABASE_URL format
- Verify NeonDB is accessible
- Check SSL settings

### Prisma errors
```bash
# Regenerate client
npm run prisma:generate

# Reset database (WARNING: deletes data)
npx prisma db push --force-reset
```

### Cold start on Render.com
- Free tier sleeps after 15 minutes
- First request takes ~30 seconds
- Use cron job to keep alive

## 📞 Support

- GitHub: https://github.com/kiroamsikem-hash/babaminrpojesi
- Deployment Guide: `../RENDER_DEPLOYMENT.md`

## 📄 License

MIT
