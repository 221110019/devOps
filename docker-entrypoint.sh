#!/bin/bash

set -e

echo "Starting application setup..."

# Wait for database
echo "Waiting for database..."
while ! nc -z laravel-db 3306; do
    sleep 2
done
echo "Database is ready!"

sleep 5

# Setup .env
if [ ! -f .env ]; then
    cp .env.example .env
fi

# Set database config
sed -i "s/DB_HOST=.*/DB_HOST=laravel-db/" .env
sed -i "s/DB_DATABASE=.*/DB_DATABASE=laravel/" .env
sed -i "s/DB_USERNAME=.*/DB_USERNAME=laravel/" .env
sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=secret/" .env

# Generate key
php artisan key:generate --force

# Run migrations
php artisan migrate --force

# Seed if needed (optional)
php artisan db:seed --force || true

# Create storage link
php artisan storage:link --force

# Cache config
php artisan config:cache
php artisan route:cache

echo "Application ready!"

exec "$@"