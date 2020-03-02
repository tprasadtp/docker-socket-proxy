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
UPSTREAM_URL := "https://github.com/Tecnativa/docker-socket-proxy"
UPSTREAM_AUTHOR := "Tecnativa <github@tecnativa.com>"

include base.mk

.PHONY: smoke-test
smoke-test: ## Smoke Test
	@echo -e "\033[92m➜ $@ \033[0m"
	@echo -e "\033[92m✱ Startup\033[0m"
	DOCKER_USER=$(DOCKER_USER) NAME=$(NAME) DOCKER_TAG=$(DOCKER_TAG) bats $(ROOT_DIR)/test/startup.bats || true
	@echo -e "\033[92m✱ Containers\033[0m"
	bats $(ROOT_DIR)/test/containers.bats || true
	@echo -e "\033[92m✱ Images\033[0m"
	bats $(ROOT_DIR)/test/images.bats || true
	@echo -e "\033[92m✱ Networks\033[0m"
	bats $(ROOT_DIR)/test/networks.bats || true
	@echo -e "\033[92m✱ Volumes\033[0m"
	bats $(ROOT_DIR)/test/volumes.bats || true
	@echo -e "\033[92m✱ Execs\033[0m"
	bats $(ROOT_DIR)/test/execs.bats || true
	@echo -e "\033[92m✱ Swarm\033[0m"
	bats $(ROOT_DIR)/test/swarm.bats || true
	@echo -e "\033[92m✱ System\033[0m"
	bats $(ROOT_DIR)/test/system.bats || true
	@echo -e "\033[92m✱ Cleanup\033[0m"
	bats $(ROOT_DIR)/test/cleanup.bats || true