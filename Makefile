PROJECT ?= kit3d
COMPOSE ?= compose.yaml
DEV_COMPOSE ?= compose.dev.yml

.PHONY: all help prod-up prod-down dev-up dev-down

all: help

help:
	@echo "Makefile for docker compose shortcuts."
	@echo "Targets:"
	@echo "  prod-up    - deploy the production environment"
	@echo "  prod-down  - clean the production environment"
	@echo "  dev-up     - deploy the development environment"
	@echo "  dev-down   - clean the development environment"

prod-up:
	docker compose -p $(PROJECT) -f $(COMPOSE) up -d

prod-down:
	docker compose -p $(PROJECT) -f $(COMPOSE) down -v

dev-up:
	docker compose -p $(PROJECT)-dev -f $(DEV_COMPOSE) up -d

dev-down:
	docker compose -p $(PROJECT)-dev -f $(DEV_COMPOSE) down -v
