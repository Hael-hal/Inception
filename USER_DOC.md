# User Documentation (USER_DOC.md)

This document provides a simple, straightforward guide for end users and administrators to operate, access, and manage the **Inception** infrastructure stack.

---

## 1. Services Provided by the Stack

The Inception infrastructure provides a complete, secure, multi-tier web application platform consisting of:

- **NGINX Web Server (Port 443 / HTTPS)**:
  - Serves as the single secure entrypoint for all incoming client traffic.
  - Enforces modern encrypted communications with **TLSv1.2** and **TLSv1.3**.
  - Routes static files and proxies PHP dynamic requests to the WordPress application layer.

- **WordPress + PHP-FPM Application Engine (Port 9000)**:
  - Executes WordPress PHP scripts via the FastCGI Process Manager (`php-fpm`).
  - Pre-configured with automatic installation, core WordPress files, and essential plugins.

- **MariaDB Relational Database (Port 3306)**:
  - Stores all WordPress articles, pages, comments, users, and site configurations.
  - Isolated within the internal container network for high data security.

---

## 2. Starting and Stopping the Project

All stack lifecycle operations are managed via simple `make` commands from the root directory:

### Starting the Stack
To build and start all services in the background:
```bash
make
# or
make up
```

### Stopping the Stack
To temporarily pause and stop active containers without destroying data:
```bash
make stop
```

### Restarting the Stack
To reboot all running services:
```bash
make restart
```

### Shutting Down the Stack
To stop and remove running containers while preserving all persistent data volumes:
```bash
make down
```

---

## 3. Accessing the Website and Administration Panel

### Host Domain Resolution
Ensure that the local domain is mapped in your system's `/etc/hosts` file:
```bash
127.0.0.1 hhamza.42.fr
```

### Accessing the Web Application
- **Public WordPress Website**:
  Navigate to [https://hhamza.42.fr](https://hhamza.42.fr) in your web browser.
- **WordPress Administration Panel**:
  Navigate to [https://hhamza.42.fr/wp-admin](https://hhamza.42.fr/wp-admin) to log in to the dashboard.

> [!NOTE]
> When accessing the site via HTTPS, your browser may present a warning that the SSL certificate is self-signed. Select **"Advanced"** -> **"Proceed to hhamza.42.fr (unsafe)"** to view the website.

---

## 4. Locating and Managing Credentials

All stack passwords and credentials are kept in the `secrets/` directory on the host machine:

| Credential Type | File Location | Purpose / Default Value |
| :--- | :--- | :--- |
| **Administrator Password** | `secrets/wp_admin_password.txt` | Login password for WordPress Admin (`chief_operator`) |
| **Regular User Password** | `secrets/wp_user_password.txt` | Login password for Author user (`staff_editor`) |
| **Database User Password** | `secrets/db_password.txt` | Database password for `wp_user` |
| **Database Root Password** | `secrets/db_root_password.txt` | Administrator password for MariaDB `root` |
| **Credentials Summary** | `secrets/credentials.txt` | Quick reference table for all users and usernames |

### Logging in as Administrator
1. Go to `https://hhamza.42.fr/wp-admin`
2. **Username**: `chief_operator` (or the `WP_ADMIN_USER` configured in `srcs/.env`)
3. **Password**: The password stored in `secrets/wp_admin_password.txt`

### Logging in as Secondary User (Author)
1. Go to `https://hhamza.42.fr/wp-admin`
2. **Username**: `staff_editor` (or the `WP_USER` configured in `srcs/.env`)
3. **Password**: The password stored in `secrets/wp_user_password.txt`

---

## 5. Checking that Services are Running Correctly

### Inspecting Container Status
Run the status command from the project root:
```bash
make status
```
Expected output:
```
NAME         IMAGE                 COMMAND                  SERVICE      STATUS      PORTS
mariadb      mariadb:inception     "/usr/local/bin/mari…"   mariadb      Up          3306/tcp
nginx        nginx:inception       "/usr/local/bin/ngin…"   nginx        Up          0.0.0.0:443->443/tcp
wordpress    wordpress:inception   "/usr/local/bin/word…"   wordpress    Up          9000/tcp
```

### Viewing Live Logs
To monitor live activity and verify request processing:
```bash
make logs
```

### Verifying HTTPS Connectivity via Terminal
You can quickly test TLS communication from the host with `curl`:
```bash
curl -kI https://hhamza.42.fr
```
A successful response will return an `HTTP/2 200` status code.
