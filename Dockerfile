FROM node:20 AS nodebuild
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

FROM composer:2.7 AS composerbuild
WORKDIR /app
COPY . .
RUN composer install --no-dev --optimize-autoloader

FROM php:8.3-apache
WORKDIR /var/www/html

COPY --from=composerbuild /app ./
COPY --from=nodebuild /app/public ./public

RUN docker-php-ext-install pdo pdo_mysql
RUN php artisan key:generate && php artisan migrate --force && php artisan storage:link

EXPOSE 80
CMD ["apache2-foreground"]
