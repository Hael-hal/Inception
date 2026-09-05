*This project has been created as part of the 42 curriculum by hhamza.*

# Inception

A complete multi-container system administration infrastructure built with **Docker** and **Docker Compose**, following the strict requirements and constraints of the 42 Inception project.

---

## Table of Contents

- [Description](#description)
  - [Project Overview](#project-overview)
  - [Architecture & Design Choices](#architecture--design-choices)
  - [Technical Comparisons](#technical-comparisons)
    - [1. Virtual Machines vs Docker](#1-virtual-machines-vs-docker)
    - [2. Secrets vs Environment Variables](#2-secrets-vs-environment-variables)
    - [3. Docker Network vs Host Network](#3-docker-network-vs-host-network)
    - [4. Docker Volumes vs Bind Mounts](#4-docker-volumes-vs-bind-mounts)
- [Directory Structure](#directory-structure)
- [Instructions](#instructions)
  - [Prerequisites](#prerequisites)
  - [Local Domain Configuration](#local-domain-configuration)
  - [Installation & Execution](#installation--execution)
  - [Available Make Commands](#available-make-commands)
- [Resources & AI Usage](#resources--ai-usage)
  - [References](#references)
  - [AI Usage Declaration](#ai-usage-declaration)

---

## Description

### Project Overview

The **Inception** project consists of virtualizing a complete web hosting infrastructure using Docker containers. The stack is composed of three interconnected services:

1. **NGINX**: The sole public-facing entrypoint, configured to serve traffic exclusively over **HTTPS (port 443)** using **TLSv1.2 or TLSv1.3**.
2. **WordPress + PHP-FPM**: A container running the WordPress CMS backend and FastCGI process manager without a bundled web server, listening on port `9000`.
3. **MariaDB**: A standalone database container holding WordPress data, listening on port `3306` only within the Docker network.

Every container is built from a custom `Dockerfile` utilizing the penultimate stable release of Debian (`debian:bullseye`). Ready-made service images (e.g. pulling official `nginx`, `wordpress`, or `mariadb` images from Docker Hub) and `latest` tags are strictly prohibited.

---

### Architecture & Design Choices

```
                                  +-------------------------------------------------+
                                  |                 Computer HOST                   |
                                  |                                                 |
         HTTPS (Port 443)         |   +---------------------------------------+     |
WWW ===============================> | NGINX (TLSv1.2 / TLSv1.3)             |     |
                                  |   +---------------------------------------+     |
                                  |                      |                          |
                                  |        FastCGI (9000)| (inception_network)      |
                                  |                      v                          |
                                  |   +---------------------------------------+     |
                                  |   | WordPress + PHP-FPM                   |     |
                                  |   +---------------------------------------+     |
                                  |                      |                          |
                                  |           MySQL(3306)| (inception_network)      |
                                  |                      v                          |
                                  |   +---------------------------------------+     |
                                  |   | MariaDB Server                        |     |
                                  |   +---------------------------------------+     |
                                  |            |                       |            |
                                  |            v                       v            |
                                  |   [wordpress_data]           [mariadb_data]     |
                                  |   /home/login/data/          /home/login/data/  |
                                  |   wordpress                  mariadb            |
                                  +-------------------------------------------------+
```

- **PID 1 Execution**: All service entrypoints use the shell `exec` command to directly spawn daemons (`mariadbd`, `php-fpm7.4`, `nginx`) as Process ID 1. No prohibited hacky loops (`tail -f`, `sleep infinity`, `while true`) are utilized.
- **Port Isolation**: Port 443 on NGINX is the only port exposed to the host machine. MariaDB (`3306`) and WordPress PHP-FPM (`9000`) communicate exclusively over the private bridge network.
- **Separation of Concerns**: Each service runs in its own isolated container, with strict role demarcation.

---

### Technical Comparisons

#### 1. Virtual Machines vs Docker

| Aspect | Virtual Machines (VMs) | Docker Containers |
| :--- | :--- | :--- |
| **Architecture** | Runs a full Guest Operating System on top of a Hypervisor (Type 1 or Type 2). | Shares the Host OS kernel using Linux namespaces and cgroups. |
| **Resource Usage** | High memory and CPU overhead (GBs of RAM pre-allocated per VM). | Lightweight, minimal memory overhead, near-native performance. |
| **Startup Time** | Minutes (boots full virtualized kernel, hardware emulation, and init system). | Milliseconds to seconds (launches an isolated process tree directly). |
| **Isolation** | Hardware-level isolation via Hypervisor virtualization. | OS-level process isolation (namespaces for PID, NET, IPC, MNT, UTS). |
| **Portability** | Heavy image files (several gigabytes), harder to ship and version control. | Compact layered container images, declarative Dockerfiles. |

#### 2. Secrets vs Environment Variables

| Aspect | Environment Variables (`.env`) | Docker Secrets |
| :--- | :--- | :--- |
| **Storage & Visibility** | Visible in plain text in process environments (`/proc/<pid>/environ`), `docker inspect`, logs, and process monitors. | Stored in in-memory temporary file systems (`/run/secrets/`), decrypted only in authorized containers. |
| **Persistence** | Kept in static configuration files or container metadata. | Never written unencrypted to disk in swarm mode, mounted dynamically as files. |
| **Accidental Exposure** | High risk of leakage via process listings, crash dumps, or Git commits. | Low risk; files remain on the host filesystem and are mounted securely into containers. |
| **Ideal Use Case** | Non-sensitive configurations (domain names, URLs, port numbers, debug flags). | Highly sensitive credentials (database passwords, API keys, private keys). |

#### 3. Docker Network vs Host Network

| Aspect | Docker Network (Custom Bridge) | Host Network (`network: host`) |
| :--- | :--- | :--- |
| **Port Isolation** | Complete isolation; containers only expose explicit ports to each other. | Shares the host network stack; ports opened inside containers bind directly to host interfaces. |
| **Port Conflicts** | Multiple containers can listen on internal port 80/443 without collision. | Port collisions occur if multiple containers or host services use the same port. |
| **DNS Resolution** | Automatic built-in DNS allows service discovery by container name (e.g. `mariadb:3306`). | No built-in Docker DNS; services must connect via `localhost` or host IPs. |
| **Security** | High boundary isolation between services and host interfaces. | Low boundary isolation; a compromised container has direct access to host network interfaces. |

#### 4. Docker Volumes vs Bind Mounts

| Aspect | Docker Named Volumes | Host Bind Mounts |
| :--- | :--- | :--- |
| **Management** | Fully managed by the Docker daemon (`docker volume create/ls/rm`). | Relies directly on the host filesystem directory structure and permissions. |
| **Driver Flexibility** | Can use volume drivers (e.g. `driver_opts` with `device: /home/login/data`). | Directly binds a specific host directory without Docker volume management abstractions. |
| **Portability** | Abstracts host filesystem specifics and ensures portability across Docker environments. | Tightly coupled to host OS paths, requiring exact host directories and permissions. |
| **Performance & Safety** | Optimized for container runtimes, isolated from accidental modification by non-Docker host users. | High performance, but sensitive to host permission collisions (`UID`/`GID` mismatch). |

---

## Directory Structure

```
.
├── Makefile
├── .gitignore
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── secrets/
│   ├── .gitkeep
│   ├── credentials.txt
│   ├── db_password.txt
│   ├── db_root_password.txt
│   ├── wp_admin_password.txt
│   └── wp_user_password.txt
└── srcs/
    ├── .env
    ├── .env.example
    ├── docker-compose.yml
    └── requirements/
        ├── mariadb/
        │   ├── .dockerignore
        │   ├── Dockerfile
        │   ├── conf/
        │   │   └── 50-server.cnf
        │   └── tools/
        │       └── mariadb.sh
        ├── nginx/
        │   ├── .dockerignore
        │   ├── Dockerfile
        │   ├── conf/
        │   │   └── nginx.conf
        │   └── tools/
        │       └── nginx.sh
        └── wordpress/
            ├── .dockerignore
            ├── Dockerfile
            ├── conf/
            │   └── www.conf
            └── tools/
                └── wordpress.sh
```

---

## Instructions

### Prerequisites

- **Docker Engine** (v20.10+)
- **Docker Compose** (v2.0+)
- **GNU Make**
- Linux / macOS development environment

### Local Domain Configuration

To access the website locally under the required 42 domain format (`hhamza.42.fr`), add the following line to your host's `/etc/hosts` file:

```bash
sudo sh -c 'echo "127.0.0.1 hhamza.42.fr" >> /etc/hosts'
```

### Installation & Execution

1. Clone the repository and navigate into the folder:
   ```bash
   git clone <repository_url> incp
   cd incp
   ```

2. Configure environment variables and secrets (if customizing beyond default templates):
   ```bash
   cp srcs/.env.example srcs/.env
   ```

3. Build and launch the entire infrastructure:
   ```bash
   make
   ```

4. Open your web browser and navigate to:
   - **WordPress Site**: `https://hhamza.42.fr`
   - **WordPress Admin**: `https://hhamza.42.fr/wp-admin`

*(Note: Because the SSL certificate is self-signed, your browser will display a security warning. Click "Advanced" -> "Proceed to site" to continue).*

---

### Available Make Commands

| Command | Action |
| :--- | :--- |
| `make` / `make all` | Prepares host directories and secrets, builds images, and starts containers. |
| `make build` | Builds or rebuilds all Docker images. |
| `make up` | Starts containers in detached mode. |
| `make down` | Stops and removes containers and the Docker network. |
| `make start` | Starts stopped containers. |
| `make stop` | Stops running containers. |
| `make restart` | Restarts all running containers. |
| `make status` / `make ps` | Displays the status of all stack containers. |
| `make logs` | Follows and displays output logs from all running containers. |
| `make clean` | Stops containers and removes all built Docker images. |
| `make fclean` | Complete teardown: removes images, volumes, containers, networks, and data directories. |
| `make re` | Performs `fclean` followed by a fresh `make all`. |

---

## Resources & AI Usage

### References

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Specification](https://docs.docker.com/compose/compose-file/)
- [Debian Official Package Archive](https://packages.debian.org/bullseye/)
- [NGINX Documentation & SSL Configuration](https://nginx.org/en/docs/)
- [WordPress WP-CLI Documentation](https://wp-cli.org/)
- [MariaDB Knowledge Base](https://mariadb.com/kb/en/)

### AI Usage Declaration

In accordance with Chapters IV and VI of the 42 Inception curriculum:
- **AI Tool Utilized**: Google DeepMind Antigravity AI Coding Assistant.
- **Tasks & Scope**:
  - Generation of structured initial configuration files (`50-server.cnf`, `www.conf`, `nginx.conf`).
  - Structuring entrypoint automation scripts (`mariadb.sh`, `wordpress.sh`, `nginx.sh`) ensuring PID 1 compliance.
  - Review and verification of strict subject constraints (Debian penultimate stable, named volume driver options, non-admin username verification, secret directory segregation).
  - Generation of complete project documentation (`README.md`, `USER_DOC.md`, `DEV_DOC.md`).
- **Human Verification**: All generated configurations and scripts were reviewed, validated against 42 requirements, and verified to run without security loopholes or prohibited syntax.
