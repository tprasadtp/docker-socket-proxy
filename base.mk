# Set the shell
SHELL ?= /bin/bash

# Base of operations
ROOT_DIR ?= $(strip $(patsubst %/, %, $(dir $(realpath $(firstword $(MAKEFILE_LIST))))))
# SEMVER_REGEX := ^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$

DOCKER_CONTEXT_DIR ?= $(ROOT_DIR)

# Default Goal
.DEFAULT_GOAL := help

ifeq ($(GITHUB_ACTIONS),true)
	# Parse REF. This can be tag or branch or PR.
	GIT_REF := $(strip $(shell echo "${GITHUB_REF}" | sed -r 's/refs\/(heads|tags|pull)\///g;s/[\/\*\#]+/-/g'))
	GITHUB_SHA_SHORT := $(shell echo "$${GITHUB_SHA:0:7}")
	GIT_TREE_DIRTY := false
	IMAGE_BUILD_SYSTEM := actions
	IMAGE_BUILD_HOST := $(shell hostname -f)
else
	# If in detached head state this will give HEAD
	BRANCH := $(strip $(shell git rev-parse --abbrev-ref HEAD | sed -r 's/[\/\*\#]+/-/g'))
	# Get Tag
	GIT_TAG := $(strip $(shell git describe --exact-match --tags $(git log -n1 --pretty='%h') 2> /dev/null))
	# Generate GITHUB_* vars
	GITHUB_SHA := $(shell git log -1 --pretty=format:"%H")
	GITHUB_SHA_SHORT := $(shell git log -1 --pretty=format:"%h")
	# Set build system to local
	IMAGE_BUILD_SYSTEM := local
	IMAGE_BUILD_HOST := localhost

	# Get list of untracked changes
	GIT_UNTRACKED_CHANGES := $(shell git status --porcelain --untracked-files=no)

	# We are now in detached HEAD state.
	ifeq ($(BRANCH),HEAD)
		__GIT_REF := $(GIT_SHA_SHORT)
	# We are on master branch
	else ifeq ($(BRANCH),master)
		__GIT_REF := master
	# None
	else
		__GIT_REF := $(BRANCH)
	endif

	# Check if dirty and deal with tags
	ifeq ($(GIT_UNTRACKED_CHANGES),)
		# Tree is clean
		GIT_TREE_DIRTY := false
		ifeq ($(GIT_TAG),)
			GIT_REF := $(__GIT_REF)
		else
			GIT_REF := $(GIT_TAG)
		endif
	else
		GIT_TREE_DIRTY := true
		GIT_REF := $(__GIT_REF)
	endif
endif


# Version
ifeq ($(GIT_REF), master)
	DOCKER_TAG ?= latest
else
	DOCKER_TAG ?= $(GIT_REF)
endif

# Enable Buidkit if not disabled
DOCKER_BUILDKIT ?= 1

# Assign default docker user
DOCKER_USER ?= tprasadtp

# Version Override only
# Only if not assigned
VERSION ?= $(GIT_REF)

# For forks
IS_FORK ?= false

# Builder metadata
IMAGE_BUILD_DATE := "$(shell date --rfc-3339=seconds)"

.PHONY: docker-lint
docker-lint: ## Runs the linter on Dockerfiles.
	@echo -e "\033[92m➜ $@ \033[0m"
	docker run --rm -i hadolint/hadolint < $(DOCKER_CONTEXT_DIR)/Dockerfile

.PHONY: docker-cross-push
docker-cross-push: ## Build docker image and push(buildx).
	@echo -e "\033[92m➜ $@ \033[0m"
	@echo -e "\033[92m↠ Building Docker Image $(DOCKER_USER)/$(NAME):$(DOCKER_TAG)\033[0m"
	DOCKER_BUILDKIT=$(DOCKER_BUILDKIT) docker buildx build \
		-t $(DOCKER_USER)/$(NAME):$(DOCKER_TAG) \
    --platform linux/amd64,linux/arm64,linux/arm/v7 \
    --push \
		--build-arg IMAGE_TITLE=$(IMAGE_TITLE) \
		--build-arg IMAGE_DESC=$(IMAGE_DESC)\
		--build-arg IMAGE_URL=$(IMAGE_URL) \
		--build-arg IMAGE_SOURCE=$(IMAGE_SOURCE) \
		--build-arg IMAGE_VERSION=$(VERSION) \
		--build-arg IMAGE_REVISION=$(GITHUB_SHA) \
		--build-arg IMAGE_LICENSES=$(IMAGE_LICENSES) \
		--build-arg IMAGE_DOCUMENTATION_URL=$(IMAGE_DOCUMENTATION_URL) \
		--build-arg IMAGE_BUILD_SYSTEM=$(IMAGE_BUILD_SYSTEM) \
		--build-arg IMAGE_BUILD_DATE=$(IMAGE_BUILD_DATE) \
		--build-arg IMAGE_BUILD_HOST=$(IMAGE_BUILD_HOST) \
		--build-arg GITHUB_WORKFLOW=$(GITHUB_WORKFLOW) \
		--build-arg GITHUB_RUN_NUMBER=$(GITHUB_RUN_NUMBER) \
		--build-arg GITHUB_REF=$(GITHUB_REF) \
		--build-arg GITHUB_ACTOR=$(GITHUB_ACTOR) \
		--build-arg GIT_REF=$(GIT_REF) \
		--build-arg GITHUB_SHA_SHORT=$(GITHUB_SHA_SHORT) \
		--build-arg GIT_TREE_DIRTY=$(GIT_TREE_DIRTY) \
		--build-arg IS_FORK=$(IS_FORK) \
		--build-arg UPSTREAM_URL=$(UPSTREAM_URL) \
		--build-arg UPSTREAM_AUTHOR=$(UPSTREAM_AUTHOR) \
		-f $(DOCKER_CONTEXT_DIR)/Dockerfile \
		$(DOCKER_CONTEXT_DIR)/
	docker buildx imagetools inspect $(DOCKER_USER)/$(NAME):$(DOCKER_TAG)

.PHONY: docker-cross-build
docker-cross-build: ## Build docker image (buildx).
	@echo -e "\033[92m➜ $@ \033[0m"
	@echo -e "\033[92m↠ Building Docker Image $(DOCKER_USER)/$(NAME):$(DOCKER_TAG)\033[0m"
	DOCKER_BUILDKIT=$(DOCKER_BUILDKIT) docker buildx build \
		-t $(DOCKER_USER)/$(NAME):$(DOCKER_TAG) \
    --platform linux/amd64,linux/arm64,linux/arm/v7 \
		--build-arg IMAGE_TITLE=$(IMAGE_TITLE) \
		--build-arg IMAGE_DESC=$(IMAGE_DESC)\
		--build-arg IMAGE_URL=$(IMAGE_URL) \
		--build-arg IMAGE_SOURCE=$(IMAGE_SOURCE) \
		--build-arg IMAGE_VERSION=$(VERSION) \
		--build-arg IMAGE_REVISION=$(GITHUB_SHA) \
		--build-arg IMAGE_LICENSES=$(IMAGE_LICENSES) \
		--build-arg IMAGE_DOCUMENTATION_URL=$(IMAGE_DOCUMENTATION_URL) \
		--build-arg IMAGE_BUILD_SYSTEM=$(IMAGE_BUILD_SYSTEM) \
		--build-arg IMAGE_BUILD_DATE=$(IMAGE_BUILD_DATE) \
		--build-arg IMAGE_BUILD_HOST=$(IMAGE_BUILD_HOST) \
		--build-arg GITHUB_WORKFLOW=$(GITHUB_WORKFLOW) \
		--build-arg GITHUB_RUN_NUMBER=$(GITHUB_RUN_NUMBER) \
		--build-arg GITHUB_REF=$(GITHUB_REF) \
		--build-arg GITHUB_ACTOR=$(GITHUB_ACTOR) \
		--build-arg GIT_REF=$(GIT_REF) \
		--build-arg GITHUB_SHA_SHORT=$(GITHUB_SHA_SHORT) \
		--build-arg GIT_TREE_DIRTY=$(GIT_TREE_DIRTY) \
		--build-arg IS_FORK=$(IS_FORK) \
		--build-arg UPSTREAM_URL=$(UPSTREAM_URL) \
		--build-arg UPSTREAM_AUTHOR=$(UPSTREAM_AUTHOR) \
		-f $(DOCKER_CONTEXT_DIR)/Dockerfile \
		$(DOCKER_CONTEXT_DIR)/
	docker buildx imagetools inspect $(DOCKER_USER)/$(NAME):$(DOCKER_TAG)


.PHONY: docker
docker: ## Build docker image.
	@echo -e "\033[92m➜ $@ \033[0m"
	@echo -e "\033[92m↠ Building Docker Image $(DOCKER_USER)/$(NAME):$(DOCKER_TAG)\033[0m"
	DOCKER_BUILDKIT=$(DOCKER_BUILDKIT) docker build \
		-t $(DOCKER_USER)/$(NAME):$(DOCKER_TAG) \
		--build-arg IMAGE_TITLE=$(IMAGE_TITLE) \
		--build-arg IMAGE_DESC=$(IMAGE_DESC)\
		--build-arg IMAGE_URL=$(IMAGE_URL) \
		--build-arg IMAGE_SOURCE=$(IMAGE_SOURCE) \
		--build-arg IMAGE_VERSION=$(VERSION) \
		--build-arg IMAGE_REVISION=$(GITHUB_SHA) \
		--build-arg IMAGE_LICENSES=$(IMAGE_LICENSES) \
		--build-arg IMAGE_DOCUMENTATION_URL=$(IMAGE_DOCUMENTATION_URL) \
		--build-arg IMAGE_BUILD_SYSTEM=$(IMAGE_BUILD_SYSTEM) \
		--build-arg IMAGE_BUILD_DATE=$(IMAGE_BUILD_DATE) \
		--build-arg IMAGE_BUILD_HOST=$(IMAGE_BUILD_HOST) \
		--build-arg GITHUB_WORKFLOW=$(GITHUB_WORKFLOW) \
		--build-arg GITHUB_RUN_NUMBER=$(GITHUB_RUN_NUMBER) \
		--build-arg GITHUB_REF=$(GITHUB_REF) \
		--build-arg GITHUB_ACTOR=$(GITHUB_ACTOR) \
		--build-arg GIT_REF=$(GIT_REF) \
		--build-arg GITHUB_SHA_SHORT=$(GITHUB_SHA_SHORT) \
		--build-arg GIT_TREE_DIRTY=$(GIT_TREE_DIRTY) \
		--build-arg IS_FORK=$(IS_FORK) \
		--build-arg UPSTREAM_URL=$(UPSTREAM_URL) \
		--build-arg UPSTREAM_AUTHOR=$(UPSTREAM_AUTHOR) \
		-f $(DOCKER_CONTEXT_DIR)/Dockerfile \
		$(DOCKER_CONTEXT_DIR)/

.PHONY: docker-push
docker-push: ## Push docker image.
	@echo -e "\033[92m➜ $@ \033[0m"
	@echo -e "\033[92m↠ Pushing $(DOCKER_USER)/$(NAME):$(DOCKER_TAG) [DockerHub]\033[0m"
	docker push $(DOCKER_USER)/$(NAME):$(DOCKER_TAG)

.PHONY: help
help: ## This help dialog.
	@IFS=$$'\n' ; \
    help_lines=(`fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##/:/'`); \
	printf "%-32s %s\n" " Target " "    Help " ; \
    printf "%-32s %s\n" "--------" "------------" ; \
    for help_line in $${help_lines[@]}; do \
        IFS=$$':' ; \
        help_split=($$help_line) ; \
        help_command="$$(echo $${help_split[0]} | sed -e 's/^ *//' -e 's/ *$$//')" ; \
        help_info="$$(echo $${help_split[2]} | sed -e 's/^ *//' -e 's/ *$$//')" ; \
        printf '\033[92m'; \
        printf "↠ %-30s %s" $$help_command ; \
        printf '\033[0m'; \
        printf "%s\n" $$help_info; \
    done

.PHONY: debug-vars
debug-vars:
	@echo "ROOT_DIR: $(ROOT_DIR)"
	@echo "DOCKER_CONTEXT_DIR: $(DOCKER_CONTEXT_DIR)"
	@echo "GITHUB_ACTIONS: $(GITHUB_ACTIONS)"
	@echo "GITHUB_WORKFLOW: $(GITHUB_WORKFLOW)"
	@echo "GITHUB_EVENT: $(GITHUB_EVENT)"
	@echo "GITHUB_RUN_NUMBER: $(GITHUB_RUN_NUMBER)"
	@echo "GITHUB_REF: $(GITHUB_REF)"
	@echo "BRANCH: $(BRANCH)"
	@echo "GITHUB_SHA: $(GITHUB_SHA)"
	@echo "GITHUB_SHA_SHORT: $(GITHUB_SHA_SHORT)"
	@echo "GIT_TREE_DIRTY: $(GIT_TREE_DIRTY)"
	@echo "GIT_REF: $(GIT_REF)"
	@echo "GIT_TAG: $(GIT_TAG)"
	@echo "DOCKER_TAG : $(DOCKER_TAG)"
	@echo "DOCKER_BUILDKIT: $(DOCKER_BUILDKIT)"
