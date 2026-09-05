*This project has been created as part of the 42 curriculum by hhamza.*

# Inception

## Description
This project consists of setting up a small infrastructure composed of different services using Docker and Docker Compose:
- **NGINX**: Entrypoint listening exclusively on port 443 with TLSv1.2/TLSv1.3.
- **WordPress + PHP-FPM**: Dynamic application listening on port 9000.
- **MariaDB**: Database container listening on port 3306.

All images are built from scratch using `debian:bullseye`.

### Comparisons

#### 1. Virtual Machines vs Docker
- **VMs**: Virtualize hardware and run a complete guest OS on top of a hypervisor. Higher CPU/RAM overhead and slow boot time.
- **Docker**: Virtualizes at OS level by sharing host kernel using cgroups/namespaces. Lightweight, instant startup, minimal resource footprint.

#### 2. Secrets vs Environment Variables
- **Environment Variables**: Visible in process lists (`/proc`), `docker inspect`, and logs. Suitable for non-sensitive configs (e.g. domain names).
- **Secrets**: Mounted as read-only files (e.g. `/run/secrets/`), avoiding plain-text exposure in environment variables.

#### 3. Docker Network vs Host Network
- **Docker Bridge Network**: Isolated network between containers with internal DNS discovery. Only explicitly mapped ports are reachable from host.
- **Host Network**: Containers share host network stack without isolation; risk of port collisions and security exposure.

#### 4. Docker Volumes vs Bind Mounts
- **Docker Named Volumes**: Managed by Docker runtime, decoupled from host directory structures, portable.
- **Bind Mounts**: Direct file mapping to host paths, depending strictly on host file permissions.

---

## Instructions

### 1. Setup Local Domain
```bash
sudo sh -c 'echo "127.0.0.1 hhamza.42.fr" >> /etc/hosts'
```

### 2. Build and Run
```bash
make
```

### 3. Access
- Website: `https://hhamza.42.fr`
- Admin Panel: `https://hhamza.42.fr/wp-admin`

---

## Resources

- [Docker Documentation](https://docs.docker.com/)
- [NGINX SSL Documentation](https://nginx.org/en/docs/http/configuring_https_servers.html)
- [WP-CLI Handbook](https://make.wordpress.org/cli/handbook/)

### AI Usage
Google DeepMind Antigravity AI was used to draft initial configuration files and structure boilerplate scripts according to 42 subject rules. All code was reviewed and validated for subject compliance.
