# Set the shell
SHELL := /bin/bash
NAME := docker-socket-proxy

# OCI Metadata
IMAGE_TITLE := "Docker Socket Proxy"
IMAGE_DESC := "This is a security-enhanced proxy for the Docker Socket"
IMAGE_URL := "https://hub.docker.com/r/tprasadtp/docker-socket-proxy"
IMAGE_SOURCE := "https://github.com/tprasadtp/docker-socket-proxy"
IMAGE_LICENSES := "Apache-2.0"
IMAGE_DOCUMENTATION_URL := "https://github.com/tprasadtp/docker-socket-proxy"

# Custom Image Metadta
IS_FORK := true
UPSTREAM_URL := "https://github.com/Tecnativa/docker-socket-proxy"
UPSTREAM_AUTHOR := "Tecnativa <github@tecnativa.com>"

include base.mk

.PHONY: smoke-test
smoke-test: ## Smoke Test
	@echo -e "\033[92m➜ $@ \033[0m"
	@echo -e "\033[92m✱ Startup\033[0m"
	DOCKER_USER=$(DOCKER_USER) NAME=$(NAME) DOCKER_TAG=$(DOCKER_TAG) bats $(ROOT_DIR)/test/startup.bats
	@echo -e "\033[92m✱ Containers\033[0m"
	bats $(ROOT_DIR)/test/containers.bats
	@echo -e "\033[92m✱ Images\033[0m"
	bats $(ROOT_DIR)/test/images.bats
	@echo -e "\033[92m✱ Networks\033[0m"
	bats $(ROOT_DIR)/test/networks.bats
	@echo -e "\033[92m✱ Volumes\033[0m"
	bats $(ROOT_DIR)/test/volumes.bats
	@echo -e "\033[92m✱ Execs\033[0m"
	bats $(ROOT_DIR)/test/execs.bats
	@echo -e "\033[92m✱ Swarm\033[0m"
	bats $(ROOT_DIR)/test/swarm.bats
	@echo -e "\033[92m✱ System\033[0m"
	bats $(ROOT_DIR)/test/system.bats
	@echo -e "\033[92m✱ Cleanup\033[0m"
	bats $(ROOT_DIR)/test/cleanup.bats

.PHONY: run
run: ## Run docekr image in background
	docker run -d --rm \
		--name dockerproxy \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-p "${DOCKER_ENDPOINT}":2375 \
    -e CONTAINERS=1 \
    -e DISTRIBUTION=1 \
    -e EVENTS=1 \
    -e EXEC=0 \
    -e IMAGES=1 \
    -e INFO=1 \
    -e LOG_LEVEL=info \
    -e NETWORKS=1 \
    -e POST=1 \
    -e SYSTEM=1 \
    -e VERSION=1 \
    -e VOLUMES=1 \
	${DOCKER_USER}/${NAME}:${DOCKER_TAG}
