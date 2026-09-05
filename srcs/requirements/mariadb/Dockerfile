FROM debian:bullseye

RUN apt-get update && apt-get install -y --no-install-recommends \
    mariadb-server \
    mariadb-client \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/run/mysqld /run/mysqld /var/lib/mysql && \
    chown -R mysql:mysql /var/run/mysqld /run/mysqld /var/lib/mysql && \
    chmod 777 /var/run/mysqld /run/mysqld

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY tools/mariadb.sh /usr/local/bin/mariadb.sh
RUN chmod +x /usr/local/bin/mariadb.sh

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/mariadb.sh"]
