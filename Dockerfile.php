FROM 8.1.18-fpm AS php-builder

RUN apt-get update && apt-get install -y \
    git \
    zip \
    unzip

# Set working directory
WORKDIR /app

# Copy file composer.json
COPY --from=composer-builder /app ./

# Install dependensi PHP dan PHP-FPM
RUN apt-get update && apt-get install -y \
    libzip-dev \
    unzip \
    && docker-php-ext-install zip

RUN docker-php-ext-install pdo pdo_pgsql

RUN php artisan route:clear

RUN php artisan cache:clear

RUN php artisan optimize:clear
