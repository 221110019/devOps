FROM laravelsail/php82-composer:latest

WORKDIR /var/www/html

COPY . .

RUN cp .env.example .env \
    && composer install --no-dev --optimize-autoloader \
    && npm install && npm run build \
    && php artisan key:generate \
    && php artisan storage:link

EXPOSE 80 5173

CMD ["./vendor/bin/sail", "up", "-d"]
