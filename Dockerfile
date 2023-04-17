FROM composer:2.5.5 AS composer-builder

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

# ==================================================================================

FROM php:8.1.18-fpm AS php-builder

# Install dependensi PHP dan PHP-FPM
RUN apt-get update && apt-get install -y \
    git \
    zip \
    unzip \
    libpq-dev

RUN docker-php-ext-install pdo pdo_pgsql

# Set working directory
WORKDIR /app

# Copy file composer.json
COPY --from=composer-builder /app ./

RUN php artisan route:clear

RUN php artisan cache:clear

RUN php artisan optimize:clear

FROM nginx:stable-alpine

COPY --from=php-builder /app /app

COPY ./nginx/default.conf /etc/nginx/conf.d/default.conf

EXPOSE 8080