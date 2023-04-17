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
WORKDIR /var/www/html

# Copy file composer.json dan composer.lock ke dalam container
COPY ./ ./

# Install dependencies menggunakan Composer
RUN composer install --no-scripts --no-autoloader --no-progress --no-interaction

# Autoload Composer
RUN composer dump-autoload --optimize

RUN php artisan route:clear

RUN php artisan cache:clear

RUN php artisan optimize:clear

EXPOSE 8081

CMD ["php-fpm", "-y", "/usr/local/etc/php-fpm.conf", "-R"]