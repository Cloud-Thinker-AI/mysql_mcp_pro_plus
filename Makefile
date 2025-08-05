# MySQL MCP Server Pro Plus - Makefile
# Best practices for Docker Compose management

.PHONY: help build up down start stop restart logs clean test lint security-check init-dirs backup restore shell mysql-shell status ps

# Default target
help: ## Show this help message
	@echo "MySQL MCP Server Pro Plus - Available Commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# Environment setup
init-dirs: ## Create necessary directories
	@echo "Creating necessary directories..."
	@mkdir -p data/mysql logs init-scripts mysql-config
	@echo "Directories created successfully!"

# Docker Compose commands
build: ## Build the Docker images
	@echo "Building Docker images..."
	docker compose build --no-cache

up: ## Start all services in detached mode
	@echo "Starting services..."
	docker compose up -d

down: ## Stop and remove all containers, networks, and volumes
	@echo "Stopping and removing all services..."
	docker compose down -v

start: ## Start existing containers
	@echo "Starting existing containers..."
	docker compose start

stop: ## Stop running containers
	@echo "Stopping containers..."
	docker compose stop

restart: ## Restart all services
	@echo "Restarting services..."
	docker compose restart

# Logging and monitoring
logs: ## Show logs from all services
	docker compose logs -f

logs-mysql: ## Show MySQL logs
	docker compose logs -f mysql

logs-mcp: ## Show MCP server logs
	docker compose logs -f mcp-server

status: ## Show status of all services
	@echo "Service Status:"
	docker compose ps

ps: status ## Alias for status

# Development and testing
test: ## Run tests
	@echo "Running tests..."
	docker compose run --rm mcp-server python -m pytest tests/ -v

test-coverage: ## Run tests with coverage
	@echo "Running tests with coverage..."
	docker compose run --rm mcp-server python -m pytest tests/ --cov=src/ --cov-report=html --cov-report=term

lint: ## Run linting checks
	@echo "Running linting checks..."
	uv run pre-commit run --all-files

# Security and quality checks
security-check: ## Run security checks
	@echo "Running security checks..."
	docker compose run --rm mcp-server bandit -r src/ -f json -o security-report.json || true
	@echo "Security check completed. Check security-report.json for details."

# Database operations
shell: ## Access MCP server shell
	docker compose exec mcp-server /bin/bash

mysql-shell: ## Access MySQL shell
	docker compose exec mysql mysql -u $(MYSQL_USER) -p$(MYSQL_PASSWORD) $(MYSQL_DATABASE)

mysql-root: ## Access MySQL as root
	docker compose exec mysql mysql -u root -p$(MYSQL_ROOT_PASSWORD)

# Backup and restore
backup: ## Create database backup
	@echo "Creating database backup..."
	@mkdir -p backups
	docker compose exec mysql mysqldump -u $(MYSQL_USER) -p$(MYSQL_PASSWORD) $(MYSQL_DATABASE) > backups/backup_$(shell date +%Y%m%d_%H%M%S).sql
	@echo "Backup created successfully!"

restore: ## Restore database from backup (usage: make restore BACKUP_FILE=backups/backup_20231201_120000.sql)
	@if [ -z "$(BACKUP_FILE)" ]; then echo "Usage: make restore BACKUP_FILE=path/to/backup.sql"; exit 1; fi
	@echo "Restoring database from $(BACKUP_FILE)..."
	docker compose exec -T mysql mysql -u $(MYSQL_USER) -p$(MYSQL_PASSWORD) $(MYSQL_DATABASE) < $(BACKUP_FILE)
	@echo "Database restored successfully!"

# Cleanup
clean: ## Remove all containers, images, volumes, and networks
	@echo "Cleaning up all Docker resources..."
	docker compose down -v --rmi all --remove-orphans
	docker system prune -f
	@echo "Cleanup completed!"

clean-data: ## Remove only data volumes (keeps images)
	@echo "Removing data volumes..."
	docker compose down -v
	@echo "Data volumes removed!"

# Development with admin tools
up-with-admin: ## Start services including phpMyAdmin
	@echo "Starting services with phpMyAdmin..."
	docker compose --profile admin up -d

# Health checks
health: ## Check health of all services
	@echo "Checking service health..."
	@docker compose ps
	@echo ""
	@echo "Health check results:"
	@docker compose exec mysql mysqladmin ping -h localhost -u root -p$(MYSQL_ROOT_PASSWORD) || echo "MySQL health check failed"
	@docker compose exec mcp-server python3 -c "import mysql.connector; mysql.connector.connect(host='mysql', user='$(MYSQL_USER)', password='$(MYSQL_PASSWORD)', database='$(MYSQL_DATABASE)'); print('MCP Server health check passed')" || echo "MCP Server health check failed"

# Quick setup for development
dev-setup: init-dirs build up ## Complete development setup
	@echo "Development setup completed!"
	@echo "Services are running. Use 'make logs' to view logs."
	@echo "phpMyAdmin available at: http://localhost:8080"
	@echo "MySQL accessible at: localhost:3306"

# Production setup
prod-setup: init-dirs build up ## Complete production setup
	@echo "Production setup completed!"
	@echo "Services are running in production mode."

# Environment variables (can be overridden)
MYSQL_ROOT_PASSWORD ?= rootpassword
MYSQL_DATABASE ?= mcp_database
MYSQL_USER ?= mcp_user
MYSQL_PASSWORD ?= mcp_password
