# Developer Documentation (DEV_DOC.md)

This technical documentation is intended for developers maintaining, extending, and auditing the **Inception** infrastructure codebase.

---

## 1. Environment Setup from Scratch

### Prerequisites
- **Host OS**: Linux (Debian/Ubuntu/Arch) or macOS.
- **Docker Engine**: `20.10.0+`
- **Docker Compose Plugin**: `v2.0.0+` (`docker compose`)
- **GNU Make**: `3.81+`
- **OpenSSL**: For manual certificate verification if needed.

### Configuration Files & Secrets Setup
1. **Repository Structure**:
   Ensure the following file layout exists:
   ```bash
   ├── Makefile
   ├── secrets/
   │   ├── credentials.txt
   │   ├── db_password.txt
   │   ├── db_root_password.txt
   │   ├── wp_admin_password.txt
   │   └── wp_user_password.txt
   └── srcs/
       ├── .env
       ├── docker-compose.yml
       └── requirements/
           ├── mariadb/
           ├── nginx/
           └── wordpress/
   ```

2. **Environment Variables (`srcs/.env`)**:
   Copy the provided `.env.example` template:
   ```bash
   cp srcs/.env.example srcs/.env
   ```
   Customize variables as required:
   - `LOGIN`: The 42 intranet login (e.g. `hhamza`).
   - `DOMAIN_NAME`: Domain name matching `<login>.42.fr`.
   - `MYSQL_DATABASE`: MariaDB database name.
   - `MYSQL_USER`: MariaDB non-root user.
   - `WP_TITLE`: Website display title.
   - `WP_ADMIN_USER`: Admin username (must NOT contain `admin` or `administrator`).
   - `WP_USER`: Secondary WordPress author username.

3. **Docker Secrets Setup**:
   Secret files in `secrets/` are automatically initialized by `make prepare` if absent, or can be filled with custom passwords:
   ```bash
   echo "custom_secure_user_pass" > secrets/db_password.txt
   echo "custom_secure_root_pass" > secrets/db_root_password.txt
   echo "custom_secure_admin_pass" > secrets/wp_admin_password.txt
   echo "custom_secure_author_pass" > secrets/wp_user_password.txt
   ```

4. **Host Data Storage Directory Preparation**:
   Create the required host directory structure matching the volume configuration:
   ```bash
   sudo mkdir -p /home/${LOGIN}/data/mariadb
   sudo mkdir -p /home/${LOGIN}/data/wordpress
   ```

---

## 2. Building & Launching the Infrastructure

### Lifecycle via Makefile
The `Makefile` at the repository root orchestrates all container builds and compose commands:

- **Full Setup & Start**:
  ```bash
  make
  ```
  *Executes directory preparation, builds all images from custom Dockerfiles (`debian:bullseye`), and starts the containers in detached mode.*

- **Rebuilding Containers**:
  ```bash
  make build
  ```
  *Re-triggers Dockerfile builds with caching.*

- **Foreground Log Tracing**:
  ```bash
  make logs
  ```

---

## 3. Container, Volume, and Network Management

### Useful Developer CLI Commands

#### Inspecting Running Processes
```bash
# View active containers
docker compose -f srcs/docker-compose.yml ps

# Inspect detailed container attributes
docker inspect mariadb
docker inspect wordpress
docker inspect nginx
```

#### Entering Container Shells (Debugging)
```bash
# Access NGINX container shell
docker exec -it nginx /bin/bash

# Access WordPress container shell
docker exec -it wordpress /bin/bash

# Access MariaDB container shell
docker exec -it mariadb /bin/bash
```

#### Verifying Database State via CLI
```bash
# Log in directly to MariaDB inside the database container
docker exec -it mariadb mariadb -uwp_user -pmariadb_user_password_42 wordpress_db -e "SHOW TABLES;"
```

#### Inspecting Networks & Volume Drivers
```bash
# Inspect custom bridge network
docker network inspect inception_network

# Inspect named volume bindings
docker volume inspect mariadb_data
docker volume inspect wordpress_data
```

---

## 4. Data Persistence & Storage Architecture

### How Persistence Works
Persistent data is decoupled from container life cycles using **Docker Named Volumes** configured with the `local` driver and `bind` driver options:

```yaml
volumes:
  mariadb_data:
    name: mariadb_data
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/${LOGIN}/data/mariadb

  wordpress_data:
    name: wordpress_data
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/${LOGIN}/data/wordpress
```

### Storage Locations on Host Machine
| Volume Name | Container Path | Host Persistence Path | Content Description |
| :--- | :--- | :--- | :--- |
| `mariadb_data` | `/var/lib/mysql` | `/home/${LOGIN}/data/mariadb` | InnoDB database tables, schemas, user privileges |
| `wordpress_data` | `/var/www/wordpress` | `/home/${LOGIN}/data/wordpress` | PHP source code, `wp-config.php`, uploads, themes, plugins |

### Data Persistence Test
1. Make changes to the WordPress site (create a post or change settings).
2. Stop and remove all containers: `make down`
3. Re-launch the containers: `make up`
4. Refresh `https://${LOGIN}.42.fr` — the newly created content remains intact because data is stored on `/home/${LOGIN}/data/`.

### Complete Stack Reset (`fclean`)
To wipe all state, delete persistent storage, and trigger a clean installation on next launch:
```bash
make fclean
```
