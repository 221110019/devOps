# ---------- Base Image ----------
FROM php:8.2-fpm

# ---------- System Setup ----------
RUN apt-get update && apt-get install -y \
    nginx default-mysql-server supervisor curl git unzip libpng-dev libjpeg-dev libfreetype6-dev libzip-dev \
    && docker-php-ext-install pdo pdo_mysql mbstring gd zip bcmath \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html

# ---------- Copy Application ----------
COPY . .

# ---------- Composer ----------
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
RUN composer install --no-dev --optimize-autoloader

# ---------- Laravel Setup ----------
RUN cp .env.example .env \
    && php artisan key:generate \
    && php artisan optimize \
    && php artisan storage:link

# ---------- Nginx ----------
RUN rm /etc/nginx/sites-enabled/default
COPY ./nginx.conf /etc/nginx/conf.d/default.conf

# ---------- Supervisor ----------
COPY ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# ---------- MySQL Setup ----------
RUN service mysql start && mysql -e "CREATE DATABASE IF NOT EXISTS laravel;" \
    && mysql -e "CREATE USER IF NOT EXISTS 'sail'@'localhost' IDENTIFIED BY 'password';" \
    && mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'sail'@'localhost'; FLUSH PRIVILEGES;"

# ---------- Expose & Start ----------
EXPOSE 80
CMD ["/usr/bin/supervisord", "-n"]
