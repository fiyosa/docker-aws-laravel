FROM php:8.1.18-zts-alpine3.17 AS php-builder

WORKDIR /app

COPY --from=composer-builder /app ./

RUN php artisan route:clear

RUN php artisan cache:clear

RUN php artisan optimize:clear

RUN docker-php-ext-install pdo pdo_pgsql