# Use official PHP image with FPM
FROM php:8.2-fpm

# Set working directory
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
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
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

# Copy existing application directory contents
COPY . .

# Create storage directories with proper permissions
RUN mkdir -p storage/framework/{sessions,views,cache} storage/logs \
    && chown -R www-data:www-data /var/www \
    && chmod -R 775 storage bootstrap/cache

# Install PHP dependencies
RUN composer install --no-scripts --no-autoloader --optimize-autoloader

# Install npm dependencies and build assets
RUN if [ -f package.json ]; then \
    npm install && npm run build; \
    fi

# Generate optimized autoloader
RUN composer dump-autoload --optimize

# Expose port 9000 for PHP-FPM
EXPOSE 9000

# Create startup script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Switch to www-data user
USER www-data

ENTRYPOINT ["docker-entrypoint.sh"]

# Start PHP-FPM server
CMD ["php-fpm"]