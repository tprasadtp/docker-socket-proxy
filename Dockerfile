FROM haproxy:1.9-alpine

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
    VOLUMES=0
COPY haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg

# Metadata
ARG GITHUB_SHA
ARG GITHUB_WORKFLOW
ARG GITHUB_RUN_NUMBER
ARG VERSION
ARG GIT_TREE_DIRTY=false

LABEL org.opencontainers.image.authors="Prasad Tengse<tprasadtp@users.noreply.github.com>" \
      org.opencontainers.image.source="https://github.com/tprasadtp/forklift" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.licenses="Apache-2.0" \
      com.github.actions.workflow="${GITHUB_WORKFLOW}" \
      com.github.actions.run="${GITHUB_RUN_NUMBER}" \
      vcs.git.upstream.url="https://github.com/Tecnativa/docker-socket-proxy" \
      vcs.git.upstream.vendor="https://github.com/Tecnativa" \
      vcs.git.commit.sha="${GITHUB_SHA}" \
      vsc.git.commit.tree.dirty="${GIT_TREE_DIRTY}"
