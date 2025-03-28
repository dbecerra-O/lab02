FROM php:8.2-apache

# 1. Instalar dependencias
RUN apt-get update && apt-get install -y \
    git \
    zip \
    unzip \
    libzip-dev \
    && docker-php-ext-install pdo_mysql zip

# 2. Configurar Apache
RUN a2enmod rewrite
COPY .docker/apache.conf /etc/apache2/sites-available/000-default.conf

# 3. Preparar directorio
WORKDIR /var/www/html
COPY . .

# 4. Instalar Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer install --no-dev --optimize-autoloader

# 5. Configurar permisos y variables
RUN chown -R www-data:www-data storage bootstrap/cache
RUN chmod -R 775 storage bootstrap/cache