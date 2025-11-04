#!/bin/bash

set -e

echo "Starting application setup..."

# Function to wait for database
wait_for_db() {
    echo "Waiting for database at $DB_HOST:$DB_PORT..."
    while ! nc -z $DB_HOST $DB_PORT; do
        sleep 2
        echo "Still waiting for database..."
    done
    echo "Database is ready!"
}

# Wait for database
wait_for_db

# Additional wait to ensure MySQL is fully ready
echo "Giving MySQL extra time to initialize..."
sleep 10

# Copy environment file if it doesn't exist in the container
if [ ! -f .env ]; then
    echo "Copying .env.example to .env..."
    cp .env.example .env
fi

# Update .env with correct database host
echo "Setting up database configuration..."
sed -i "s/DB_HOST=.*/DB_HOST=laravel-db/" .env
sed -i "s/DB_DATABASE=.*/DB_DATABASE=laravel/" .env
sed -i "s/DB_USERNAME=.*/DB_USERNAME=laravel/" .env
sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=secret/" .env

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