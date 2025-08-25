COMPOSE = docker-compose -f srcs/docker-compose.yml

build: init
	$(COMPOSE) build --no-cache

init:
	@chmod +x init.sh
	@sudo ./init.sh

up: init
	$(COMPOSE) up -d

down:
	$(COMPOSE) down

clean:
	$(COMPOSE) down -v
	docker system prune -af

logs:
	$(COMPOSE) logs -f

stop:
	$(COMPOSE) stop

restart:
	$(COMPOSE) restart

nginx:
	$(COMPOSE) build --no-cache nginx
	$(COMPOSE) up -d nginx

wordpress:
	$(COMPOSE) build --no-cache wordpress
	$(COMPOSE) up -d wordpress

mariadb:
	$(COMPOSE) build --no-cache mariadb
	$(COMPOSE) up -d mariadb

.PHONY: build init up down clean logs stop restart nginx wordpress mariadb