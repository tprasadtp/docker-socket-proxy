#!/usr/bin/env bats

@test "Cleanup any old image" {
  result="$(docker stop dockerproxy || true)"
  [ "$?" -eq 0 ]
}

@test "Test Run Image" {
  	run docker run -d --rm \
      --name dockerproxy \
      -v /var/run/docker.sock:/var/run/docker.sock \
      -p "${DOCKER_ENDPOINT}":2375 \
      -e AUTH=0 \
      -e BUILD=1 \
      -e COMMIT=1 \
      -e CONFIGS=1 \
      -e CONTAINERS_ATTACH=1 \
      -e CONTAINERS_CREATE=1 \
      -e CONTAINERS_EXEC=1 \
      -e CONTAINERS_PAUSE=1 \
      -e CONTAINERS_PRUNE=1 \
      -e CONTAINERS_RENAME=1 \
      -e CONTAINERS_RESIZE=1 \
      -e CONTAINERS_START=1 \
      -e CONTAINERS_UNPAUSE=1 \
      -e CONTAINERS_UPDATE=0 \
      -e CONTAINERS_WAIT=1 \
      -e CONTAINERS=1 \
      -e DISTRIBUTION=1 \
      -e DELETE=1 \
      -e EVENTS=1 \
      -e EXEC=0 \
      -e IMAGES_DELETE=1 \
      -e IMAGES=1 \
      -e INFO=1 \
      -e LOG_LEVEL=debug \
      -e NETWORKS_CONNECT=1 \
      -e NETWORKS_CREATE=1 \
      -e NETWORKS_DELETE=1 \
      -e NETWORKS_DISCONNECT=1 \
      -e NETWORKS_PRUNE=0 \
      -e NETWORKS=1 \
      -e NODES=1 \
      -e PING=1 \
      -e PLUGINS=0 \
      -e POST=1 \
      -e SECRETS=0 \
      -e SERVICES=0 \
      -e SESSION=0 \
      -e SWARM=0 \
      -e SYSTEM=1 \
      -e TASKS=0 \
      -e VERSION=1 \
      -e VOLUMES_CREATE=1 \
      -e VOLUMES_DELETE=1 \
      -e VOLUMES_PRUNE=0 \
      -e VOLUMES=1 \
      ${DOCKER_USER}/${NAME}:${DOCKER_TAG}
    [ "$status" -eq 0 ]
}

@test "Sleep a bit for container to be up" {
  run sleep 5
  [ "$status" -eq 0 ]
}

@test "Expect OK /_ping" {
  run curl -s "http://${DOCKER_ENDPOINT}/_ping"
  [ "$status" -eq 0 ]
  [ "$output" == "OK" ]
}
