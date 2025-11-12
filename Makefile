# SPLANTS Marketing Engine - Makefile
# Convenient commands for development and deployment

# Auto-detect Docker Compose command (plugin vs standalone)
DOCKER_COMPOSE := $(shell docker compose version > /dev/null 2>&1 && echo "docker compose" || echo "docker-compose")

.PHONY: help
help: ## Show this help message
	@echo "SPLANTS Marketing Engine - Command Reference"
	@echo "============================================"
	@echo ""
	@echo "Usage: make [command]"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

.PHONY: start
start: ## First-time setup and start (runs interactive wizard)
	@echo "Starting SPLANTS Marketing Engine..."
	@if [ ! -f .env ]; then \
		./scripts_quick-start.sh; \
	else \
		echo "Configuration exists. Starting services..."; \
		$(DOCKER_COMPOSE) up -d; \
		echo ""; \
		echo "✅ Services started!"; \
		echo "   Web UI:    http://localhost:3000"; \
		echo "   API Docs:  http://localhost:3000/api/docs"; \
	fi

.PHONY: setup
setup: ## Alias for 'start' - runs interactive setup wizard
	@$(MAKE) start

.PHONY: stop
stop: ## Stop all services
	@echo "Stopping services..."
	@$(DOCKER_COMPOSE) down
	@echo "✅ Services stopped"

.PHONY: restart
restart: ## Restart all services
	@echo "Restarting services..."
	@$(DOCKER_COMPOSE) restart
	@echo "✅ Services restarted"

.PHONY: logs
logs: ## View application logs (follow mode)
	@$(DOCKER_COMPOSE) logs -f

.PHONY: logs-app
logs-app: ## View app service logs only
	@$(DOCKER_COMPOSE) logs -f app

.PHONY: logs-web
logs-web: ## View web service logs only
	@$(DOCKER_COMPOSE) logs -f web

.PHONY: logs-db
logs-db: ## View database logs only
	@$(DOCKER_COMPOSE) logs -f db

.PHONY: status
status: ## Check service status
	@$(DOCKER_COMPOSE) ps

.PHONY: clean
clean: ## Remove containers and volumes (WARNING: deletes data)
	@echo "WARNING: This will delete all data!"
	@read -p "Are you sure? (y/N): " confirm && [ "$$confirm" = "y" ] && $(DOCKER_COMPOSE) down -v || echo "Cancelled"

.PHONY: backup
backup: ## Backup database
	@./scripts_backup.sh

.PHONY: restore
restore: ## Restore database from backup
	@if [ -z "$(file)" ]; then \
		echo "Usage: make restore file=<backup-file>"; \
		echo ""; \
		echo "Available backups:"; \
		ls -la ./backups/*.sql.gz 2>/dev/null || echo "No backups found"; \
	else \
		./scripts_restore.sh $(file); \
	fi

.PHONY: test
test: ## Run API tests (validates backend-frontend contract)
	@echo "Running API tests..."
	@python3 test_api.py

.PHONY: shell
shell: ## Open Python shell in app container
	@$(DOCKER_COMPOSE) exec app python

.PHONY: db-shell
db-shell: ## Open PostgreSQL shell
	@$(DOCKER_COMPOSE) exec db psql -U splants splants

.PHONY: update
update: ## Pull latest changes and rebuild
	@echo "Updating SPLANTS Marketing Engine..."
	@git pull
	@$(DOCKER_COMPOSE) build --no-cache
	@$(DOCKER_COMPOSE) up -d
	@echo "✅ Update complete!"

.PHONY: dev
dev: ## Start in development mode (attached, with logs)
	@$(DOCKER_COMPOSE) up

.PHONY: build
build: ## Build Docker images
	@echo "Building Docker images..."
	@$(DOCKER_COMPOSE) build
	@echo "✅ Build complete"

.PHONY: rebuild
rebuild: ## Rebuild Docker images (no cache)
	@echo "Rebuilding Docker images (no cache)..."
	@$(DOCKER_COMPOSE) build --no-cache
	@echo "✅ Rebuild complete"

.PHONY: monitor
monitor: ## Monitor resource usage
	@docker stats