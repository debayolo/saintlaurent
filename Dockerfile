FROM php:8.2-fpm

# Install system dependencies and PHP extensions (no nginx)
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

# Set permissions for Laravel directories including public
RUN chown -R www-data:www-data /var/www && \
    chmod -R 755 /var/www/public && \
    chmod -R 775 storage bootstrap/cache

# Install Laravel dependencies
RUN composer install --no-dev --optimize-autoloader --no-scripts

# Expose port 8000 for Laravel's built-in server
EXPOSE 8000

# Start Laravel's built-in development server
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
