# Stage 1: Build assets
FROM node:23 AS frontend
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Stage 2: Laravel app
FROM laravelsail/php82-composer:latest
WORKDIR /var/www/html

COPY . .
COPY --from=frontend /app/public/build ./public/build

RUN cp .env.example .env \
    && composer install --no-dev --optimize-autoloader \
    && php artisan key:generate \
    && php artisan storage:link
RUN docker-php-ext-install pdo pdo_mysql
EXPOSE 80 5173
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=80"]

