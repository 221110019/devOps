FROM php:8.2-fpm

# Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
    zip unzip git curl libpng-dev libjpeg-dev libfreetype6-dev libonig-dev libxml2-dev libzip-dev \
    && docker-php-ext-install pdo pdo_mysql mbstring exif pcntl bcmath gd zip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /var/www/html

# Copy Laravel project into image
COPY . .

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Install dependencies
RUN composer install --no-dev --optimize-autoloader

# Generate app key and optimize
RUN cp .env.example .env \
    && php artisan key:generate \
    && php artisan optimize \
    && php artisan storage:link

# Expose port and start Laravel server
EXPOSE 80
ENTRYPOINT ["php", "artisan", "serve", "--host=0.0.0.0", "--port=80"]
