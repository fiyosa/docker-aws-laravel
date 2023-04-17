FROM php:8.1.18-fpm

COPY --from=composer:2.5.5 /usr/bin/composer /usr/bin/composer
RUN chmod +x /usr/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER 1

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
RUN composer install --optimize-autoloader --no-interaction --no-progress

# Copy seluruh isi proyek Laravel ke dalam container
COPY . .

# Autoload Composer
RUN composer dump-autoload --optimize

RUN php artisan route:clear

RUN php artisan cache:clear

RUN php artisan optimize:clear

EXPOSE 8081