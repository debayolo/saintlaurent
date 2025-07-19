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

# Copy application files
COPY . .

# Ensure cache and storage directories exist
RUN mkdir -p bootstrap/cache storage/logs storage/framework && \
    chown -R www-data:www-data bootstrap storage && \
    chmod -R 775 bootstrap storage

# Install Laravel dependencies
RUN composer install --no-dev --optimize-autoloader --no-scripts

# Laravel permissions
RUN chown -R www-data:www-data /var/www && \
    chmod -R 775 storage bootstrap/cache

# Expose port for Laravel development server
EXPOSE 8000

# Start Laravel’s built-in server
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
