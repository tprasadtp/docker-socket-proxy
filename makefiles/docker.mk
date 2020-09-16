# BEGIN-DOCKER-TEMPLATE
# TEMPLATE_VERSION: 2.0.1

# Docker Makefile. This sould be used along with help.mk
# But **AFTER** defining all variables.

# Docker build context directory. If not specified, . is assumed!
DOCKER_CONTEXT_DIR ?= .

# Full path, including filename for Dockerfile. If not specified, ./Dockerfile is assumed
DOCKERFILE_PATH  ?= ./Dockerfile

# Extra Arguments, useful to pass --build-arg.
# DOCKER_EXTRA_ARGS

# Enable Buidkit if not already disabled
DOCKER_BUILDKIT  ?= 1

# buildx settings
BUILDX_ENABLE    ?= 0
BUILDX_PUSH      ?= 0
BUILDX_PLATFORMS ?= linux/amd64,linux/arm64,linux/arm/v7

# Builder metadata
IMAGE_VENDOR     ?= Prasad Tengse <tprasadtp@users.noreply.github.com>

# We need to quote this to avoid issues with command
IMAGE_BUILD_DATE := $(shell date --rfc-3339=seconds)

ifeq ($(GITHUB_ACTIONS),true)
	# We are running in GITHUB CI,
	# Parse GITHUB_REF and GITHUB_SHA
	# We will extract the
	#  - Branch name in branch push builds
	#  - Tagname in tag push builds
	#  - Pull request number in PR builds.
	GIT_REF            := $(strip $(shell echo "$${GITHUB_REF}" | sed -r 's/refs\/(heads|tags|pull)\///g;s/[\/\*\#]+/-/g'))
	GIT_SHA_SHORT      := $(shell echo "$${GITHUB_SHA:0:7}")
	# Its a CI build and we are not changing anything, so assume git tree is clean.
	GIT_DIRTY          := false
	IMAGE_BUILD_SYSTEM := actions
	IMAGE_BUILD_HOST   := $(shell hostname -f)
else
	# If in detached head state this will give HEAD, just keep it in your HEAD :P
	GIT_BRANCH := $(strip $(shell git rev-parse --abbrev-ref HEAD | sed -r 's/[\/\*\#]+/-/g'))

	# Get latest tag. This will be empty if there are no tags pointing at HEAD
	# on actions build, tag triggers a separate build, GITHUB_REF handles it.
	GIT_TAG := $(strip $(shell git describe --exact-match --tags $(git log -n1 --pretty='%h') 2> /dev/null))

	# Generate GITHUB_* vars on local build
	GITHUB_ACTIONS     := false

	# Commit details
	GITHUB_SHA         := $(shell git log -1 --pretty=format:"%H")
	GIT_SHA_SHORT      := $(shell git log -1 --pretty=format:"%h")

	# Builder details

	# Do not leak local/internal hostnames if its not running in CI.
	IMAGE_BUILD_HOST   := localhost
	IMAGE_BUILD_SYSTEM := local

	# Following are only valid on ACTIONS. They are of
	# little importance on local builds. but assign them anyway for
	# consitancy. Build Numbers and values are not valid.
	GITHUB_RUN_NUMBER  := 0
	GITHUB_ACTOR       := NA
	GITHUB_WORKFLOW    := NA
	GITHUB_REF         := NA


	# Get list of changes files
	GIT_UNTRACKED_CHANGES := $(shell git status --porcelain --untracked-files=no)

	# GIT_REF
	# In local builds, if we have a tag pointing at HEAD && our git tree is not dirty, set GIT_REF to GIT_TAG.
	# Otherwise set this to GIT_BRANCH
	GIT_REF    := $(shell if [[ "$(GIT_UNTRACKED_CHANGES)" == "" ]] && [[ "$(GIT_TAG)" != "" ]]; then echo "$(GIT_TAG)"; else echo "$(GIT_BRANCH)"; fi )
	GIT_DIRTY  := $(shell if [[ "$(GIT_UNTRACKED_CHANGES)" == "" ]]; then echo "false"; else echo "true"; fi)
endif


# Now start building docker tags
# If we are on master set version to latest.
ifeq ($(GIT_REF),master)
	DOCKER_TAGS := $(foreach __REG,$(DOCKER_IMAGES),$(__REG):latest)
else
	DOCKER_TAGS := $(foreach __REG,$(DOCKER_IMAGES),$(__REG):$(GIT_REF))
endif

# Add Additional Tags if VERSION is defined already
# AKA if VERSION is defined, WE WILL add ttag image:$(VERSION) to docker tags. This is
# independent of git tags.
ifneq ($(VERSION),)
	# VERSION is NOT empty, assign tags.
	DOCKER_TAGS   += $(foreach __REG,$(DOCKER_IMAGES),$(__REG):$(VERSION))
	IMAGE_VERSION := $(VERSION)
else
	IMAGE_VERSION := $(GIT_REF)
endif

# Add GIT_SHA_SHORT to docker tags
DOCKER_TAGS += $(foreach __REG,$(DOCKER_IMAGES),$(__REG):$(GIT_SHA_SHORT))

# Check if we have buildx enabled
ifeq ($(BUILDX_ENABLE),1)
	DOCKER_BUILD_COMMAND  := buildx build --platform $(BUILDX_PLATFORMS) $(shell if [[ "$(BUILDX_PUSH)" == "1" ]]; then echo "--push"; fi)
	DOCKER_INSPECT_ARGS   := buildx imagetools inspect --raw $(firstword $(DOCKER_TAGS)) | jq "."
else
	DOCKER_BUILD_COMMAND  := build
	DOCKER_INSPECT_ARGS   := image inspect $(firstword $(DOCKER_TAGS)) | jq ".[].Config.Labels"
endif

# Build --tag argument
DOCKER_TAG_ARGS := $(addprefix --tag ,$(DOCKER_TAGS))

# IF DOCKER_TARGET is defined, use it
ifneq ($(DOCKER_TARGET),)
	DOCKER_BUILD_COMMAND += --target "$(DOCKER_TARGET)"
endif

.PHONY: docker-check-variables
docker-check-variables: ## Check if required variables are defined
	@echo -e "\033[92m➜ $@ \033[0m"
	$(call check_defined, DOCKER_IMAGES, Docker Images)
	$(call check_defined, IMAGE_TITLE, Image title for OCI annotations)
	$(call check_defined, IMAGE_DESC, Image description for OCI annotations)
	$(call check_defined, IMAGE_URL, Image description for OCI annotations)
	$(call check_defined, IMAGE_SOURCE, Image Source URL for OCI annotations)
	$(call check_defined, IMAGE_LICENSES, Licenses in SPDX License Expression format)
	$(call check_defined, IMAGE_DOCUMENTATION, Image Documentation URL for OCI annotations)
	@echo -e "\033[92m✔ \033[0mRequired variables are defined"

.PHONY: docker-lint
docker-lint: ## Runs the linter on Dockerfiles.
	@echo -e "\033[92m➜ $@ \033[0m"
	docker run --rm -i hadolint/hadolint < "$(DOCKERFILE_PATH)"

.PHONY: docker
docker: docker-check-variables ## Build docker image.
	@echo -e "\033[92m➜ $@ \033[0m"
	@echo -e "\033[92m🐳 Building Docker Image \033[0m"
	DOCKER_BUILDKIT=$(DOCKER_BUILDKIT) docker \
    $(DOCKER_BUILD_COMMAND) \
    $(DOCKER_TAG_ARGS) \
    $(DOCKER_EXTRA_ARGS) \
    --label org.opencontainers.image.created="$(IMAGE_BUILD_DATE)" \
    --label org.opencontainers.image.description="$(IMAGE_DESC)" \
    --label org.opencontainers.image.documentation="$(IMAGE_DOCUMENTATION)" \
    --label org.opencontainers.image.licenses="$(IMAGE_LICENSES)" \
    --label org.opencontainers.image.revision="$(GITHUB_SHA)" \
    --label org.opencontainers.image.source="$(IMAGE_SOURCE)" \
    --label org.opencontainers.image.title="$(IMAGE_TITLE)" \
    --label org.opencontainers.image.url="$(IMAGE_URL)" \
    --label org.opencontainers.image.vendor="$(IMAGE_VENDOR)" \
    --label org.opencontainers.image.version="$(IMAGE_VERSION)" \
    --label io.github.tprasadtp.meta="3" \
    --label io.github.tprasadtp.build.system="$(IMAGE_BUILD_SYSTEM)" \
    --label io.github.tprasadtp.build.host="$(IMAGE_BUILD_HOST)" \
    --label io.github.tprasadtp.actions.workflow="$(GITHUB_WORKFLOW)" \
    --label io.github.tprasadtp.actions.build="$(GITHUB_RUN_NUMBER)" \
    --label io.github.tprasadtp.actions.actor="$(GITHUB_ACTOR)" \
    --label io.github.tprasadtp.actions.ref="$(GITHUB_REF)" \
    --label io.github.tprasadtp.git.commit="$(GIT_SHA_SHORT)" \
    --label io.github.tprasadtp.git.dirty="$(GIT_DIRTY)" \
    --file $(DOCKERFILE_PATH) \
    $(DOCKER_CONTEXT_DIR)

.PHONY: docker-inspect
docker-inspect: docker-check-variables ## Inspect Labels of the container [Build First!]
	@echo -e "\033[92m➜ $@ \033[0m"
	docker $(DOCKER_INSPECT_ARGS)

.PHONY: docker-push
docker-push: docker-check-variables ## Push docker image.
	@echo -e "\033[92m➜ $@ \033[0m"
	@for tag in $(DOCKER_TAGS); do \
		echo -e "\033[92m🐳 Pushing $${tag}\033[0m\n" \
	  docker push "$${img}"; \
		done

# Print Docker Tags
define print_docker_tags
	@for tag in $(DOCKER_TAGS); do echo "🐳 $${tag}"; done
endef


.PHONY: show-docker-tags
show-docker-tags: docker-check-variables ## Show Docker Image Tags
	@echo "------------- Docker Tags ---------------------"
	$(call print_docker_tags)

.PHONY: show-docker-vars
show-docker-vars:
	@echo "------------  DOCKER VARIABLES ---------------"
	@echo "DOCKER_IMAGES        : $(DOCKER_IMAGES)"
	@echo "--------------  DOCKER TAGS ------------------"
	$(call print_docker_tags)
	@echo "-------------- PATH VARIABLES ----------------"
	@echo "DOCKER_CONTEXT_DIR   : $(DOCKER_CONTEXT_DIR)"
	@echo "DOCKERFILE_PATH      : $(DOCKERFILE_PATH)"
	@echo "------------- BUILD VARIABLES ----------------"
	@echo "DOCKER_BUILDKIT      : $(DOCKER_BUILDKIT)"
	@echo "BUILDX_ENABLE        : $(BUILDX_ENABLE)"
	@echo "BUILDX_PUSH          : $(BUILDX_PUSH)"
	@echo "DOCKER_TARGET        : $(DOCKER_TARGET)"
	@echo "BUILDX_PLATFORMS     : $(BUILDX_PLATFORMS)"
	@echo "DOCKER_BUILD_COMMAND : $(DOCKER_BUILD_COMMAND)"
	@echo "DOCKER_EXTRA_ARGS    : $(DOCKER_EXTRA_ARGS)"
	@echo "DOCKER_INSPECT_ARGS  : $(DOCKER_INSPECT_ARGS)"
	@echo "------------- ACTION VARIABLES ----------------"
	@echo "GITHUB_ACTIONS       : $(GITHUB_ACTIONS)"
	@echo "GITHUB_WORKFLOW      : $(GITHUB_WORKFLOW)"
	@echo "GITHUB_RUN_NUMBER    : $(GITHUB_RUN_NUMBER)"
	@echo "GITHUB_REF           : $(GITHUB_REF)"
	@echo "-------------- GIT VARIABLES ------------------"
	@echo "GIT_BRANCH           : $(GIT_BRANCH)"
	@echo "GITHUB_SHA           : $(GITHUB_SHA)"
	@echo "GIT_SHA_SHORT        : $(GIT_SHA_SHORT)"
	@echo "GIT_REF              : $(GIT_REF)"
	@echo "GIT_TAG              : $(GIT_TAG)"
	@echo "GIT_DIRTY            : $(GIT_DIRTY)"

# END-DOCKER-TEMPLATE
