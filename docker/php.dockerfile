FROM php:8.1.18-zts-alpine3.17

# Set working directory
WORKDIR /var/www/html

# Install dependensi PHP dan PHP-FPM
RUN apt-get update && apt-get install -y \
    libzip-dev \
    unzip \
    && docker-php-ext-install zip
    
RUN php artisan route:clear

RUN php artisan cache:clear

RUN php artisan optimize:clear

RUN docker-php-ext-install pdo pdo_pgsql