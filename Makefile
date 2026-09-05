all:
	@mkdir -p /home/hael-hal/data/mariadb
	@mkdir -p /home/hael-hal/data/wordpress
	docker compose -f srcs/docker-compose.yml up -d --build

build:
	docker compose -f srcs/docker-compose.yml build

down:
	docker compose -f srcs/docker-compose.yml down

clean: down
	docker compose -f srcs/docker-compose.yml down --rmi all -v

fclean: clean
	@rm -rf /home/hael-hal/data
	docker system prune -a --volumes -f

re: fclean all

.PHONY: all build down clean fclean re
