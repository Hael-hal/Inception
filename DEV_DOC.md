# Developer Documentation

## 1. Environment Setup
- Ensure Docker, Docker Compose, and Make are installed.
- Ensure `srcs/.env` and `secrets/` files are present.
- Create local persistent data folders:
  ```bash
  mkdir -p /home/hhamza/data/mariadb /home/hhamza/data/wordpress
  ```

## 2. Build & Launch
- **Build and start**: `make`
- **Rebuild images**: `make build`
- **Tear down stack**: `make down`
- **Full reset**: `make fclean`

## 3. Manage Containers & Volumes
- **Check container status**: `docker compose -f srcs/docker-compose.yml ps`
- **View logs**: `docker compose -f srcs/docker-compose.yml logs -f`
- **Inspect named volumes**: `docker volume inspect mariadb_data wordpress_data`

## 4. Data Storage & Persistence
- **MariaDB Database**: Persisted on host at `/home/hhamza/data/mariadb` via named volume `mariadb_data`.
- **WordPress Files**: Persisted on host at `/home/hhamza/data/wordpress` via named volume `wordpress_data`.
- Stopping containers (`make down`) does NOT erase data. Only `make fclean` removes the `/home/hhamza/data` directories.
