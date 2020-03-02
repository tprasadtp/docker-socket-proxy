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
    [ "$status" -eq 0 ]
}

@test "Expect OK /_ping" {
  run curl -s "http://${DOCKER_ENDPOINT}/_ping"
  [ "$status" -eq 0 ]
  [ "$output" == "OK" ]
}