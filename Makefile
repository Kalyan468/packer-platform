.DEFAULT_GOAL := help
ARM_RESOURCE_GROUP ?= dev_az_rg1
ARM_LOCATION ?= North Europe
CI_BUILD_ID ?= Packer
ARM_STORAGE_ACCOUNT ?= devnesa0001
ARM_CONTAINER_NAME ?= devnecn0001
ARM_CAPTURE_NAME ?= packer-images
IMAGE_DATETIME ?= $(shell date +%Y%m%d-%H%M%S)
GIT_SHORT_HASH ?= $(shell git rev-parse --short HEAD)

azure-base-image:
	ansible-galaxy install -f \
		-r azure/$(OS_FLAVOUR)/ansible/base/requirements.yml \
		-p azure/$(OS_FLAVOUR)/ansible/base/roles
	chmod +x ./resources/generic/azCLI/create-resource-group.sh
	which az
	./resources/generic/azCLI/create-resource-group.sh "$(ARM_RESOURCE_GROUP)" "$(ARM_LOCATION)"
	packer build \
		-var-file=azure/$(OS_FLAVOUR)/variables/base/variables.json \
		-var "build_name=base-$(OS_FLAVOUR)-$(GIT_SHORT_HASH)-$(IMAGE_DATETIME)" \
		-var "type=base" \
		-var "os_flavour=$(OS_FLAVOUR)" \
		-var "storage_account=$(ARM_STORAGE_ACCOUNT)"\
		-var "container_name=$(ARM_CONTAINER_NAME)"\
		-var "capture_name=$(ARM_CAPTURE_NAME)"\
		-var "resource_group_name=$(ARM_RESOURCE_GROUP)"\
		-var "location=$(ARM_LOCATION)" \
		-var "ci_build_id=$(CI_BUILD_ID)" \
		-var "ci_build_link=$(CI_BUILD_LINK)" \
		azure-base-image.json

azure-base-image-list: ## prints a list of base images on current subscription
	@./resources/generic/azCLI/list-base-images.sh

delete-azure-base-image: ## Deletes an azure base image
	bash -c "source ./resources/generic/azCLI/lib/auth.sh; az_login"
	az image delete -g $(ARM_RESOURCE_GROUP) --name "base-$(OS_FLAVOUR)-$(GIT_SHORT_HASH)-$(IMAGE_DATETIME)"

help: ## See all the Makefile targets
	@grep -E '^[a-zA-Z0-9._-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: azure-base-image azure-base-image-list help
