FROM composer:lts

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