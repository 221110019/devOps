FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y software-properties-common curl git unzip zip \
    && add-apt-repository -y ppa:ondrej/php \
    && apt-get update && apt-get install -y \
       php8.2-cli php8.2-mbstring php8.2-bcmath php8.2-curl php8.2-xml php8.2-mysql \
       nodejs npm \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
WORKDIR /var/www/html
COPY . .

RUN composer install --no-dev --optimize-autoloader
RUN npm install
RUN npm run build

RUN cp .env.example .env
RUN php artisan key:generate
RUN php artisan migrate --force
RUN php artisan db:seed
RUN php artisan storage:link

EXPOSE 80
CMD php -S 0.0.0.0:80 -t public
