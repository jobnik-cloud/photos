# Build stage - compile frontend assets and install PHP dependencies
FROM node:24-alpine AS builder

WORKDIR /app

# Install PHP and composer for PHP dependencies
RUN apk add --no-cache php83 php83-phar php83-openssl php83-mbstring php83-xml php83-curl php83-zip php83-dom php83-tokenizer php83-xmlwriter php83-fileinfo php83-intl
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copy package files
COPY package*.json ./

# Install Node dependencies
RUN npm ci

# Copy source code
COPY . .

# Build the app (frontend assets)
RUN npm run build

# Install PHP dependencies via composer
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Runtime image - lightweight Alpine
FROM alpine:latest

WORKDIR /app

# Install bash for shell scripts
RUN apk add --no-cache bash

# Copy all necessary app files from builder
# Standard Nextcloud app structure
COPY --from=builder /app/appinfo ./appinfo/
COPY --from=builder /app/lib ./lib/
COPY --from=builder /app/js ./js/
COPY --from=builder /app/css ./css/
COPY --from=builder /app/l10n ./l10n/
COPY --from=builder /app/img ./img/
COPY --from=builder /app/templates ./templates/

# Copy composer directory and vendor directory (required for autoload)
COPY --from=builder /app/composer ./composer/
COPY --from=builder /app/vendor ./vendor/

# Set correct ownership (www-data user = 33:33)
RUN chown -R 33:33 /app

# Default command (not really used, but good practice)
CMD ["/bin/sh"]

