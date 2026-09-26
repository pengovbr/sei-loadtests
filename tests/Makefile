
MAKEFILE_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

SCRIPTS_DIR := $(MAKEFILE_DIR)assets/scripts
ENVS_DIR := $(MAKEFILE_DIR)assets/envs-props

SEI_DOCKER_GIT_URL ?= https://github.com/pengovbr/sei-docker
SEI_DOCKER_LOCATION ?= $(MAKEFILE_DIR)assets/repos/sei-docker
SEI_DOCKER_LOCATION_INFRA ?= $(SEI_DOCKER_LOCATION)/infra

SEI_FONTES_REPO ?= https://github.com/pengovbr/sei
SEI_FONTES_LOCATION ?= $(MAKEFILE_DIR)assets/repos/sei-fontes
SEI_FONTES_CHECKOUT_VERSION ?= "4.0.12.15"

test: download-sei-docker download-sei-fontes sei-setup jmeter-run

download-sei-docker:
	@if [ ! -d "$(SEI_DOCKER_LOCATION)" ] || [ $$(ls -A "$(SEI_DOCKER_LOCATION)" | wc -l) -eq 0 ]; then \
		echo "Download do sei-docker de $(SEI_DOCKER_GIT_URL) para $(SEI_DOCKER_LOCATION)"; \
		git clone --depth 1 $(SEI_DOCKER_GIT_URL) $(SEI_DOCKER_LOCATION); \
	else \
		echo "Já existe o sei-docker em $(SEI_DOCKER_LOCATION)"; \
		echo "Pulando download"; \
	fi;


download-sei-fontes:
	@if [ ! -d "$(SEI_FONTES_LOCATION)" ] || [ $$(ls -A "$(SEI_FONTES_LOCATION)" | wc -l) -eq 0 ]; then \
		echo "Downloading sei-fontes from $(SEI_FONTES_REPO) to $(SEI_FONTES_LOCATION)"; \
		git clone $(SEI_FONTES_REPO) $(SEI_FONTES_LOCATION); \
		git -C $(SEI_FONTES_LOCATION) checkout $(SEI_FONTES_CHECKOUT_VERSION); \
	else \
		echo "Já existe o sei-fontes em $(SEI_FONTES_LOCATION)"; \
		echo "Pulando download e checkout"; \
	fi;


sei-destroy:
	echo "Destruindo e limpando volumes ..."; \
	make -C $(SEI_DOCKER_LOCATION_INFRA) clear || true; \
	make -C $(SEI_DOCKER_LOCATION_INFRA) apagar_volumes

sei-setup:
	@make sei-destroy
	@echo "Vamos subir o sei usando o sei-docker/infra em $(SEI_DOCKER_LOCATION)infra"
	$(SCRIPTS_DIR)/setup.sh $(SEI_DOCKER_LOCATION_INFRA) $(SEI_FONTES_LOCATION) $(ENVS_DIR) $(SEI_FONTES_CHECKOUT_VERSION)

jmeter-run:
	@echo "Running jmeter tests..."
	$(SCRIPTS_DIR)/jmeterRun.sh $(SEI_FONTES_LOCATION) $(ENVS_DIR)


