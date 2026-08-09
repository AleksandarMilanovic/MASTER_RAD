SHELL := /bin/bash
COMPOSE := docker compose -f compose/compose.yaml

.PHONY: help validate config up-core down ps logs

.PHONY: thehive-integration
thehive-integration:
	./scripts/deploy/configure-thehive-integration.sh


.PHONY: validate-thehive-integration
validate-thehive-integration:
	./scripts/validate/validate-thehive-integration.sh

help:
	@echo "Dostupne komande:"
	@echo "  make validate  - proverava lokalne preduslove"
	@echo "  make config    - validira Compose konfiguraciju"
	@echo "  make up-core   - podize osnovni profil"
	@echo "  make down      - zaustavlja okruzenje"
	@echo "  make ps        - prikazuje stanje servisa"
	@echo "  make logs      - prikazuje logove"

validate:
	bash scripts/validate/check-prerequisites.sh

config:
	$(COMPOSE) config

up-core:
	$(COMPOSE) --profile core up -d

down:
	$(COMPOSE) down

ps:
	$(COMPOSE) ps

logs:
	$(COMPOSE) logs --tail=200
