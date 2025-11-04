FROM laravelsail/php82-composer:latest

WORKDIR /var/www/html

COPY . .

RUN composer install --no-dev --optimize-autoloader \
    && cp .env.example .env \
    && php artisan key:generate \
    && php artisan optimize \
    && php artisan storage:link

EXPOSE 80
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=80"]
