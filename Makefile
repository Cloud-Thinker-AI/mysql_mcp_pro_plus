# MySQL MCP Server Pro Plus - Makefile
# Best practices for Docker Compose management

.PHONY: help up down logs clean test lint security-check init-dirs backup restore shell mysql-shell status ps

# Default target
help: ## Show this help message
	@echo "MySQL MCP Server Pro Plus - Available Commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'


up: ## Start all services in detached mode
	@echo "Starting services..."
	docker compose up -d --build

up-mcp:
	@echo "Starting MCP server..."
	docker compose up -d mcp-server

down: ## Stop and remove all containers, networks, and volumes
	@echo "Stopping and removing all services..."
	docker compose down -v

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
mysql-shell: ## Access MySQL shell
	docker compose exec mysql mysql -u $(MYSQL_USER) -p$(MYSQL_PASSWORD) $(MYSQL_DATABASE)

mysql-root: ## Access MySQL as root
	docker compose exec mysql mysql -u root -p$(MYSQL_ROOT_PASSWORD)

# Test data generation
generate-test-data: ## Generate 10M rows and perform 1M transactions for testing
	@echo "Generating test data..."
	uv run python scripts/generate_test_data.py
	@echo "Test data generation completed!"

generate-test-data-docker: ## Generate test data using Docker container
	@echo "Generating test data using Docker..."
	docker compose exec mcp-server python scripts/generate_test_data.py
	@echo "Test data generation completed!"

verify-bad-practices: ## Verify that bad practices are present in the database
	@echo "Verifying bad practices in database..."
	uv run python scripts/verify_bad_practices.py

verify-bad-practices-docker: ## Verify bad practices using Docker container
	@echo "Verifying bad practices using Docker..."
	docker compose exec mcp-server python scripts/verify_bad_practices.py

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

clean-data: ## Remove only data volumes (keeps images)
	@echo "Removing data volumes..."
	docker compose down -v
	@echo "Data volumes removed!"

# Development with admin tools
up-with-admin: ## Start services including phpMyAdmin
	@echo "Starting services with phpMyAdmin..."
	docker compose --profile admin up -d

inspector:
	npx @modelcontextprotocol/inspector

# Environment variables (can be overridden)
MYSQL_ROOT_PASSWORD ?= rootpassword
MYSQL_DATABASE ?= mcp_database
MYSQL_USER ?= mcp_user
MYSQL_PASSWORD ?= mcp_password
