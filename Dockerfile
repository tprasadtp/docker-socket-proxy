FROM haproxy:2.1-alpine

EXPOSE 2375
ENV ALLOW_RESTARTS=0 \
    AUTH=0 \
    BUILD=0 \
    COMMIT=0 \
    CONFIGS=0 \
    CONTAINERS=0 \
    DISTRIBUTION=0 \
    EVENTS=1 \
    EXEC=0 \
    IMAGES=0 \
    INFO=0 \
    LOG_LEVEL=info \
    NETWORKS=0 \
    NODES=0 \
    PING=1 \
    PLUGINS=0 \
    POST=0 \
    SECRETS=0 \
    SERVICES=0 \
    SESSION=0 \
    SWARM=0 \
    SYSTEM=0 \
    TASKS=0 \
    VERSION=1 \
    VOLUMES=0 \
    DOCKER_BACKEND=/var/run/docker.sock
COPY haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg

# OCI
ARG IMAGE_TITLE
ARG IMAGE_DESC
ARG IMAGE_URL
ARG IMAGE_SOURCE
ARG IMAGE_VERSION
ARG IMAGE_LICENSES
ARG IMAGE_DOCUMENTATION_URL
ARG IMAGE_VENDOR="Prasad Tengse<tprasadtp@users.noreply.github.com>"

# Custom Metadata
# -----------------
# CI Which built the image
ARG IMAGE_BUILD_SYSTEM
# Usually Available on builder
ARG GITHUB_WORKFLOW
ARG GITHUB_RUN_NUMBER
ARG GITHUB_REF
ARG GITHUB_SHA
ARG GITHUB_ACTOR

# Upstream Metadata
ARG UPSTREAM_URL
ARG UPSTREAM_AUTHOR

# If the tree was dirty on build
ARG GIT_TREE_DIRTY

LABEL org.opencontainers.image.vendor="${IMAGE_VENDOR}" \
      org.opencontainers.image.source="${IMAGE_SOURCE}" \
      org.opencontainers.image.url="${IMAGE_URL}" \
      org.opencontainers.image.revision="${GITHUB_SHA}" \
      org.opencontainers.image.documentation="${IMAGE_DOCUMENTATION_URL}" \
      org.opencontainers.image.title="${IMAGE_TITLE}" \
      org.opencontainers.image.description="${IMAGE_DESC}" \
      org.opencontainers.image.version="${IMAGE_VERSION}" \
      org.opencontainers.image.licenses="${IMAGE_LICENSES}" \
      io.github.tprasadtp.build.system="${IMAGE_BUILD_SYSTEM}" \
      io.github.tprasadtp.actions.workflow="${GITHUB_WORKFLOW}" \
      io.github.tprasadtp.actions.build="${GITHUB_RUN_NUMBER}" \
      io.github.tprasadtp.actions.ref="${GITHUB_REF}" \
      io.github.tprasadtp.actions.actor="${GITHUB_ACTOR}" \
      io.github.tprasadtp.upstream.url="${UPSTREAM_URL}" \
      io.github.tprasadtp.upstream.author="${UPSTREAM_AUTHOR}" \
      io.github.tprasadtp.commit.dirty="${GIT_TREE_DIRTY}"
