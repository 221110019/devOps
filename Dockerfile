# Frontend build stage with Node.js 20
FROM node:20 as frontend

WORKDIR /var/www

# Copy package files first for better caching
COPY package*.json ./
RUN npm install

# Copy source files and build
COPY . .
RUN npm run build

# PHP stage
FROM php:8.2-fpm

WORKDIR /var/www

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    libzip-dev \
    default-mysql-client \
    nano \
    netcat-openbsd \
    && docker-php-ext-install \
    pdo_mysql \
    mbstring \
    exif \
    pcntl \
    bcmath \
    gd \
    zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy application code
COPY . .

# Copy built assets from frontend stage
COPY --from=frontend /var/www/public/build /var/www/public/build

# Create storage directories with proper permissions
RUN mkdir -p storage/framework/{sessions,views,cache} storage/logs \
    && chown -R www-data:www-data /var/www \
    && chmod -R 775 storage bootstrap/cache

# Install PHP dependencies
RUN composer install --no-scripts --no-autoloader --optimize-autoloader

# Generate optimized autoloader
RUN composer dump-autoload --optimize

EXPOSE 9000

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

USER www-data

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["php-fpm"]