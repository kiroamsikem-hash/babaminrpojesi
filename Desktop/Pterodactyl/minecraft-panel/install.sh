#!/bin/bash

# AetherPanel - Ubuntu Auto Installer
# Version: 2.0.0
# Author: AetherPanel Team

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PANEL_DIR="/opt/aetherpanel"
PANEL_USER="aetherpanel"
PANEL_GROUP="aetherpanel"
NODE_VERSION="18"
POSTGRES_VERSION="15"
REDIS_VERSION="7"
INFLUXDB_VERSION="2.7"

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        log_error "This script must NOT be run as root"
        exit 1
    fi
}

# Check Ubuntu version
check_ubuntu() {
    if [[ ! -f /etc/os-release ]]; then
        log_error "This script is designed for Ubuntu/Debian systems only"
        exit 1
    fi

    . /etc/os-release
    if [[ "$ID" != "ubuntu" && "$ID" != "debian" ]]; then
        log_error "This script is designed for Ubuntu/Debian systems only"
        exit 1
    fi

    log_info "Detected $PRETTY_NAME"
}

# Update system packages
update_system() {
    log_info "Updating system packages..."
    sudo apt update
    sudo apt upgrade -y
    sudo apt autoremove -y
    log_success "System packages updated"
}

# Install system dependencies
install_dependencies() {
    log_info "Installing system dependencies..."

    # Basic tools
    sudo apt install -y curl wget git unzip software-properties-common apt-transport-https ca-certificates gnupg lsb-release

    # Build tools
    sudo apt install -y build-essential python3 python3-dev python3-pip

    # Database and cache
    sudo apt install -y postgresql-$POSTGRES_VERSION postgresql-contrib-$POSTGRES_VERSION redis-server

    # Java for Minecraft
    sudo apt install -y openjdk-17-jre-headless

    # Network tools
    sudo apt install -y ufw fail2ban

    # Monitoring tools
    sudo apt install -y htop iotop ncdu

    # Development tools
    sudo apt install -y vim nano screen tmux

    log_success "System dependencies installed"
}

# Install Node.js
install_nodejs() {
    log_info "Installing Node.js $NODE_VERSION..."

    if ! command -v node &> /dev/null; then
        curl -fsSL https://deb.nodesource.com/setup_$NODE_VERSION.x | sudo -E bash -
        sudo apt-get install -y nodejs
    fi

    # Install PM2 for process management
    sudo npm install -g pm2 @types/node typescript ts-node

    log_success "Node.js $NODE_VERSION installed"
}

# Install Docker
install_docker() {
    log_info "Installing Docker..."

    if ! command -v docker &> /dev/null; then
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt update
        sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    fi

    # Add user to docker group
    sudo usermod -aG docker $USER

    log_success "Docker installed"
}

# Install InfluxDB
install_influxdb() {
    log_info "Installing InfluxDB..."

    if ! command -v influx &> /dev/null; then
        wget -qO- https://repos.influxdata.com/influxdb.key | sudo apt-key add -
        echo "deb https://repos.influxdata.com/ubuntu focal stable" | sudo tee /etc/apt/sources.list.d/influxdb.list
        sudo apt update
        sudo apt install -y influxdb2

        sudo systemctl enable influxdb
        sudo systemctl start influxdb
    fi

    log_success "InfluxDB installed"
}

# Setup PostgreSQL
setup_postgres() {
    log_info "Setting up PostgreSQL..."

    # Create database and user
    sudo -u postgres psql -c "CREATE DATABASE aetherpanel;" 2>/dev/null || true
    sudo -u postgres psql -c "CREATE USER aetherpanel WITH PASSWORD 'secure_password_change_this';" 2>/dev/null || true
    sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE aetherpanel TO aetherpanel;" 2>/dev/null || true

    # Enable and start service
    sudo systemctl enable postgresql
    sudo systemctl start postgresql

    log_success "PostgreSQL configured"
}

# Setup Redis
setup_redis() {
    log_info "Setting up Redis..."

    # Configure Redis
    sudo sed -i 's/supervised no/supervised systemd/' /etc/redis/redis.conf
    sudo sed -i 's/# maxmemory <bytes>/maxmemory 256mb/' /etc/redis/redis.conf
    sudo sed -i 's/# maxmemory-policy noeviction/maxmemory-policy allkeys-lru/' /etc/redis/redis.conf

    sudo systemctl enable redis-server
    sudo systemctl restart redis-server

    log_success "Redis configured"
}

# Create minecraft user
create_user() {
    log_info "Creating minecraft user..."

    if ! id "$PANEL_USER" &>/dev/null; then
        sudo groupadd -f $PANEL_GROUP
        sudo useradd -r -s /bin/bash -g $PANEL_GROUP -d $PANEL_DIR -m $PANEL_USER
    fi

    # Add to necessary groups
    sudo usermod -aG docker $PANEL_USER
    sudo usermod -aG www-data $PANEL_USER

    log_success "Minecraft user created"
}

# Setup directories
setup_directories() {
    log_info "Setting up directories..."

    sudo mkdir -p $PANEL_DIR
    sudo mkdir -p $PANEL_DIR/servers
    sudo mkdir -p $PANEL_DIR/backups
    sudo mkdir -p $PANEL_DIR/temp
    sudo mkdir -p $PANEL_DIR/logs
    sudo mkdir -p $PANEL_DIR/uploads

    sudo chown -R $PANEL_USER:$PANEL_GROUP $PANEL_DIR
    sudo chmod -R 755 $PANEL_DIR

    log_success "Directories created and configured"
}

# Configure firewall
configure_firewall() {
    log_info "Configuring firewall..."

    # Enable UFW
    sudo ufw --force enable

    # Allow SSH (important!)
    sudo ufw allow ssh

    # Allow web ports
    sudo ufw allow 80
    sudo ufw allow 443

    # Allow Minecraft panel ports
    sudo ufw allow 3000
    sudo ufw allow 8080
    sudo ufw allow 2022

    # Allow Minecraft server ports (range)
    sudo ufw allow 25565:25665/tcp
    sudo ufw allow 25565:25665/udp

    log_success "Firewall configured"
}

# Configure fail2ban
configure_fail2ban() {
    log_info "Configuring fail2ban..."

    sudo systemctl enable fail2ban
    sudo systemctl start fail2ban

    log_success "Fail2ban configured"
}

# Clone and setup panel
setup_panel() {
    log_info "Setting up Minecraft Panel..."

    # Clone repository (this would be your GitHub repo)
    if [[ ! -d "$PANEL_DIR/.git" ]]; then
        sudo -u $PANEL_USER git clone https://github.com/your-username/minecraft-panel.git $PANEL_DIR
    fi

    cd $PANEL_DIR

    # Install dependencies
    sudo -u $PANEL_USER npm install

    # Setup environment
    if [[ ! -f "$PANEL_DIR/config.env" ]]; then
        sudo -u $PANEL_USER cp config.env.example config.env
        # Configure database URLs
        sudo -u $PANEL_USER sed -i 's|DATABASE_URL=.*|DATABASE_URL="postgresql://minecraft:secure_password_change_this@localhost:5432/minecraft_panel?schema=public"|' config.env
        sudo -u $PANEL_USER sed -i 's|REDIS_URL=.*|REDIS_URL="redis://localhost:6379"|' config.env
        sudo -u $PANEL_USER sed -i 's|INFLUXDB_URL=.*|INFLUXDB_URL="http://localhost:8086"|' config.env
    fi

    # Generate Prisma client
    sudo -u $PANEL_USER npx prisma generate

    # Push database schema
    sudo -u $PANEL_USER npx prisma db push

    # Create admin user
    sudo -u $PANEL_USER npm run setup

    log_success "AetherPanel setup completed"
}

# Create systemd services
create_services() {
    log_info "Creating systemd services..."

    # Controller service
    cat > /tmp/aetherpanel-controller.service << EOF
[Unit]
Description=AetherPanel Controller
After=network.target postgresql.service redis-server.service influxdb.service
Requires=postgresql.service redis-server.service influxdb.service

[Service]
Type=simple
User=$PANEL_USER
Group=$PANEL_GROUP
WorkingDirectory=$PANEL_DIR
ExecStart=/usr/bin/npm run start
Restart=always
RestartSec=10
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
EOF

    sudo mv /tmp/aetherpanel-controller.service /etc/systemd/system/
    sudo systemctl daemon-reload
    sudo systemctl enable aetherpanel-controller

    # Daemon service
    cat > /tmp/aetherpanel-daemon.service << EOF
[Unit]
Description=AetherPanel Daemon
After=network.target docker.service
Requires=docker.service

[Service]
Type=simple
User=$PANEL_USER
Group=$PANEL_GROUP
WorkingDirectory=$PANEL_DIR
ExecStart=/usr/bin/npm run daemon
Restart=always
RestartSec=10
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
EOF

    sudo mv /tmp/aetherpanel-daemon.service /etc/systemd/system/
    sudo systemctl daemon-reload
    sudo systemctl enable aetherpanel-daemon

    log_success "Systemd services created"
}

# Setup SSL (optional)
setup_ssl() {
    log_info "Setting up SSL certificate..."

    if command -v certbot &> /dev/null; then
        log_info "Certbot already installed"
    else
        sudo apt install -y certbot python3-certbot-nginx
    fi

    log_success "SSL setup ready (run certbot manually for certificates)"
}

# Start services
start_services() {
    log_info "Starting services..."

    sudo systemctl start aetherpanel-controller
    sudo systemctl start aetherpanel-daemon

    # Wait for services to start
    sleep 10

    # Check status
    if sudo systemctl is-active --quiet aetherpanel-controller; then
        log_success "Controller service started"
    else
        log_error "Controller service failed to start"
    fi

    if sudo systemctl is-active --quiet aetherpanel-daemon; then
        log_success "Daemon service started"
    else
        log_error "Daemon service failed to start"
    fi
}

# Display completion message
completion_message() {
    echo
    log_success "🎉 AetherPanel installation completed!"
    echo
    echo "🌐 Web Panel: http://$(hostname -I | awk '{print $1}'):3000"
    echo "🔧 Admin Panel: http://$(hostname -I | awk '{print $1}'):3000/admin"
    echo "📊 Daemon API: http://$(hostname -I | awk '{print $1}'):8080"
    echo "🔐 SFTP Server: $(hostname -I | awk '{print $1}'):2022"
    echo
    echo "📝 Next steps:"
    echo "1. Configure your domain and SSL certificate"
    echo "2. Update database passwords in config.env"
    echo "3. Configure AWS S3 for backups (optional)"
    echo "4. Set up monitoring and alerts"
    echo
    echo "🔑 Default Admin Credentials:"
    echo "Username: admin"
    echo "Password: change-this-password-immediately"
    echo
    echo "📚 Useful commands:"
    echo "sudo systemctl status minecraft-controller  # Check controller status"
    echo "sudo systemctl status minecraft-daemon     # Check daemon status"
    echo "sudo ufw status                            # Check firewall status"
    echo "sudo -u minecraft pm2 logs                 # View application logs"
    echo
    echo "⚠️  IMPORTANT SECURITY STEPS:"
    echo "1. Change default admin password immediately"
    echo "2. Update database passwords"
    echo "3. Configure SSL certificates"
    echo "4. Review firewall rules"
    echo "5. Enable automatic backups"
    echo
}

# Main installation function
main() {
    echo "🚀 AetherPanel - Ubuntu Auto Installer"
    echo "====================================="
    echo

    check_root
    check_ubuntu

    echo "This script will install:"
    echo "- Node.js $NODE_VERSION"
    echo "- PostgreSQL $POSTGRES_VERSION"
    echo "- Redis $REDIS_VERSION"
    echo "- InfluxDB $INFLUXDB_VERSION"
    echo "- Docker & Docker Compose"
    echo "- AetherPanel"
    echo

    read -p "Do you want to continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Installation cancelled"
        exit 0
    fi

    update_system
    install_dependencies
    install_nodejs
    install_docker
    install_influxdb
    setup_postgres
    setup_redis
    create_user
    setup_directories
    configure_firewall
    configure_fail2ban
    setup_panel
    create_services
    setup_ssl
    start_services
    completion_message

    log_success "Installation completed successfully! 🎉"
}

# Run main function
main "$@"