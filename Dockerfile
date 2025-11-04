# Base PHP image
FROM php:8.2-fpm

# System dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
    git unzip curl nodejs npm libpng-dev libjpeg-dev libfreetype6-dev libzip-dev \
    && docker-php-ext-install pdo pdo_mysql mbstring bcmath gd zip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /var/www/html

# Copy project files
COPY . .

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader

# Install frontend dependencies & build
RUN npm install && npm run build

# Setup Laravel app
RUN cp .env.example .env \
    && php artisan key:generate \
    && php artisan migrate --force \
    && php artisan db:seed --force \
    && php artisan storage:link

# Expose port
EXPOSE 80

# Start Laravel built-in server
ENTRYPOINT ["php", "artisan", "serve", "--host=0.0.0.0", "--port=80"]
