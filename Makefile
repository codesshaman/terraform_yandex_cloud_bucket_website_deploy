name = Terraform

VAR :=				# Cmd arg var
NO_COLOR=\033[0m	# Color Reset
OK=\033[32;01m		# Green Ok
ERROR=\033[31;01m	# Error red
WARN=\033[33;01m	# Warning yellow
VERSION="0.171.0"
PLUGINS_DIR = $(HOME)/.terraform.d/plugins/
PLUGIN_DIR = $(HOME)/.terraform.d/plugins/registry.terraform.io/yandex-cloud/yandex/$(VERSION)/linux_amd64
PROVIDER_FILE = terraform-provider-yandex_v$(VERSION)
PROVIDER_ARCHIVE = terraform-provider-yandex_$(VERSION)_linux_amd64.zip
DOWNLOAD_URL = https://github.com/yandex-cloud/terraform-provider-yandex/releases/download/v$(VERSION)/terraform-provider-yandex_$(VERSION)_linux_amd64.zip
ifneq (,$(wildcard .env))
    include .env
    export $(shell sed 's/=.*//' .env)
endif

all:
	@printf "$(OK)- terraform apply\n"
# 	@terraform apply -auto-approve
	@terraform apply

env:
	@printf "$(ERROR)==== Create environment file for ${name}... ====$(NO_COLOR)\n"
	@if [ -f .env ]; then \
		echo "$(ERROR).env file already exists!$(NO_COLOR)"; \
	else \
		cp .env.example .env; \
		echo "$(GREEN).env file successfully created!$(NO_COLOR)"; \
	fi

git:
	@printf "$(YELLOW)==== Set user name and email to git for ${name} repo... ====$(NO_COLOR)\n"
	@bash scripts/gituser.sh

help:
	@echo -e "$(OK)==== Manual for ${name} configuration ===="
	@echo -e "$(WARN)- make				: Launch configuration"
	@echo -e "$(WARN)- make create_qa		: Create qa workspace"
	@echo -e "$(WARN)- make create_staging		: Create staging workspace"
	@echo -e "$(WARN)- make create_production	: Create production workspace"
	@echo -e "$(WARN)- make init			: Init configuration"
	@echo -e "$(WARN)- make git			: Set git user"
	@echo -e "$(WARN)- make plan			: Show intallation plan"
	@echo -e "$(WARN)- make push			: Push last changes to git"
	@echo -e "$(WARN)- make provider			: Install provider"
	@echo -e "$(WARN)- make select_qa		: Select qa workspace"
	@echo -e "$(WARN)- make select_staging		: Select staging workspace"
	@echo -e "$(WARN)- make select_production	: Select production workspace"
	@echo -e "$(WARN)- make vars			: get variables from .env"
	@echo -e "$(WARN)- make wget			: Download provider"
	@echo -e "$(WARN)- make zip			: Unpack provider"
	@echo -e "$(WARN)- make clean			: Clean all images"
	@echo -e "$(WARN)- make fclean			: Full clean of all images and archives$(NO_COLOR)"

create_qa:
	@terraform workspace new qa

create_staging:
	@terraform workspace new staging

create_production:
	@terraform workspace new production

init:
	@terraform init -upgrade=false -plugin-dir $(PLUGINS_DIR)

plan:
	@terraform plan

provider:
	@if [ ! -f "$(PROVIDER_FILE)" ]; then \
		exit 1; \
	fi
	@if [ ! -d "$(PLUGIN_DIR)" ]; then \
		mkdir -p "$(PLUGIN_DIR)"; \
	fi
	@mv "$(PROVIDER_FILE)" "$(PLUGIN_DIR)"
	@chmod +x "$(PLUGIN_DIR)/$(PROVIDER_FILE)"
	@rm $(PROVIDER_ARCHIVE)

push:
	@bash scripts/push.sh

select_qa:
	@terraform workspace select qa

select_staging:
	@terraform workspace select staging

select_production:
	@terraform workspace select production

vars:
	@set -a && . ./.env && envsubst < terraform.tfvars.template > terraform.tfvars

wget:
	@wget "$(DOWNLOAD_URL)"
	@if [ $$? -ne 0 ]; then \
		rm -f "$(PROVIDER_FILE)"; \
		exit 1; \
	fi

zip:
	@unzip terraform-provider-yandex_*_linux_amd64.zip

clean:
	@printf "$(ERROR)- Clean configuration$(NO_COLOR)"
	@bash scripts/clean.sh

.PHONY	: all help push clean fclean
