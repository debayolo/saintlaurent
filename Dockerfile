FROM php:8.2-fpm

# Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
    git curl libpng-dev libjpeg-dev libonig-dev libxml2-dev \
    libzip-dev zip unzip libpq-dev \
    && docker-php-ext-install pdo_mysql mbstring zip gd

# Install Composer
COPY --from=composer:2.6 /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www

# Copy application code
COPY . .

# Set permissions for Laravel
RUN chown -R www-data:www-data /var/www \
    && chmod -R 775 storage bootstrap/cache

# Install Laravel dependencies
RUN composer install --no-dev --optimize-autoloader --no-scripts

# Clear old caches (optional but good)
RUN php artisan config:clear && \
    php artisan cache:clear && \
    php artisan route:clear && \
    php artisan view:clear

# Expose FPM port (Render listens to port 10000 by default)
EXPOSE 9000

# Run PHP-FPM as the main process
CMD ["php-fpm"]
