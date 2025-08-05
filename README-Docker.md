# MySQL MCP Server Pro Plus - Docker Setup

This document provides comprehensive instructions for running the MySQL MCP Server Pro Plus using Docker Compose with best practices.

## 🚀 Quick Start

### 1. Prerequisites

- Docker Engine 20.10+
- Docker Compose 2.0+
- Make (optional, for using Makefile commands)

### 2. Initial Setup

```bash
# Clone the repository
git clone <repository-url>
cd mysql_mcp_pro_plus

# Copy environment file
cp env.example .env

# Edit environment variables (optional)
nano .env

# Initialize directories and start services
make dev-setup
```

### 3. Verify Installation

```bash
# Check service status
make status

# View logs
make logs

# Test the setup
make health
```

## 📋 Available Commands

### Using Makefile (Recommended)

```bash
# Show all available commands
make help

# Development setup
make dev-setup

# Start services
make up

# Stop services
make down

# View logs
make logs

# Access shells
make shell          # MCP server shell
make mysql-shell    # MySQL shell
make mysql-root     # MySQL root shell

# Testing and quality
make test
make lint
make security-check

# Backup and restore
make backup
make restore BACKUP_FILE=backups/backup_20231201_120000.sql

# Cleanup
make clean
```

### Using Docker Compose Directly

```bash
# Start services
docker compose up -d

# Start with phpMyAdmin
docker compose --profile admin up -d

# View logs
docker compose logs -f

# Stop services
docker compose down

# Rebuild images
docker compose build --no-cache
```

## 🔧 Configuration

### Environment Variables

The following environment variables can be configured in `.env`:

| Variable              | Default              | Description         |
| --------------------- | -------------------- | ------------------- |
| `MYSQL_ROOT_PASSWORD` | `rootpassword`       | MySQL root password |
| `MYSQL_DATABASE`      | `mcp_database`       | Database name       |
| `MYSQL_USER`          | `mcp_user`           | Database user       |
| `MYSQL_PASSWORD`      | `mcp_password`       | Database password   |
| `MYSQL_CHARSET`       | `utf8mb4`            | Character set       |
| `MYSQL_COLLATION`     | `utf8mb4_unicode_ci` | Collation           |
| `MYSQL_SQL_MODE`      | `TRADITIONAL`        | SQL mode            |

### Ports

- **MySQL**: `3306` (localhost:3306)
- **phpMyAdmin**: `8080` (localhost:8080) - when using admin profile

## 🏗️ Architecture

### Services

1. **mysql**: MySQL 8.0 database server
2. **mcp-server**: Python-based MCP server
3. **phpMyAdmin**: Web-based MySQL administration (optional)

### Network

- Custom bridge network: `mcp_network`
- Subnet: `172.20.0.0/16`

### Volumes

- `mysql_data`: Persistent MySQL data storage
- `./logs`: Application logs
- `./init-scripts`: Database initialization scripts
- `./mysql-config`: MySQL configuration files

## 🔒 Security Features

### Container Security

- Non-root user execution
- Dropped capabilities
- Read-only filesystem (where possible)
- No new privileges
- Temporary filesystem for /tmp

### Database Security

- Custom user with limited privileges
- Secure authentication plugin
- Network isolation
- Configurable SQL mode

## 📊 Monitoring and Health Checks

### Health Checks

- **MySQL**: Uses `mysqladmin ping`
- **MCP Server**: Tests database connectivity

### Logging

```bash
# View all logs
make logs

# View specific service logs
make logs-mysql
make logs-mcp
```

### Status Monitoring

```bash
# Check service status
make status

# Health check
make health
```

## 🧪 Testing

### Run Tests

```bash
# Basic tests
make test

# Tests with coverage
make test-coverage

# Linting
make lint
make lint-fix

# Security checks
make security-check
```

## 💾 Backup and Restore

### Create Backup

```bash
make backup
```

### Restore from Backup

```bash
make restore BACKUP_FILE=backups/backup_20231201_120000.sql
```

## 🛠️ Troubleshooting

### Common Issues

#### 1. Port Conflicts

```bash
# Check if ports are in use
netstat -tulpn | grep :3306
netstat -tulpn | grep :8080

# Change ports in docker-compose.yml if needed
```

#### 2. Permission Issues

```bash
# Fix directory permissions
sudo chown -R $USER:$USER data/ logs/
```

#### 3. Database Connection Issues

```bash
# Check MySQL status
make mysql-root

# Check MCP server logs
make logs-mcp
```

#### 4. Container Won't Start

```bash
# Check container logs
docker compose logs mysql
docker compose logs mcp-server

# Rebuild containers
make clean
make build
make up
```

### Debug Commands

```bash
# Access container shells
make shell
make mysql-shell

# Check container resources
docker compose top

# Inspect containers
docker compose ps
docker inspect mysql_mcp_db
```

## 🔄 Development Workflow

### 1. Development Setup

```bash
make dev-setup
```

### 2. Code Changes

```bash
# Make changes to source code
# Rebuild and restart
make build
make restart
```

### 3. Testing Changes

```bash
make test
make lint
```

### 4. Production Deployment

```bash
make prod-setup
```

## 📚 Additional Resources

- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [MySQL Docker Image](https://hub.docker.com/_/mysql)
- [MCP Protocol Documentation](https://modelcontextprotocol.io/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with `make test`
5. Submit a pull request

## 📄 License

This project is licensed under the same terms as the main project.
