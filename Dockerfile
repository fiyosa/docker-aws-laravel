FROM php:8.1.18-fpm

COPY --from=composer:2.5.5 /usr/bin/composer /usr/bin/composer

# Install dependensi PHP dan PHP-FPM
RUN apt-get update && apt-get install -y \
    git \
    zip \
    unzip \
    libpq-dev

RUN docker-php-ext-install pdo pdo_pgsql

# Set working directory
WORKDIR /var/www/html

# Copy file composer.json dan composer.lock ke dalam container
COPY ./ ./

# Install dependencies menggunakan Composer
RUN composer install --no-scripts --no-autoloader

# Autoload Composer
RUN composer dump-autoload --optimize

RUN php artisan route:clear

RUN php artisan cache:clear

RUN php artisan optimize:clear

CMD ['php','artisan','serve']

EXPOSE 8081