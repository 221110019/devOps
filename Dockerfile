FROM php:8.2-fpm

# ---------- System Setup ----------
RUN apt-get update && apt-get install -y \
    nginx mariadb-server-core supervisor curl git unzip libpng-dev libjpeg-dev libfreetype6-dev libzip-dev \
    && docker-php-ext-install pdo pdo_mysql mbstring gd zip bcmath \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# ---------- Workdir & Code ----------
WORKDIR /var/www/html
COPY . .

# ---------- Composer ----------
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
RUN composer install --no-dev --optimize-autoloader

# ---------- Laravel Prep ----------
RUN cp .env.example .env \
    && php artisan key:generate \
    && php artisan optimize \
    && php artisan storage:link

# ---------- Nginx & Supervisor ----------
COPY ./docker/nginx.conf /etc/nginx/nginx.conf
COPY ./docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 80

# ---------- Entrypoint ----------
CMD service nginx start && \
    mysqld_safe --skip-networking=0 --bind-address=0.0.0.0 & \
    php artisan migrate --force && \
    php artisan serve --host=0.0.0.0 --port=80
