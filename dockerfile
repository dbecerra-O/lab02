FROM php:8.2-apache

# 1. Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    git \
    zip \
    unzip \
    libzip-dev \
    libpng-dev \
    libonig-dev \
    && docker-php-ext-install pdo pdo_mysql mbstring zip exif pcntl bcmath gd

# 2. Configurar Apache
RUN a2enmod rewrite
COPY .docker/apache.conf /etc/apache2/sites-available/000-default.conf

# 3. Preparar directorio de trabajo
WORKDIR /var/www/html
COPY . .

# 4. Instalar Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# 5. Generar APP_KEY si no existe (SOLUCIÓN CLAVE)
RUN if [ ! -f .env ]; then \
        cp .env.example .env && \
        php artisan key:generate; \
    else \
        if ! grep -q '^APP_KEY=base64:' .env; then \
            php artisan key:generate; \
        fi; \
    fi

# 6. Instalar dependencias de Composer
RUN composer install --no-dev --optimize-autoloader

# 7. Configurar permisos
RUN chown -R www-data:www-data storage bootstrap/cache
RUN chmod -R 775 storage bootstrap/cache

# 8. Configurar variables de entorno para producción
RUN sed -i 's/^APP_DEBUG=.*/APP_DEBUG=false/' .env && \
    sed -i 's/^APP_ENV=.*/APP_ENV=production/' .env