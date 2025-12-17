.PHONY: help start start-prod build stop restart logs console bash db-reset db-migrate db-seed test clean status

# Default target
help:
	@echo "Urganise - Docker Commands"
	@echo ""
	@echo "Available targets:"
	@echo "  make start        - Start the application (development)"
	@echo "  make start-prod   - Start the application (production)"
	@echo "  make build        - Build production image"
	@echo "  make stop         - Stop the application"
	@echo "  make restart      - Restart the application"
	@echo "  make logs         - View logs"
	@echo "  make console      - Open Rails console"
	@echo "  make bash         - Open bash terminal"
	@echo "  make db-reset     - Reset database"
	@echo "  make db-migrate   - Run migrations"
	@echo "  make db-seed      - Load demo data"
	@echo "  make test         - Run tests"
	@echo "  make clean        - Clean containers and volumes"
	@echo "  make status       - Check container status"
	@echo ""
	@echo "Or use: ./docker-helper.sh [command]"

start:
	@echo "🚀 Starting Urganise (development)..."
	@docker-compose up --build -d
	@echo "✓ Urganise is running at http://localhost:3000"

start-prod:
	@echo "🚀 Starting Urganise (production)..."
	@if [ ! -f .env.production ]; then \
		echo "Creating .env.production..."; \
		cp .env.production.example .env.production; \
		echo "⚠️  Edit .env.production with secure values!"; \
	fi
	@docker-compose -f docker-compose.prod.yml --env-file .env.production up --build -d
	@echo "✓ Urganise is running at http://localhost:3000"

build:
	@echo "🔨 Building production image..."
	@docker-compose -f docker-compose.prod.yml build --no-cache
	@echo "✓ Production image built successfully"

stop:
	@echo "🛑 Stopping Urganise..."
	@docker-compose down 2>/dev/null || true
	@docker-compose -f docker-compose.prod.yml down 2>/dev/null || true
	@echo "✓ Urganise stopped"

restart:
	@echo "🔄 Restarting Urganise..."
	@docker-compose restart
	@echo "✓ Urganise restarted"

logs:
	@docker-compose logs -f

console:
	@docker-compose exec web rails console

bash:
	@docker-compose exec web bash

db-reset:
	@echo "⚠️  WARNING: This will delete all data!"
	@read -p "Are you sure? [y/N]: " confirm && [ "$$confirm" = "y" ] || exit 1
	@docker-compose exec web rails db:drop db:create db:migrate db:seed
	@echo "✓ Database reset complete"

db-migrate:
	@docker-compose exec web rails db:migrate
	@echo "✓ Migrations complete"

db-seed:
	@docker-compose exec web rails db:seed
	@echo "✓ Demo data loaded"

test:
	@docker-compose exec web rails test

clean:
	@echo "⚠️  WARNING: This will remove containers, volumes, and images!"
	@read -p "Are you sure? [y/N]: " confirm && [ "$$confirm" = "y" ] || exit 1
	@docker-compose down -v --rmi local
	@echo "✓ Cleanup complete"

status:
	@docker-compose ps
	@echo ""
	@docker stats --no-stream
