FROM php:8.1.18-fpm AS php-builder

# Install dependensi PHP dan PHP-FPM
RUN apt-get update && apt-get install -y \
    libzip-dev \
    unzip \
    libpq-dev

RUN docker-php-ext-install pdo pdo_pgsql

# Set working directory
WORKDIR /app

RUN php artisan route:clear

RUN php artisan cache:clear

RUN php artisan optimize:clear

EXPOSE 8081

CMD ["php-fpm"]