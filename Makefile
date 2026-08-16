SHELL := /bin/bash

.DEFAULT_GOAL := help

.PHONY: \
	help setup up down status validate \
	networks-up \
	wazuh-up wazuh-down wazuh-validate \
	thehive-up thehive-down thehive-validate \
	thehive-integration validate-thehive-integration \
	caldera-up caldera-down caldera-validate \
	monitoring-up monitoring-down monitoring-validate \
	logs


help:
	@echo ""
	@echo "Hybrid Cyber Range"
	@echo "=================="
	@echo ""
	@echo "Main commands:"
	@echo "  make up          Start complete cyber range"
	@echo "  make down        Stop complete cyber range"
	@echo "  make status      Show platform status"
	@echo "  make validate    Validate complete cyber range"
	@echo ""
	@echo "Individual components:"
	@echo "  make wazuh-up"
	@echo "  make wazuh-down"
	@echo "  make thehive-up"
	@echo "  make thehive-down"
	@echo "  make caldera-up"
	@echo "  make caldera-down"
	@echo "  make monitoring-up"
	@echo "  make monitoring-down"
	@echo ""
	@echo "Diagnostics:"
	@echo "  make wazuh-validate"
	@echo "  make thehive-validate"
	@echo "  make caldera-validate"
	@echo "  make monitoring-validate"
	@echo "  make validate-thehive-integration"
	@echo ""


up:
	./scripts/deploy/all-up.sh


down:
	./scripts/reset/all-down.sh


validate:
	./scripts/validate/validate-all.sh


networks-up:
	./scripts/deploy/networks-up.sh


wazuh-up:
	./scripts/deploy/wazuh-up.sh


wazuh-down:
	./scripts/reset/wazuh-down.sh


wazuh-validate:
	./scripts/validate/validate-wazuh.sh


thehive-up:
	./scripts/deploy/thehive-up.sh


thehive-down:
	./scripts/reset/thehive-down.sh


thehive-validate:
	./scripts/validate/validate-thehive.sh


thehive-integration:
	./scripts/deploy/configure-thehive-integration.sh


validate-thehive-integration:
	./scripts/validate/validate-thehive-integration.sh


caldera-up:
	./scripts/deploy/caldera-up.sh


caldera-down:
	./scripts/reset/caldera-down.sh


caldera-validate:
	./scripts/validate/validate-caldera.sh


monitoring-up:
	./scripts/deploy/monitoring-up.sh


monitoring-down:
	./scripts/reset/monitoring-down.sh


monitoring-validate:
	./scripts/validate/validate-monitoring.sh


status:
	@echo ""
	@echo "=== Docker Services ==="
	@docker ps \
		--format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
	@echo ""
	@echo "=== CALDERA ==="
	@systemctl is-active hcr-caldera || true
	@echo ""


logs:
	@echo "Use:"
	@echo "  docker logs <container>"
	@echo "  journalctl -u hcr-caldera -f"