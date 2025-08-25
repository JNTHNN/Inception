COMPOSE = docker-compose -f srcs/docker-compose.yml

init:
	@echo "Initialisation des dossiers de données..."
	@chmod +x init.sh
	@./init.sh

build: init
	$(COMPOSE) build --no-cache

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

.PHONY: init build up down clean logs stop restart nginx wordpress mariadb