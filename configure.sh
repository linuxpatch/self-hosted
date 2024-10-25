#!/bin/bash 
# Author: support@linuxpatch.com
# Description: This script generates a random set of credentials and writes them to a .env file.
# It also creates required directories and sets up logging.

# Set up logging
LOG_FILE="configure.log"
exec 1> >(tee -a "$LOG_FILE") 2>&1

echo "Starting configuration at $(date)"

# Create required directories
if [ ! -d data/certs ] || [ ! -d data/logs ]; then
    echo "Creating required directories..."
    mkdir -p data/certs data/logs
    chmod 755 data/certs data/logs
fi

# Function to generate random string
generate_random() {
    local length=$1
    if [[ ! "$length" =~ ^[0-9]+$ ]]; then
        echo "Error: Length must be a positive integer" >&2
        return 1
    fi
    if [ "$length" -lt 1 ]; then
        echo "Error: Length must be greater than 0" >&2
        return 1
    fi
    LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom | head -c "$length"
}

echo "Checking for existing configuration..."

# Load existing .env if it exists
if [ -f data/.env ]; then
    echo "Found existing .env file, loading configuration..."
    source data/.env
    
    # Check and set missing variables with defaults or generated values
    [ -z "$PREFIX_DIR" ] && PREFIX_DIR="/app/data"
    [ -z "$DOMAIN" ] && DOMAIN=$(hostname -f 2>/dev/null || hostname)
    [ -z "$DB_USERNAME" ] && DB_USERNAME="lpuser_$(generate_random 8)"
    [ -z "$DB_PASSWORD" ] && DB_PASSWORD="$(generate_random 32)"
    [ -z "$DB_NAME" ] && DB_NAME="linuxpatch"
    [ -z "$REDIS_DATABASE" ] && REDIS_DATABASE=0
    [ -z "$SESSION_SECRET" ] && SESSION_SECRET="$(generate_random 32)"
    [ -z "$SMTP_USERNAME" ] && SMTP_USERNAME="smtp_$(generate_random 8)"
    [ -z "$SMTP_PASSWORD" ] && SMTP_PASSWORD="$(generate_random 32)"
    [ -z "$SMTP_FROM_EMAIL" ] && SMTP_FROM_EMAIL="noreply@$(hostname -f 2>/dev/null || hostname)"
    [ -z "$ADMIN_USERNAME" ] && ADMIN_USERNAME="admin@$(hostname -f 2>/dev/null || hostname)"
    [ -z "$ADMIN_PASSWORD" ] && ADMIN_PASSWORD="$(generate_random 32)"
else
    echo "No existing configuration found. Generating new credentials..."
    
    DOMAIN=$(hostname -f 2>/dev/null || hostname)

    # Generate random credentials
    DB_USERNAME="lpuser_$(generate_random 8)"
    DB_PASSWORD="$(generate_random 32)"
    DB_NAME="linuxpatch"
    REDIS_DATABASE=0
    SESSION_SECRET="$(generate_random 64)"
    SMTP_USERNAME="smtp_$(generate_random 8)"
    SMTP_PASSWORD="$(generate_random 32)"
    SMTP_FROM_EMAIL="noreply@$DOMAIN"
    ADMIN_USERNAME="admin@$DOMAIN"
    ADMIN_PASSWORD="$(generate_random 24)"

    # Create .env file
    echo "Creating .env file..."
    cat > data/.env << EOF

# Prefix Directory
PREFIX_DIR=/app/data
CONFIG_FILE=${PREFIX_DIR}/.env

# Database Configuration
DB_TYPE=mysql
DB_USERNAME=$DB_USERNAME
DB_PASSWORD=$DB_PASSWORD
DB_NAME=$DB_NAME

# Redis Configuration
REDIS_DATABASE=$REDIS_DATABASE

# Session Configuration
SESSION_SECRET=$SESSION_SECRET

# SMTP Configuration
SMTP_HOST=localhost
SMTP_PORT=25
SMTP_USERNAME=$SMTP_USERNAME
SMTP_PASSWORD=$SMTP_PASSWORD
SMTP_FROM_EMAIL=$SMTP_FROM_EMAIL
SMTP_USE_TLS=0

# Logging Configuration
LOG_FILE=

# Server Configuration
SERVER_NAME=$DOMAIN
SERVER_PORT=80
TLS_DOMAIN=$DOMAIN
TLS_PORT=443
TLS_ENABLED=0

# TLS Configuration
TLS_CERT_FILE=/app/data/certs/server.crt
TLS_KEY_FILE=/app/data/certs/server.key
TLS_CA_FILE=/app/data/certs/ca.crt
EOF
fi

echo "Configuration completed successfully at $(date)"
echo "Credentials have been saved to .env file"
echo "Log file available at: $LOG_FILE"

# Print summary (excluding sensitive data)
echo -e "\nConfiguration Summary:"
echo "========================"
echo "Database Name: $DB_NAME"
echo "Database Username: $DB_USERNAME"
echo "Database Password: $DB_PASSWORD"
echo "Redis Database: $REDIS_DATABASE"
echo "SMTP From Email: $SMTP_FROM_EMAIL"
echo "SMTP Username: $SMTP_USERNAME"
echo "SMTP Password: $SMTP_PASSWORD"
echo "Log File: $LOG_FILE"
echo "Server Port: 80"
echo "TLS Port: 443"

# Update docker-compose.yml with environment variables
echo "Updating docker-compose.yml with configuration..."

cat > docker-compose.yml << EOF
services:
  linuxpatch-app:
    restart: unless-stopped
    image: linuxpatch/appliance:latest
    expose:
      - "80"
      - "443" 
    command: ["./web"]
    environment:
      - PREFIX_DIR=/app/data
      - CONFIG_FILE=/app/data/.env
      - DB_TYPE=${DB_TYPE:-mysql}
      - DB_HOST=linuxpatch-db
      - DB_PORT=3306
      - DB_USERNAME=${DB_USERNAME}
      - DB_PASSWORD=${DB_PASSWORD}
      - DB_NAME=${DB_NAME}
      - REDIS_HOST=linuxpatch-redis
      - REDIS_PORT=6379
      - REDIS_DATABASE=${REDIS_DATABASE}
      - SESSION_SECRET=${SESSION_SECRET}
      - TLS_CERT_FILE=/app/data/certs/server.crt
      - TLS_KEY_FILE=/app/data/certs/server.key
      - TLS_ENABLED=${TLS_ENABLED:-0}
      - TLS_CA_FILE=/app/data/certs/ca.crt
      - SMTP_HOST=${SMTP_HOST}
      - SMTP_PORT=${SMTP_PORT}
      - SMTP_USERNAME=${SMTP_USERNAME}
      - SMTP_PASSWORD=${SMTP_PASSWORD}
      - SMTP_FROM_EMAIL=${SMTP_FROM_EMAIL}
      - SMTP_USE_TLS=${SMTP_USE_TLS}
      - LOG_FILE=
      - SERVER_NAME=${SERVER_NAME:-$(hostname -f 2>/dev/null || hostname)}
      - SERVER_HOST=${SERVER_HOST:-0.0.0.0} 
      - SERVER_PORT=${SERVER_PORT:-80}
      - TLS_DOMAIN=${TLS_DOMAIN:-$(hostname -f 2>/dev/null || hostname)}
      - TLS_PORT=${TLS_PORT:-443}
      - ADMIN_USERNAME=${ADMIN_USERNAME}
      - ADMIN_PASSWORD=${ADMIN_PASSWORD}
    volumes:
      - ${PREFIX_DIR}/data:/app/data
    depends_on:
      linuxpatch-db:
        condition: service_healthy
      linuxpatch-redis:
        condition: service_healthy
    networks:
      - linuxpatch-app-network
    ports:
      - 80:80
      - 443:443

  linuxpatch-db:
    restart: unless-stopped
    image: percona/percona-server:8.0
    command: mysqld
    environment:
      - MYSQL_ROOT_PASSWORD=${DB_PASSWORD}
      - MYSQL_DATABASE=${DB_NAME}
      - MYSQL_USER=${DB_USERNAME}
      - MYSQL_PASSWORD=${DB_PASSWORD}
    volumes:
      - linuxpatch-mysql-data:/var/lib/mysql
    networks:
      - linuxpatch-app-network
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 10s
      timeout: 10s
      retries: 10

  linuxpatch-redis:
    restart: unless-stopped
    image: redis:6
    command: redis-server
    volumes:
      - linuxpatch-redis-data:/data
    networks:
      - linuxpatch-app-network
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 10s
      retries: 10

volumes:
  linuxpatch-mysql-data:
  linuxpatch-redis-data:

networks:
  linuxpatch-app-network:
    driver: bridge
EOF

echo "docker-compose.yml has been updated with configuration values"

echo "Configuration completed successfully at $(date)"

echo "Starting services..."

docker compose up -d

echo "Services started successfully"

echo
echo "Configuration completed successfully at $(date)"
echo
echo "You can access the application at https://$DOMAIN"
echo
echo "- Username: $ADMIN_USERNAME"
echo "- Password: $ADMIN_PASSWORD"
echo
echo "Thank you for using LinuxPatch!"
