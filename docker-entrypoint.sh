#!/bin/bash

set -e

echo "Starting application setup..."

# Wait for database to be ready
echo "Waiting for database..."
while ! nc -z laravel-db 3306; do
  sleep 1
done
echo "Database is ready!"

# Copy environment file if it doesn't exist in the container
if [ ! -f .env ]; then
    echo "Copying .env.example to .env..."
    cp .env.example .env
fi

# Generate application key if not set
if ! grep -q "APP_KEY=base64:" .env; then
    echo "Generating application key..."
    php artisan key:generate --force
    echo "Application key generated successfully!"
fi

# Run database migrations
echo "Running database migrations..."
php artisan migrate --force
echo "Migrations completed successfully!"

# Seed the database
echo "Seeding database..."
php artisan db:seed --force
echo "Database seeding completed successfully!"

# Create storage link
echo "Creating storage link..."
php artisan storage:link --force
echo "Storage link created successfully!"

# Clear and cache config
echo "Caching configuration..."
php artisan config:cache
php artisan route:cache
php artisan view:cache
echo "Configuration cached successfully!"

echo "Application setup completed!"

# Start PHP-FPM
exec "$@"