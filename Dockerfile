FROM php:8.1.18-fpm

COPY --from=composer:2.0 /usr/bin/composer /usr/bin/composer

# Install dependensi PHP dan PHP-FPM
RUN apt-get update && apt-get install -y \
    git \
    zip \
    unzip \
    libpq-dev

RUN docker-php-ext-install pdo pdo_pgsql

# Set working directory
WORKDIR /app

# Copy file composer.json dan composer.lock ke dalam container
COPY composer.json ./

# Install dependencies menggunakan Composer
RUN composer install --no-scripts --no-autoloader

# Copy seluruh isi proyek Laravel ke dalam container
COPY . .

# Autoload Composer
RUN composer dump-autoload --optimize

RUN php artisan route:clear

RUN php artisan cache:clear

RUN php artisan optimize:clear

EXPOSE 8081