#!/usr/bin/env bats

@test "GET /swarm [200|503|403]" {
  run curl -s \
    -o /dev/null \
    -w "%{http_code}" \
    "http://${DOCKER_ENDPOINT}/swarm"
  [ "$status" -eq 0 ]
  [ "$output" -eq 200 ] || [ "$output" -eq 503 ] || [ "$output" -eq 403 ]
}
