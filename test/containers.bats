#!/usr/bin/env bats

@test "GET /containers" {
  run curl -s -o /dev/null -w "%{http_code}" "http://${DOCKER_ENDPOINT}/containers/json"
  [ "$status" -eq 0 ]
  [ "$output" -eq 200 ]
}

@test "FIXTURE Pull Pause container" {
  run docker pull gcr.io/google_containers/pause:latest
  [ "$status" -eq 0 ]
}

@test "POST /containers CREATE" {
  run curl -s \
  -w "%{http_code}" \
  -o /dev/null \
  -H "Content-Type: application/json" \
  -X POST \
  -d '{"Image": "gcr.io/google_containers/pause:latest", "NetworkDisabled": true}' \
  "http://${DOCKER_ENDPOINT}/containers/create?name=pause"
  [ "$status" -eq 0 ]
  [ "$output" -eq 201 ] || [ "$output" -eq 409 ]
}

@test "GET /containers INSPECT (existing)" {
  run curl -s \
  -w "%{http_code}" \
  -o /dev/null \
  "http://${DOCKER_ENDPOINT}/containers/pause/json"
  [ "$status" -eq 0 ]
  [ "$output" -eq 200 ]
}

@test "GET /containers INSPECT (non-existing)" {
  run curl -s \
  -w "%{http_code}" \
  -o /dev/null \
  "http://${DOCKER_ENDPOINT}/containers/no-such-container/json"
  [ "$status" -eq 0 ]
  [ "$output" -eq 404 ]
}

@test "GET /containers PS (existing)" {
  run curl -s \
  -w "%{http_code}" \
  -o /dev/null \
  "http://${DOCKER_ENDPOINT}/containers/dockerproxy/top"
  [ "$status" -eq 0 ]
  [ "$output" -eq 200 ]
}

@test "GET /containers PS (non-existing)" {
  run curl -s \
  -w "%{http_code}" \
  -o /dev/null \
  "http://${DOCKER_ENDPOINT}/containers/no-such-container/top"
  [ "$status" -eq 0 ]
  [ "$output" -eq 404 ]
}

@test "GET /containers DIFF (existing)" {
  run curl -s \
  -o /dev/null \
  -w "%{http_code}" \
  "http://${DOCKER_ENDPOINT}/containers/dockerproxy/changes"
  [ "$status" -eq 0 ]
  [ "$output" -eq 200 ]
}

@test "GET /containers DIFF (non-existing)" {
  run curl -s \
  -w "%{http_code}" \
  -o /dev/null \
  "http://${DOCKER_ENDPOINT}/containers/no-such-container/changes"
  [ "$status" -eq 0 ]
  [ "$output" -eq 404 ]
}

# Stats
@test "GET /containers STATS (existing)" {
  run curl -s \
  -o /dev/null \
  -w "%{http_code}" \
  "http://${DOCKER_ENDPOINT}/containers/dockerproxy/stats?stream=false"
  [ "$status" -eq 0 ]
  [ "$output" -eq 200 ]
}

@test "GET /containers STATS (non-existing)" {
  run curl -s \
  -w "%{http_code}" \
  -o /dev/null \
  "http://${DOCKER_ENDPOINT}/containers/no-such-container/stats?stream=false"
  [ "$status" -eq 0 ]
  [ "$output" -eq 404 ]
}

@test "POST /containers START (existing)" {
  run curl -s \
  -w "%{http_code}" \
  -o /dev/null \
  -X POST \
  "http://${DOCKER_ENDPOINT}/containers/pause/start"
  [ "$status" -eq 0 ]
  [ "$output" -eq 204 ] || [ "$output" -eq 304 ] || [ "$output" -eq 409 ]
}

@test "POST /containers START (non-existing)" {
  run curl -s \
  -w "%{http_code}" \
  -o /dev/null \
  -X POST \
  "http://${DOCKER_ENDPOINT}/containers/no-such-container/start"
  [ "$status" -eq 0 ]
  [ "$output" -eq 404 ]
}

@test "POST /containers STOP (existing)" {
  run curl -s \
  -w "%{http_code}" \
  -o /dev/null \
  -X POST \
  "http://${DOCKER_ENDPOINT}/containers/pause/stop"
  [ "$status" -eq 0 ]
  [ "$output" -eq 204 ] || [ "$output" -eq 304 ]
}

@test "POST /containers STOP (non-existing)" {
  run curl -s \
  -w "%{http_code}" \
  -o /dev/null \
  -X POST \
  "http://${DOCKER_ENDPOINT}/containers/no-such-container/stop"
  [ "$status" -eq 0 ]
  [ "$output" -eq 404 ]
}

@test "POST /containers RESTART (existing)" {
  run curl -s \
  -w "%{http_code}" \
  -o /dev/null \
  -X POST \
  "http://${DOCKER_ENDPOINT}/containers/pause/restart"
  [ "$status" -eq 0 ]
  [ "$output" -eq 204 ]
}

@test "POST /containers RESTART (non-existing)" {
  run curl -s \
  -w "%{http_code}" \
  -o /dev/null \
  -X POST \
  "http://${DOCKER_ENDPOINT}/containers/no-such-container/restart"
  [ "$status" -eq 0 ]
  [ "$output" -eq 404 ]
}

@test "POST /containers PAUSE (existing)" {
  run curl -s \
  -w "%{http_code}" \
  -o /dev/null \
  -X POST \
  "http://${DOCKER_ENDPOINT}/containers/pause/pause"
  [ "$status" -eq 0 ]
  [ "$output" -eq 204 ] || [ "$output" == 409 ]
}

@test "POST /containers PAUSE 404" {
  run curl -s \
  -w "%{http_code}" \
  -o /dev/null \
  -X POST \
  "http://${DOCKER_ENDPOINT}/containers/no-such-container/pause"
  [ "$status" -eq 0 ]
  [ "$output" -eq 404 ]
}

@test "POST /containers UNPAUSE 404" {
  run curl -s \
  -w "%{http_code}" \
  -o /dev/null \
  -X POST \
  "http://${DOCKER_ENDPOINT}/containers/no-such-container/unpause"
  [ "$status" -eq 0 ]
  [ "$output" -eq 404 ]
}

@test "DELETE /containers 204" {
  run curl -s \
  -w "%{http_code}" \
  -o /dev/null \
  -X DELETE \
  "http://${DOCKER_ENDPOINT}/containers/pause?force=true"
  [ "$status" -eq 0 ]
  [ "$output" -eq 204 ]
}

@test "DELETE /containers 404" {
  run curl -s \
  -w "%{http_code}" \
  -o /dev/null \
  -X DELETE \
  "http://${DOCKER_ENDPOINT}/containers/no-such-container?force=true"
  [ "$status" -eq 0 ]
  [ "$output" -eq 404 ]
}
