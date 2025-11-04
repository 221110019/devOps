# --- Build stage: Node ---
FROM node:20 AS nodebuild
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# --- Build stage: Composer ---
FROM composer:2.8 AS composerbuild
WORKDIR /app
COPY . .
RUN composer install --no-dev --optimize-autoloader

# --- Final image ---
FROM php:8.3-apache
WORKDIR /var/www/html

COPY --from=composerbuild /app ./
COPY --from=nodebuild /app/public ./public
RUN docker-php-ext-install pdo pdo_mysql

EXPOSE 80

ENTRYPOINT ["sh", "-c", "cp .env.example .env && php artisan key:generate && php artisan migrate --force && php artisan storage:link && apache2-foreground"]
