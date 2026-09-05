#!/bin/bash
set -e

# Retrieve WordPress and MariaDB passwords from Docker secrets if available
if [ -f "/run/secrets/db_password" ]; then
    MYSQL_PASSWORD=$(cat /run/secrets/db_password)
elif [ -n "$MYSQL_PASSWORD_FILE" ] && [ -f "$MYSQL_PASSWORD_FILE" ]; then
    MYSQL_PASSWORD=$(cat "$MYSQL_PASSWORD_FILE")
fi

if [ -f "/run/secrets/wp_admin_password" ]; then
    WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
elif [ -n "$WP_ADMIN_PASSWORD_FILE" ] && [ -f "$WP_ADMIN_PASSWORD_FILE" ]; then
    WP_ADMIN_PASSWORD=$(cat "$WP_ADMIN_PASSWORD_FILE")
fi

if [ -f "/run/secrets/wp_user_password" ]; then
    WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)
elif [ -n "$WP_USER_PASSWORD_FILE" ] && [ -f "$WP_USER_PASSWORD_FILE" ]; then
    WP_USER_PASSWORD=$(cat "$WP_USER_PASSWORD_FILE")
fi

cd /var/www/wordpress

# Wait for MariaDB database to be ready and accepting connections
echo "==> [WordPress] Waiting for MariaDB database connection on mariadb:3306..."
until mariadb-admin ping -h"mariadb" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" --silent; do
    sleep 2
done
echo "==> [WordPress] MariaDB connection successfully verified."

# Initialize WordPress if wp-config.php is not present
if [ ! -f "wp-config.php" ]; then
    echo "==> [WordPress] Downloading WordPress core..."
    wp core download --allow-root --path=/var/www/wordpress

    echo "==> [WordPress] Generating wp-config.php..."
    wp config create \
        --allow-root \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${MYSQL_PASSWORD}" \
        --dbhost="mariadb:3306" \
        --path=/var/www/wordpress

    echo "==> [WordPress] Installing WordPress core and creating administrator user (${WP_ADMIN_USER})..."
    wp core install \
        --allow-root \
        --url="https://${DOMAIN_NAME}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --path=/var/www/wordpress

    echo "==> [WordPress] Creating secondary user (${WP_USER})..."
    wp user create \
        "${WP_USER}" \
        "${WP_USER_EMAIL}" \
        --role=author \
        --user_pass="${WP_USER_PASSWORD}" \
        --allow-root \
        --path=/var/www/wordpress

    chown -R www-data:www-data /var/www/wordpress
    chmod -R 755 /var/www/wordpress
    echo "==> [WordPress] WordPress initialization completed successfully."
fi

mkdir -p /run/php
chown -R www-data:www-data /run/php

echo "==> [WordPress] Starting PHP-FPM (FastCGI Process Manager) on port 9000..."
exec php-fpm7.4 -F
