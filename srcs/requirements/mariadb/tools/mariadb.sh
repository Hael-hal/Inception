#!/bin/bash
set -e

# Retrieve MariaDB passwords from Docker secrets if available
if [ -f "/run/secrets/db_password" ]; then
    MYSQL_PASSWORD=$(cat /run/secrets/db_password)
elif [ -n "$MYSQL_PASSWORD_FILE" ] && [ -f "$MYSQL_PASSWORD_FILE" ]; then
    MYSQL_PASSWORD=$(cat "$MYSQL_PASSWORD_FILE")
fi

if [ -f "/run/secrets/db_root_password" ]; then
    MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
elif [ -n "$MYSQL_ROOT_PASSWORD_FILE" ] && [ -f "$MYSQL_ROOT_PASSWORD_FILE" ]; then
    MYSQL_ROOT_PASSWORD=$(cat "$MYSQL_ROOT_PASSWORD_FILE")
fi

mkdir -p /run/mysqld /var/lib/mysql
chown -R mysql:mysql /run/mysqld /var/lib/mysql
chmod 777 /run/mysqld

# First-time database initialization
if [ ! -d "/var/lib/mysql/mysql" ] || [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
    echo "==> [MariaDB] Initializing database files..."
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql > /dev/null

    echo "==> [MariaDB] Applying database users and permissions..."
    TMP_SQL_FILE=$(mktemp)
    if [ ! -f "$TMP_SQL_FILE" ]; then
        echo "Failed to create temporary SQL initialization file"
        exit 1
    fi

    cat << EOF > "$TMP_SQL_FILE"
USE mysql;
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED VIA mysql_native_password USING PASSWORD('${MYSQL_ROOT_PASSWORD}');
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\` CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

    # Execute SQL in bootstrap mode
    mariadbd --user=mysql --bootstrap < "$TMP_SQL_FILE"
    rm -f "$TMP_SQL_FILE"
    echo "==> [MariaDB] Database initialization completed successfully."
fi

echo "==> [MariaDB] Starting MariaDB server..."
exec mariadbd --user=mysql --console
