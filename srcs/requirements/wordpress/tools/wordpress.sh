#!/bin/bash
set -e

MYSQL_PASSWORD=$(cat /run/secrets/db_password)

cd /var/www/wordpress

while ! mariadb-admin ping -h mariadb -u "${MYSQL_USER}" -p"${MYSQL_PASSWORD}" --silent; do
    sleep 2
done

if [ ! -f "wp-config.php" ]; then
    wp core download --allow-root
    wp config create --allow-root --dbname="${MYSQL_DATABASE}" --dbuser="${MYSQL_USER}" --dbpass="${MYSQL_PASSWORD}" --dbhost="mariadb:3306"
    wp core install --allow-root --url="https://${DOMAIN_NAME}" --title="Inception" --admin_user="${WP_ADMIN_USER}" --admin_password="${WP_ADMIN_PASSWORD}" --admin_email="${WP_ADMIN_EMAIL}"
    wp user create "${WP_USER}" "${WP_USER_EMAIL}" --role=author --user_pass="${WP_USER_PASSWORD}" --allow-root
    chown -R www-data:www-data /var/www/wordpress
fi

mkdir -p /run/php
exec /usr/sbin/php-fpm8.2 -F
