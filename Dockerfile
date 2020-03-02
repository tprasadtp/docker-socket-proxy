FROM haproxy:2.1-alpine

EXPOSE 2375
ENV ALLOW_RESTARTS=0 \
    AUTH=0 \
    BUILD=0 \
    COMMIT=0 \
    CONFIGS=0 \
    CONTAINERS_ATTACH=0 \
    CONTAINERS_CREATE=0 \
    CONTAINERS_EXEC=0 \
    CONTAINERS_PAUSE=0 \
    CONTAINERS_PRUNE=0 \
    CONTAINERS_RENAME=0 \
    CONTAINERS_RESIZE=0 \
    CONTAINERS_START=0 \
    CONTAINERS_UNPAUSE=0 \
    CONTAINERS_UPDATE=0 \
    CONTAINERS_WAIT=0 \
    CONTAINERS=0 \
    DISTRIBUTION=0 \
    DELETE=0 \
    EVENTS=1 \
    EXEC=0 \
    IMAGES_DELETE=0 \
    IMAGES=0 \
    INFO=0 \
    LOG_LEVEL=info \
    NETWORKS_CONNECT=0 \
    NETWORKS_CREATE=0 \
    NETWORKS_DELETE=0 \
    NETWORKS_DISCONNECT=0 \
    NETWORKS_PRUNE=0 \
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
    VOLUMES_CREATE=0 \
    VOLUMES_DELETE=0 \
    VOLUMES_PRUNE=0 \
    VOLUMES=0 \
    DOCKER_BACKEND=/var/run/docker.sock
COPY haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg

#  OCI
ARG IMAGE_TITLE
ARG IMAGE_DESC
ARG IMAGE_URL
ARG IMAGE_SOURCE
ARG IMAGE_VERSION
ARG IMAGE_REVISION
ARG IMAGE_LICENSES
ARG IMAGE_DOCUMENTATION_URL
ARG IMAGE_BUILD_HOST
ARG IMAGE_BUILD_DATE
ARG IMAGE_VENDOR="Prasad Tengse<tprasadtp@users.noreply.github.com>"

# Custom Metadata
# -----------------
# CI Which built the image
ARG IMAGE_BUILD_SYSTEM
# Usually Available on builder
ARG GITHUB_WORKFLOW
ARG GITHUB_RUN_NUMBER
ARG GITHUB_SHA_SHORT
ARG GITHUB_ACTOR
ARG GITHUB_REF

# If the tree was dirty on build
ARG GIT_TREE_DIRTY
ARG GIT_REF

LABEL org.opencontainers.image.vendor="${IMAGE_VENDOR}" \
      org.opencontainers.image.source="${IMAGE_SOURCE}" \
      org.opencontainers.image.url="${IMAGE_URL}" \
      org.opencontainers.image.revision="${IMAGE_REVISION}" \
      org.opencontainers.image.documentation="${IMAGE_DOCUMENTATION_URL}" \
      org.opencontainers.image.title="${IMAGE_TITLE}" \
      org.opencontainers.image.description="${IMAGE_DESC}" \
      org.opencontainers.image.version="${IMAGE_VERSION}" \
      org.opencontainers.image.licenses="${IMAGE_LICENSES}" \
      io.github.tprasadtp.build.system="${IMAGE_BUILD_SYSTEM}" \
      io.github.tprasadtp.build.host="${IMAGE_BUILD_HOST}" \
      io.github.tprasadtp.build.date="${IMAGE_BUILD_DATE}" \
      io.github.tprasadtp.actions.workflow="${GITHUB_WORKFLOW}" \
      io.github.tprasadtp.actions.build="${GITHUB_RUN_NUMBER}" \
      io.github.tprasadtp.actions.actor="${GITHUB_ACTOR}" \
      io.github.tprasadtp.actions.ref="${GITHUB_REF}" \
      io.github.tprasadtp.git.ref="${GIT_REF}" \
      io.github.tprasadtp.git.short-sha="${GITHUB_SHA_SHORT}" \
      io.github.tprasadtp.git.dirty="${GIT_TREE_DIRTY}"

