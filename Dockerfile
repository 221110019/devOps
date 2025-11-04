FROM composer:2.7 AS build

WORKDIR /app
COPY . .
RUN composer install --no-dev --optimize-autoloader
RUN npm install && npm run build

FROM php:8.3-apache

WORKDIR /var/www/html
COPY --from=build /app ./
RUN docker-php-ext-install pdo pdo_mysql
RUN php artisan key:generate && php artisan migrate --force && php artisan storage:link

EXPOSE 80
CMD ["apache2-foreground"]
