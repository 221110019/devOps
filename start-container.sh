#!/bin/bash
set -e

echo "Waiting for database..."
while ! nc -z mysql 3306; do
    sleep 2
done
echo "Database is ready!"

sleep 3

# Setup application
if [ ! -f .env ]; then
    cp .env.example .env
fi

php artisan key:generate --force
php artisan migrate --force
php artisan storage:link --force
php artisan config:cache
php artisan route:cache

echo "Application is ready!"

# Start PHP development server
exec php artisan serve --host=0.0.0.0 --port=80