FROM laravelsail/php82-composer:latest

WORKDIR /var/www/html

COPY . .
RUN composer install --no-dev --optimize-autoloader
RUN npm install
RUN npm run build
EXPOSE 80 5173

#CMD ["./vendor/bin/sail", "up"]
CMD ["php", "-v"]