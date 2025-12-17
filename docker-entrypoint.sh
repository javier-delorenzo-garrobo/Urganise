#!/bin/bash
set -e

# Wait for database to be ready
echo "🚀 Starting Urganise..."
echo "⏳ Waiting for PostgreSQL..."

# Simple wait using nc (netcat)
while ! nc -z db 5432; do
  sleep 0.5
done

echo "✓ PostgreSQL is ready!"

# Create database if it doesn't exist
bundle exec rails db:create 2>/dev/null || true

# Run migrations
echo "Running database migrations..."
bundle exec rails db:migrate

# Seed database if needed (only in development)
if [ "$RAILS_ENV" = "development" ] && [ ! -f /rails/.db_seeded ]; then
  echo "Seeding database..."
  bundle exec rails db:seed
  touch /rails/.db_seeded
fi

# Remove server PID if it exists
if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi

# Execute the main command
exec "$@"
