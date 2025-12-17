# 🚀 Production Deployment Guide for Urganise

This guide explains how to build and deploy Urganise for production using Docker Desktop.

## 📋 Table of Contents
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Building for Production](#building-for-production)
- [Running in Production](#running-in-production)
- [Database Management](#database-management)
- [Monitoring](#monitoring)
- [Security Considerations](#security-considerations)
- [Troubleshooting](#troubleshooting)

## 🔧 Prerequisites

- **Docker Desktop** installed and running
- Minimum 2GB RAM available for containers
- Git
- Basic understanding of environment variables

## ⚡ Quick Start

### 1. Clone and Configure

```bash
# Clone the repository
git clone <your-repo-url>
cd urganise

# Create production environment file
cp .env.production.example .env.production
```

### 2. Configure Environment Variables

Edit `.env.production` with secure values:

```bash
# Required: Change the database password
POSTGRES_PASSWORD=your_secure_password_here

# Required: Generate a secret key base
SECRET_KEY_BASE=$(docker run --rm ruby:3.4.7-slim ruby -e "require 'securerandom'; puts SecureRandom.hex(64)")

# Optional: Add Gemini API key for AI features
GOOGLE_GEMINI_API_KEY=your_api_key_here
```

### 3. Build and Start

Using the helper script (recommended):
```bash
./docker-helper.sh build          # Build production image
./docker-helper.sh start --prod   # Start in production mode
```

Or using Make:
```bash
make build                        # Build production image
make start-prod                   # Start in production mode
```

Or using Docker Compose directly:
```bash
docker-compose -f docker-compose.prod.yml build
docker-compose -f docker-compose.prod.yml --env-file .env.production up -d
```

### 4. Access the Application

Open your browser and navigate to:
```
http://localhost:3000
```

## ⚙️ Configuration

### Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `POSTGRES_USER` | Yes | `urganise` | Database username |
| `POSTGRES_PASSWORD` | Yes | - | Database password (must be secure) |
| `POSTGRES_DB` | Yes | `urganise_production` | Database name |
| `SECRET_KEY_BASE` | Yes | - | Rails secret key (use `rails secret`) |
| `GOOGLE_GEMINI_API_KEY` | No | - | API key for AI features |
| `PORT` | No | `3000` | Application port |
| `RAILS_MAX_THREADS` | No | `5` | Puma thread count |
| `SEED_DB` | No | `false` | Load demo data on first run |

### Generating SECRET_KEY_BASE

Method 1 - Using Docker:
```bash
docker run --rm ruby:3.4.7-slim ruby -e "require 'securerandom'; puts SecureRandom.hex(64)"
```

Method 2 - Using Rails (if installed locally):
```bash
rails secret
```

## 🔨 Building for Production

### Build Production Image

```bash
# Using helper script
./docker-helper.sh build

# Using Make
make build

# Using Docker Compose
docker-compose -f docker-compose.prod.yml build --no-cache
```

This will:
- Build a multi-stage Docker image optimized for production
- Precompile assets (Tailwind CSS)
- Install only production gems
- Set up the Rails environment

### Image Size Optimization

The production Dockerfile uses:
- Multi-stage builds to reduce final image size
- Ruby slim base image
- jemalloc for memory optimization
- Only production dependencies

## 🚀 Running in Production

### Start the Application

```bash
# Start (builds if needed)
./docker-helper.sh start --prod

# Or with Make
make start-prod
```

### Stop the Application

```bash
# Stop all containers
./docker-helper.sh stop

# Or with Make
make stop
```

### View Logs

```bash
# Real-time logs
./docker-helper.sh logs

# Or with Docker Compose
docker-compose -f docker-compose.prod.yml logs -f
```

### Restart the Application

```bash
# Restart without rebuilding
docker-compose -f docker-compose.prod.yml restart

# Restart with rebuild
docker-compose -f docker-compose.prod.yml up --build -d
```

## 💾 Database Management

### Initial Setup

The database is automatically set up on first run:
- Database creation
- Schema loading
- Migrations execution
- Optional seeding (if `SEED_DB=true`)

### Run Migrations

```bash
# Access the container
docker-compose -f docker-compose.prod.yml exec web bash

# Run migrations
bundle exec rails db:migrate RAILS_ENV=production
```

### Backup Database

```bash
# Create backup
docker-compose -f docker-compose.prod.yml exec db pg_dump -U urganise urganise_production > backup.sql

# With timestamp
docker-compose -f docker-compose.prod.yml exec db pg_dump -U urganise urganise_production > backup_$(date +%Y%m%d_%H%M%S).sql
```

### Restore Database

```bash
# Stop the application
docker-compose -f docker-compose.prod.yml stop web

# Restore from backup
cat backup.sql | docker-compose -f docker-compose.prod.yml exec -T db psql -U urganise urganise_production

# Restart application
docker-compose -f docker-compose.prod.yml start web
```

### Database Console

```bash
# PostgreSQL console
docker-compose -f docker-compose.prod.yml exec db psql -U urganise urganise_production

# Rails console (with database access)
docker-compose -f docker-compose.prod.yml exec web rails console RAILS_ENV=production
```

## 📊 Monitoring

### Check Container Status

```bash
# Using helper script
./docker-helper.sh status

# Or directly
docker-compose -f docker-compose.prod.yml ps
```

### View Resource Usage

```bash
# Real-time stats
docker stats

# Container logs
docker-compose -f docker-compose.prod.yml logs web
docker-compose -f docker-compose.prod.yml logs db
```

### Health Checks

The production setup includes automatic health checks:

**Database Health Check:**
- Runs every 10 seconds
- Checks PostgreSQL readiness
- 5 retries before marking unhealthy

**Web Application Health Check:**
- Runs every 30 seconds
- Checks `/up` endpoint
- 40 second startup grace period

View health status:
```bash
docker-compose -f docker-compose.prod.yml ps
```

## 🔒 Security Considerations

### Before Deploying to Production

1. **Change Default Passwords**
   ```bash
   # In .env.production
   POSTGRES_PASSWORD=use_a_very_secure_random_password
   ```

2. **Generate Secure SECRET_KEY_BASE**
   ```bash
   # Never use the same key across environments
   SECRET_KEY_BASE=$(docker run --rm ruby:3.4.7-slim ruby -e "require 'securerandom'; puts SecureRandom.hex(64)")
   ```

3. **Disable Demo Seeding**
   ```bash
   # In .env.production
   SEED_DB=false
   ```

4. **Review Exposed Ports**
   ```yaml
   # In docker-compose.prod.yml
   # Only expose necessary ports
   ports:
     - "3000:3000"  # Consider using a reverse proxy
   ```

5. **Set Allowed Hosts (if deploying to a domain)**
   ```bash
   # In .env.production
   RAILS_HOSTS=yourdomain.com,www.yourdomain.com
   ```

6. **Enable SSL (if behind a proxy)**
   ```bash
   # In .env.production
   FORCE_SSL=true
   ```

### File Permissions

The production Dockerfile runs as a non-root user (UID 1000) for security:
```dockerfile
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash
USER 1000:1000
```

### Sensitive Files

Never commit these files to version control:
- `.env.production` (contains secrets)
- `config/master.key` (Rails credentials)
- `config/credentials/*.key`

Ensure `.gitignore` includes:
```
/.env*
/config/*.key
```

## 🐛 Troubleshooting

### Container Won't Start

**Check logs:**
```bash
docker-compose -f docker-compose.prod.yml logs web
docker-compose -f docker-compose.prod.yml logs db
```

**Common issues:**
1. **Database not ready** - Wait a few seconds and check health status
2. **Missing SECRET_KEY_BASE** - Generate and add to `.env.production`
3. **Port already in use** - Change `PORT` in `.env.production`

### Database Connection Errors

**Verify database is running:**
```bash
docker-compose -f docker-compose.prod.yml ps db
```

**Test connection:**
```bash
docker-compose -f docker-compose.prod.yml exec db psql -U urganise urganise_production -c "SELECT 1;"
```

**Check credentials:**
```bash
# Verify environment variables are loaded
docker-compose -f docker-compose.prod.yml exec web env | grep POSTGRES
```

### Asset Compilation Errors

**Rebuild without cache:**
```bash
docker-compose -f docker-compose.prod.yml build --no-cache web
```

**Precompile assets manually:**
```bash
docker-compose -f docker-compose.prod.yml exec web rails assets:precompile RAILS_ENV=production
```

### Performance Issues

**Check resource usage:**
```bash
docker stats
```

**Increase thread count:**
```bash
# In .env.production
RAILS_MAX_THREADS=10
```

**Check database connections:**
```bash
docker-compose -f docker-compose.prod.yml exec db psql -U urganise urganise_production -c "SELECT count(*) FROM pg_stat_activity;"
```

### Clean Restart

If you encounter persistent issues:
```bash
# Stop everything
docker-compose -f docker-compose.prod.yml down

# Remove volumes (⚠️ deletes data!)
docker-compose -f docker-compose.prod.yml down -v

# Rebuild and start fresh
docker-compose -f docker-compose.prod.yml up --build -d
```

## 📦 Updating the Application

### Pull Latest Changes

```bash
# Stop the application
docker-compose -f docker-compose.prod.yml down

# Pull updates
git pull origin main

# Rebuild and start
docker-compose -f docker-compose.prod.yml up --build -d

# Check logs
docker-compose -f docker-compose.prod.yml logs -f web
```

### Zero-Downtime Updates (with backup)

```bash
# 1. Backup database
docker-compose -f docker-compose.prod.yml exec db pg_dump -U urganise urganise_production > backup_before_update.sql

# 2. Pull updates
git pull origin main

# 3. Build new image
docker-compose -f docker-compose.prod.yml build

# 4. Run migrations (if any)
docker-compose -f docker-compose.prod.yml run --rm web rails db:migrate RAILS_ENV=production

# 5. Restart with new image
docker-compose -f docker-compose.prod.yml up -d
```

## 🌐 Exposing to the Internet

For production deployment accessible from the internet, consider:

1. **Reverse Proxy** (Nginx, Traefik, Caddy)
2. **SSL/TLS Certificates** (Let's Encrypt)
3. **Domain Configuration**
4. **Firewall Rules**
5. **Regular Backups**

Example with Nginx:
```nginx
server {
    listen 80;
    server_name yourdomain.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## 📞 Support

For issues or questions:
- Check the [DOCKER.md](DOCKER.md) for development setup
- Review [README.md](README.md) for general information
- Check Docker logs: `./docker-helper.sh logs`

---

**Remember:** Always test changes in a development environment before deploying to production! 🚀
