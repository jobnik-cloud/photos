# Build stage - compile frontend assets
FROM node:24-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy source code
COPY . .

# Build the app
RUN npm run build

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

# Copy composer directory
COPY --from=builder /app/composer ./composer/

# Set correct ownership (www-data user = 33:33)
RUN chown -R 33:33 /app

# Default command (not really used, but good practice)
CMD ["/bin/sh"]

