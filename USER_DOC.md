# User Documentation

## 1. Services Provided
- **NGINX**: HTTPS entrypoint on port 443 (TLSv1.2 / TLSv1.3).
- **WordPress**: Web content management via PHP-FPM on port 9000.
- **MariaDB**: Relational database on port 3306.

## 2. Start and Stop
- **Start**: `make` or `make up`
- **Stop**: `make down`
- **Restart**: `docker compose -f srcs/docker-compose.yml restart`

## 3. Access Website & Admin Panel
- **Website**: `https://hhamza.42.fr`
- **Admin Panel**: `https://hhamza.42.fr/wp-admin`
  - Admin User: `hhamza_boss` (Password in `srcs/.env` / `secrets/credentials.txt`)
  - Author User: `simpleuser` (Password in `srcs/.env` / `secrets/credentials.txt`)

## 4. Credentials
- Located in `secrets/` directory (`db_password.txt`, `db_root_password.txt`, `credentials.txt`).

## 5. Check Services Running
```bash
docker compose -f srcs/docker-compose.yml ps
```
All containers (`mariadb`, `wordpress`, `nginx`) should report status `Up`.
