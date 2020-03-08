# Base
WATCHTOWER_BASE := $(strip $(patsubst %/, %, $(dir $(realpath $(firstword $(MAKEFILE_LIST))))))

# Set Help, default goal and WATCHTOWER_BASE
include help.mk

NAME  := docker-socket-proxy

# OCI Metadata
IMAGE_TITLE             := Docker Socket Proxy
IMAGE_DESC              := This is a security-enhanced proxy for the Docker Socket
IMAGE_URL               := https://hub.docker.com/r/tprasadtp/docker-socket-proxy
IMAGE_SOURCE            := https://github.com/tprasadtp/docker-socket-proxy
IMAGE_LICENSES          := Apache-2.0
IMAGE_DOCUMENTATION_URL := https://github.com/tprasadtp/docker-socket-proxy

# Custom Image Metadta
UPSTREAM_PRESENT := true
UPSTREAM_URL     := https://github.com/Tecnativa/docker-socket-proxy
UPSTREAM_AUTHOR  := Tecnativa

include docker.mk

.PHONY: smoke-test
smoke-test: ## Smoke Test
	@echo -e "\033[92m➜ $@ \033[0m"
	@echo -e "\033[92m✱ Startup\033[0m"
	DOCKER_USER=$(DOCKER_USER) NAME=$(NAME) DOCKER_TAG=$(firstword $(DOCKER_TAGS)) bats $(WATCHTOWER_BASE)/test/startup.bats
	@echo -e "\033[92m✱ Containers\033[0m"
	bats $(WATCHTOWER_BASE)/test/containers.bats
	@echo -e "\033[92m✱ Images\033[0m"
	bats $(WATCHTOWER_BASE)/test/images.bats
	@echo -e "\033[92m✱ Networks\033[0m"
	bats $(WATCHTOWER_BASE)/test/networks.bats
	@echo -e "\033[92m✱ Volumes\033[0m"
	bats $(WATCHTOWER_BASE)/test/volumes.bats
	@echo -e "\033[92m✱ Execs\033[0m"
	bats $(WATCHTOWER_BASE)/test/execs.bats
	@echo -e "\033[92m✱ Swarm\033[0m"
	bats $(WATCHTOWER_BASE)/test/swarm.bats
	@echo -e "\033[92m✱ System\033[0m"
	bats $(WATCHTOWER_BASE)/test/system.bats
	@echo -e "\033[92m✱ Cleanup\033[0m"
	bats $(WATCHTOWER_BASE)/test/cleanup.bats
