#WATCHTOWER_BASE := $(strip $(patsubst %/, %, $(dir $(realpath $(firstword $(MAKEFILE_LIST))))))

# Set Help, default goal and WATCHTOWER_BASE
include makefiles/help.mk


# docker image
DOCKER_IMAGES          := ghcr.io/tprasadtp/docker-socket-proxy tprasadtp/docker-socket-proxy

# OCI Metadata
IMAGE_TITLE             := Docker Socket Proxy
IMAGE_DESC              := This is a security-enhanced proxy for the Docker Socket
IMAGE_URL               := https://hub.docker.com/r/tprasadtp/docker-socket-proxy
IMAGE_SOURCE            := https://github.com/tprasadtp/docker-socket-proxy
IMAGE_LICENSES          := Apache-2.0
IMAGE_DOCUMENTATION     := https://github.com/tprasadtp/docker-socket-proxy

include makefiles/docker.mk

# Define Endpoints for smoke test if not defined already
ifeq ($(DOCKER_PROXY_ENDPOINT),)
DOCKER_PROXY_ENDPOINT := 127.0.0.1:12375
endif

.PHONY: smoke-test
smoke-test: ## Smoke Test
	@echo -e "\033[92m➜ $@ \033[0m"
	@echo -e "\033[92m✱ Startup\033[0m"
	DOCKER_TAG=$(firstword $(DOCKER_TAGS)) DOCKER_PROXY_ENDPOINT=$(DOCKER_PROXY_ENDPOINT) bats test/startup.bats
	@echo -e "\033[92m✱ Containers\033[0m"
	DOCKER_PROXY_ENDPOINT=$(DOCKER_PROXY_ENDPOINT) bats test/containers.bats
	@echo -e "\033[92m✱ Images\033[0m"
	DOCKER_PROXY_ENDPOINT=$(DOCKER_PROXY_ENDPOINT) bats test/images.bats
	@echo -e "\033[92m✱ Networks\033[0m"
	DOCKER_PROXY_ENDPOINT=$(DOCKER_PROXY_ENDPOINT) bats test/networks.bats
	@echo -e "\033[92m✱ Volumes\033[0m"
	DOCKER_PROXY_ENDPOINT=$(DOCKER_PROXY_ENDPOINT) bats test/volumes.bats
	@echo -e "\033[92m✱ Execs\033[0m"
	DOCKER_PROXY_ENDPOINT=$(DOCKER_PROXY_ENDPOINT) bats test/execs.bats
	@echo -e "\033[92m✱ Swarm\033[0m"
	DOCKER_PROXY_ENDPOINT=$(DOCKER_PROXY_ENDPOINT) bats test/swarm.bats
	@echo -e "\033[92m✱ System\033[0m"
	DOCKER_PROXY_ENDPOINT=$(DOCKER_PROXY_ENDPOINT) bats test/system.bats
	@echo -e "\033[92m✱ Cleanup\033[0m"
	DOCKER_PROXY_ENDPOINT=$(DOCKER_PROXY_ENDPOINT) bats test/cleanup.bats
