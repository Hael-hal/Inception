# ==============================================================================
# Inception Makefile
# ==============================================================================

NAME            = inception
COMPOSE_FILE    = srcs/docker-compose.yml
ENV_FILE        = srcs/.env

# Extract LOGIN from .env if present, otherwise default to hhamza
LOGIN           ?= $(shell grep '^LOGIN=' $(ENV_FILE) 2>/dev/null | cut -d '=' -f2)
ifeq ($(LOGIN),)
LOGIN           = hhamza
endif

DATA_DIR        = /home/$(LOGIN)/data
WP_DATA         = $(DATA_DIR)/wordpress
DB_DATA         = $(DATA_DIR)/mariadb

DOCKER_COMPOSE  = docker compose -f $(COMPOSE_FILE)

# Color helpers for terminal output
GREEN           = \033[0;32m
YELLOW          = \033[0;33m
RED             = \033[0;31m
BLUE            = \033[0;34m
NC              = \033[0m

# ==============================================================================
# Targets
# ==============================================================================

.PHONY: all prepare build up down start stop restart status ps logs clean fclean re

all: prepare build up
	@echo "$(GREEN)==> [Inception] Stack successfully started!$(NC)"
	@echo "$(BLUE)==> Access WordPress via: https://$(LOGIN).42.fr$(NC)"

prepare:
	@echo "$(BLUE)==> [Inception] Preparing host data directories and secrets...$(NC)"
	@mkdir -p $(WP_DATA) $(DB_DATA)
	@mkdir -p secrets
	@if [ ! -f secrets/db_password.txt ]; then echo "mariadb_user_password_42" > secrets/db_password.txt; fi
	@if [ ! -f secrets/db_root_password.txt ]; then echo "mariadb_root_password_42" > secrets/db_root_password.txt; fi
	@if [ ! -f secrets/wp_admin_password.txt ]; then echo "wp_admin_secure_pass_42" > secrets/wp_admin_password.txt; fi
	@if [ ! -f secrets/wp_user_password.txt ]; then echo "wp_author_secure_pass_42" > secrets/wp_user_password.txt; fi
	@if [ ! -f secrets/credentials.txt ]; then \
		echo "# Inception Credentials" > secrets/credentials.txt; \
		echo "WP_ADMIN_USER=chief_operator" >> secrets/credentials.txt; \
		echo "WP_USER=staff_editor" >> secrets/credentials.txt; \
	fi
	@if [ ! -f $(ENV_FILE) ]; then cp srcs/.env.example $(ENV_FILE); fi

build: prepare
	@echo "$(BLUE)==> [Inception] Building custom Docker images...$(NC)"
	@$(DOCKER_COMPOSE) build

up: prepare
	@echo "$(GREEN)==> [Inception] Launching containers in detached mode...$(NC)"
	@$(DOCKER_COMPOSE) up -d

down:
	@echo "$(YELLOW)==> [Inception] Stopping and removing containers and networks...$(NC)"
	@$(DOCKER_COMPOSE) down

start:
	@echo "$(GREEN)==> [Inception] Starting existing containers...$(NC)"
	@$(DOCKER_COMPOSE) start

stop:
	@echo "$(YELLOW)==> [Inception] Stopping active containers...$(NC)"
	@$(DOCKER_COMPOSE) stop

restart:
	@echo "$(BLUE)==> [Inception] Restarting containers...$(NC)"
	@$(DOCKER_COMPOSE) restart

status ps:
	@echo "$(BLUE)==> [Inception] Current container status:$(NC)"
	@$(DOCKER_COMPOSE) ps

logs:
	@$(DOCKER_COMPOSE) logs -f

clean: down
	@echo "$(YELLOW)==> [Inception] Removing built images and orphaned containers...$(NC)"
	@$(DOCKER_COMPOSE) down --rmi all --remove-orphans

fclean:
	@echo "$(RED)==> [Inception] Full cleanup in progress...$(NC)"
	@$(DOCKER_COMPOSE) down --rmi all --volumes --remove-orphans 2>/dev/null || true
	@docker system prune -a --volumes -f 2>/dev/null || true
	@echo "$(RED)==> [Inception] Removing host data directories...$(NC)"
	@rm -rf $(DATA_DIR) 2>/dev/null || sudo rm -rf $(DATA_DIR) 2>/dev/null || true
	@echo "$(GREEN)==> [Inception] Clean complete.$(NC)"

re: fclean all
