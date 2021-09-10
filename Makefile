.DEFAULT_GOAL := help
SHELL = /bin/bash
ENVIRONMENT ?=

include .env
export

PROVISION_ROOT = $(PWD)


define terraform_vars
@bash -c "sed -e 's/$$//' \
-e 's/^ //' \
-e 's/^#.*//' \
-e '/^[[:space:]]*$$/d' .env \
| awk '{split(\$$0,a,\"=\");new_var=tolower(a[1])\"=\"a[2];print new_var}' > /tmp/.env.tmp;"
@bash -c "sed -e 's/^.*/TF_VAR_&/' /tmp/.env.tmp > $(PROVISION_ROOT)/.env.tf; rm -f /tmp/.env.tmp;"
endef


define PRINT_HELP_PYSCRIPT
import re, sys
for line in sys.stdin:
	match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
	if match:
		target, help = match.groups()
		print("%-20s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT


# ================== Make commands ====================
help:
	@python -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)


.PHONY: machine-image
machine-image: ## Deploy a machine image with Packer
ifeq ($(BUILD_SOURCE), )
	@echo "Usage: BUILD_SOURCE=grafana make machine-image"
	@echo ""
	@echo "See machine-images/*.pkr.hcl build blocks for names."
	@echo "Valid values are: grafana, grafana-nginx"
	exit 1
endif
	@packer build -only *.$(BUILD_SOURCE) machine-images/default.pkr.hcl


.PHONY: plan apply destroy
ifeq ($(MAKELEVEL), 0)
plan: ## Plan Grafana resources with terraform plan
	@echo "••• Setting terraform variables"
	$(call terraform_vars)
	$(MAKE) $@
else
plan:
	@echo "••• Planning Grafana deployment"
	@set -a; . .env.tf; set +a; terraform init; terraform plan -var-file=grafana-vars.tfvars
endif


ifeq ($(MAKELEVEL), 0)
apply: ## Deploy Grafana resources with terraform apply
	@echo "••• Setting terraform variables"
	$(call terraform_vars)
	$(MAKE) $@
else
apply:
	@echo "••• Deploying Grafana"
	@set -a; . .env.tf; set +a; terraform apply -var-file grafana-vars.tfvars
endif


ifeq ($(MAKELEVEL), 0)
destroy: ## Tear down Grafana resources with terraform destroy
	@echo "••• Setting terraform variables"
	$(call terraform_vars)
	$(MAKE) $@
else
destroy:
	@echo "••• Tearing down Grafana"
	@set -a; . .env.tf; set +a; terraform destroy -var-file grafana-vars.tfvars
endif
