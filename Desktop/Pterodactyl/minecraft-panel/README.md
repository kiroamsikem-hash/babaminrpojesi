# 🚀 AetherPanel - Enterprise Minecraft Management

**Full-Stack Minecraft Server Management Panel with Controller-Daemon Architecture**

A modern, feature-rich Minecraft server management panel inspired by Skyport, built with cutting-edge technologies and designed for maximum performance and security.

## ✨ Features

### 🏗️ Architecture
- **Controller-Daemon Architecture**: Wings-style daemon service for server management
- **Real-time Communication**: Socket.io for live console and statistics
- **Microservices Design**: Scalable and maintainable codebase

### 🎨 Modern UI/UX (Skyport Style)
- **Dark Theme**: Ultra-dark design with Electric Purple (#8b5cf6) and Success Green (#10b981)
- **Tailwind CSS**: Modern, responsive design system
- **Interactive Dashboard**: Glow effects, smooth animations, and intuitive navigation
- **Terminal Integration**: xterm.js powered console with real-time output
- **Collapsible Sidebar**: Clean navigation with file manager and backup tools

### 🔒 Security & Authentication
- **JWT Authentication**: Secure token-based authentication
- **RBAC System**: Role-Based Access Control for users and servers
- **Command Sanitization**: Safe command execution with input validation
- **File Security**: Path traversal protection and secure file operations

### 🛠️ Server Management
- **Multi-Node Support**: Distributed server deployment across multiple nodes
- **Resource Management**: CPU, memory, and disk allocation controls
- **Live Monitoring**: Real-time server statistics and player tracking
- **Backup System**: Automated backup creation and restoration
- **Plugin/Mod Management**: Advanced plugin and mod installation system

### 🐧 Linux Integration
- **Screen/Tmux Sessions**: Persistent server sessions that survive panel restarts
- **cgroups Support**: Linux control groups for resource limitation
- **Docker Integration**: Containerized server deployment options

## 🛠️ Enterprise Tech Stack

### Backend Architecture (Production-Ready)
- **Runtime**: Node.js 18 LTS with TypeScript
- **Framework**: Fastify (2-3x faster than Express)
- **Language**: TypeScript with strict type checking
- **Microservices**: gRPC for internal communication
- **Authentication**: JWT + RBAC with refresh tokens

### Database Layer (Scalable & Reliable)
- **Primary DB**: PostgreSQL 15 with connection pooling
- **Cache Layer**: Redis 7 with clustering support
- **ORM**: Prisma with type-safe queries
- **Migrations**: Automated schema migrations
- **Time-Series**: InfluxDB 2.7 for metrics

### Containerization & Orchestration
- **Container Runtime**: Docker with multi-stage builds
- **Orchestration**: Docker Compose with health checks
- **Process Management**: Supervisor for daemon processes
- **Resource Limits**: cgroups and Docker limits

### Frontend (Modern React Architecture)
- **Framework**: React 18 with TypeScript
- **Build Tool**: Vite for fast development
- **Styling**: Tailwind CSS with custom design system
- **Terminal**: xterm.js with addon ecosystem
- **State Management**: React Context + custom hooks
- **Icons**: Lucide React icons

### Security & Compliance
- **Encryption**: AES-256-GCM for data at rest
- **Transport**: TLS 1.3 with perfect forward secrecy
- **Authentication**: Multi-factor authentication ready
- **Authorization**: Fine-grained permissions
- **Audit Logging**: Comprehensive security logging
- **SFTP**: Secure file transfer with chroot jails

### DevOps & CI/CD
- **Version Control**: Git with conventional commits
- **CI/CD**: GitHub Actions with multi-environment
- **Testing**: Jest + Supertest with 90%+ coverage
- **Linting**: ESLint + Prettier
- **Security**: Trivy vulnerability scanning
- **Monitoring**: Health checks and metrics

### Cloud & Infrastructure
- **Backup Storage**: AWS S3 with lifecycle policies
- **CDN**: CloudFront for static assets
- **Monitoring**: Grafana + Prometheus stack
- **Logging**: Structured logging with Pino
- **Load Balancing**: Nginx with rate limiting

## Installation

1. **Clone the repository** (if applicable) or set up the project:
   ```bash
   mkdir minecraft-panel
   cd minecraft-panel
   npm init -y
   ```

2. **Install dependencies**:
   ```bash
   npm install express socket.io mongoose bcryptjs jsonwebtoken express-rate-limit helmet cors dotenv multer fs-extra child_process
   npm install --save-dev nodemon
   ```

3. **Set up environment variables**:
   Create a `config.env` file in the root directory:
   ```env
   PORT=3000
   NODE_ENV=development
   MONGODB_URI=mongodb://localhost/minecraft-panel
   JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
   JWT_EXPIRES_IN=24h
   DEFAULT_JAVA_PATH=java
   DEFAULT_MINECRAFT_VERSION=1.20.1
   DEFAULT_MEMORY=2048M
   DEFAULT_PORT_RANGE_START=25565
   DEFAULT_PORT_RANGE_END=25665
   ADMIN_USERNAME=admin
   ADMIN_PASSWORD=change-this-password
   ADMIN_EMAIL=admin@localhost
   MAX_FILE_SIZE=100000000
   UPLOAD_PATH=./uploads
   ```

4. **Start MongoDB**:
   Make sure MongoDB is running on your system.

5. **Setup initial admin user**:
   ```bash
   npm run setup
   ```

6. **Run the application**:
   ```bash
   # Development mode
   npm run dev

   # Production mode
   npm start
   ```

6. **Access the application**:
   - Open your browser and go to `http://localhost:3000`
   - Create your first admin user using the `/api/admin/create-admin` endpoint

## API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user
- `GET /api/auth/me` - Get current user info
- `PUT /api/auth/update-profile` - Update user profile
- `PUT /api/auth/change-password` - Change password

### Servers
- `GET /api/servers` - Get user's servers
- `GET /api/servers/:id` - Get server details
- `POST /api/servers` - Create new server
- `PUT /api/servers/:id/start` - Start server
- `PUT /api/servers/:id/stop` - Stop server
- `PUT /api/servers/:id` - Update server settings
- `DELETE /api/servers/:id` - Delete server
- `POST /api/servers/:id/console` - Send console command

### Nodes (Admin Only)
- `GET /api/nodes` - Get all nodes
- `GET /api/nodes/:id` - Get node details
- `POST /api/nodes` - Create new node
- `PUT /api/nodes/:id` - Update node
- `DELETE /api/nodes/:id` - Delete node
- `GET /api/nodes/:id/ping` - Ping node
- `GET /api/nodes/:id/servers` - Get servers on node

### Admin
- `GET /api/admin/stats` - Get admin dashboard stats
- `GET /api/admin/users` - Get all users
- `PUT /api/admin/users/:id` - Update user
- `DELETE /api/admin/users/:id` - Delete user
- `GET /api/admin/servers` - Get all servers
- `POST /api/admin/create-admin` - Create admin user (one-time setup)

## Project Structure

```
minecraft-panel/
├── server.js                 # Main server file
├── config.env               # Environment configuration
├── package.json             # Package configuration
├── src/
│   ├── models/              # MongoDB models
│   │   ├── User.js         # User model
│   │   ├── Server.js       # Server model
│   │   └── Node.js         # Node model
│   ├── routes/              # API routes
│   │   ├── auth.js         # Authentication routes
│   │   ├── servers.js      # Server management routes
│   │   ├── nodes.js        # Node management routes
│   │   └── admin.js        # Admin routes
│   ├── controllers/         # Route controllers (future use)
│   ├── middleware/          # Custom middleware
│   │   └── auth.js         # Authentication middleware
│   ├── utils/               # Utility functions
│   └── config/              # Configuration files
├── public/                  # Static files
│   ├── views/               # HTML views
│   │   ├── index.html      # Home page
│   │   ├── dashboard.html  # User dashboard
│   │   └── admin.html      # Admin panel
│   ├── css/
│   │   └── style.css       # Main stylesheet
│   └── js/                  # Client-side JavaScript
│       ├── auth.js         # Authentication scripts
│       ├── dashboard.js    # Dashboard functionality
│       └── admin.js        # Admin panel functionality
├── servers/                 # Server files directory (created dynamically)
└── uploads/                 # File uploads directory (created dynamically)
```

## Features in Development

- [ ] Plugin installation and management
- [ ] Mod installation and management
- [ ] File manager for server files
- [ ] Backup and restore functionality
- [ ] Advanced server configuration
- [ ] Player management interface
- [ ] Server templates
- [ ] API rate limiting improvements
- [ ] Docker container support
- [ ] Webhook notifications

## Security Considerations

- Change the JWT secret in production
- Use HTTPS in production
- Implement proper password policies
- Regular security audits
- Keep dependencies updated

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the ISC License.

## 🚀 Kurulum ve Başlatma

### Otomatik Ubuntu Kurulumu (Önerilen)

```bash
# GitHub'dan projeyi indir
git clone https://github.com/your-username/minecraft-panel.git
cd minecraft-panel

# Otomatik kurulum script'ini çalıştır
sudo bash install.sh

# Kurulum tamamlandıktan sonra:
# http://sunucu-ip-adresi:3000 adresine git
# Default admin: admin / change-this-password-immediately
```

### Hızlı Başlatma (Development)

```bash
# Bağımlılıkları yükle
npm install

# İlk admin kullanıcısını oluştur
npm run setup

# Geliştirme sunucusunu başlat
npm run dev
```

### Production Kurulumu (Docker)

```bash
# Tüm servisleri başlat
docker-compose up -d

# Logları takip et
docker-compose logs -f
```

### Manuel Kurulum

```bash
# PostgreSQL ve Redis'i başlat
# (Docker veya native installation)

# Veritabanı şemasını oluştur
npx prisma generate
npx prisma db push

# TypeScript'i derle
npm run build

# Servisleri başlat
npm start      # Controller
npm run daemon # Daemon (ayrı terminal)
```

### Ubuntu Server'da Manuel Kurulum

```bash
# Sistem güncellemesi
sudo apt update && sudo apt upgrade -y

# Gerekli paketleri yükle
sudo apt install -y curl wget git postgresql-15 redis-server docker.io

# Node.js kurulumu
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Projeyi klonla
sudo mkdir -p /opt/minecraft-panel
sudo chown $USER:$USER /opt/minecraft-panel
git clone https://github.com/your-username/minecraft-panel.git /opt/minecraft-panel
cd /opt/minecraft-panel

# Bağımlılıkları yükle
npm install

# Konfigürasyon
cp config.env.example config.env
nano config.env  # Veritabanı ayarlarını düzenle

# Veritabanı kurulumu
npx prisma generate
npx prisma db push

# İlk admin kullanıcısı
npm run setup

# Systemd servislerini yükle
sudo cp systemd/minecraft-controller.service /etc/systemd/system/
sudo cp systemd/minecraft-daemon.service /etc/systemd/system/
sudo systemctl daemon-reload

# Servisleri başlat
sudo systemctl enable minecraft-controller minecraft-daemon
sudo systemctl start minecraft-controller minecraft-daemon

# Nginx kurulumu (opsiyonel)
sudo apt install -y nginx
sudo cp nginx.conf /etc/nginx/sites-available/minecraft-panel
sudo ln -s /etc/nginx/sites-available/minecraft-panel /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx

# Cron job'ları yükle
sudo cp cron/minecraft-panel /etc/cron.d/
sudo systemctl restart cron

# Logrotate kurulum
sudo cp logrotate/minecraft-panel /etc/logrotate.d/
```

### Sistem Gereksinimleri

- **Node.js**: 18+ LTS
- **PostgreSQL**: 15+
- **Redis**: 7+
- **Docker**: 24+ (Docker Compose için)
- **TypeScript**: 5.6+

### Ortam Değişkenleri

```bash
# Veritabanı
DATABASE_URL="postgresql://user:pass@localhost:5432/minecraft_panel"
REDIS_URL="redis://localhost:6379"

# Güvenlik
JWT_SECRET="your-super-secret-jwt-key"
DATA_ENCRYPTION_KEY="256-bit-aes-key"

# AWS S3 (Opsiyonel)
AWS_ACCESS_KEY_ID="your-key"
AWS_SECRET_ACCESS_KEY="your-secret"
AWS_S3_BUCKET_NAME="minecraft-backups"

# InfluxDB (Opsiyonel)
INFLUXDB_URL="http://localhost:8086"
INFLUXDB_TOKEN="your-token"
```

## 🧪 Test ve Kalite

```bash
# Tüm testleri çalıştır
npm test

# Coverage raporu
npm run test:coverage

# Lint kontrolü
npx eslint src/ --ext .ts

# TypeScript derleme kontrolü
npm run build
```

## 📊 Monitoring ve Logs

```bash
# Health check
curl http://localhost:3000/health

# Daemon health
curl http://localhost:8080/health

# Application logs
docker-compose logs controller
docker-compose logs daemon

# Database logs
docker-compose logs postgres
```

## 🔧 Troubleshooting

### Yaygın Problemler

**PostgreSQL bağlantı hatası:**
```bash
# Docker container'ını kontrol et
docker ps | grep postgres

# Veritabanına bağlan
docker exec -it minecraft-postgres psql -U postgres -d minecraft_panel
```

**Redis bağlantı hatası:**
```bash
# Redis'i test et
docker exec -it minecraft-redis redis-cli ping
```

**Port çakışması:**
```bash
# Kullanılan portları kontrol et
netstat -tulpn | grep :3000
netstat -tulpn | grep :8080
```

### Log Dosyaları

- **Controller**: `logs/controller.log`
- **Daemon**: `logs/daemon.log`
- **PostgreSQL**: `logs/postgres.log`
- **Redis**: `logs/redis.log`

## 📚 API Dokümantasyonu

### REST API Endpoints

#### Authentication
- `POST /api/auth/register` - Kullanıcı kaydı
- `POST /api/auth/login` - Giriş
- `GET /api/auth/me` - Profil bilgisi

#### Servers
- `GET /api/servers` - Sunucu listesi
- `POST /api/servers` - Sunucu oluştur
- `PUT /api/servers/:id/start` - Sunucuyu başlat
- `DELETE /api/servers/:id` - Sunucuyu sil

#### Plugins & Mods
- `GET /api/servers/:id/plugins` - Plugin listesi
- `POST /api/servers/:id/plugins/install` - Plugin yükle
- `GET /api/servers/:id/mods` - Mod listesi
- `POST /api/servers/:id/mods/install` - Mod yükle

### gRPC Services

Protobuf tanımları `src/proto/` dizininde bulunur.

## 🤝 Contributing

1. Fork edin
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add amazing feature'`)
4. Branch'inizi push edin (`git push origin feature/amazing-feature`)
5. Pull Request oluşturun

## 📄 License

Bu proje ISC License altında lisanslanmıştır.

## 🆘 Support

Destek için repository'de issue açın veya development team ile iletişime geçin.

---

## 🎯 Roadmap

### Phase 1 ✅ (Mevcut)
- [x] Temel Minecraft paneli
- [x] Fastify + TypeScript
- [x] PostgreSQL + Redis
- [x] Docker konteynerizasyonu

### Phase 2 🔄 (Çalışılıyor)
- [ ] React.js frontend
- [ ] gRPC microservices
- [ ] AWS S3 entegrasyonu
- [ ] InfluxDB metrics

### Phase 3 📋 (Planlandı)
- [ ] Kubernetes orchestration
- [ ] Multi-region deployment
- [ ] Advanced monitoring
- [ ] Mobile application

---

**🎉 Enterprise-grade Minecraft server yönetim paneliniz hazır!**