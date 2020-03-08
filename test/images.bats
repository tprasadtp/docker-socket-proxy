#!/usr/bin/env bats

@test "GET /images IMAGES [200]" {
  run curl -s -o /dev/null -w "%{http_code}" "http://${DOCKER_ENDPOINT}/images/json"
  [ "$status" -eq 0 ]
  [ "$output" -eq 200 ]
}

@test "GET /images INSPECT [200]" {
  run curl -s \
  -w "%{http_code}" \
  -o /dev/null \
  "http://${DOCKER_ENDPOINT}/images/gcr.io/google_containers/pause:latest/json"
  [ "$status" -eq 0 ]
  [ "$output" -eq 200 ]
}

@test "GET /containers INSPECT [404]" {
  run curl -s \
  -w "%{http_code}" \
  -o /dev/null \
  "http://${DOCKER_ENDPOINT}/images/gcr.io/google_containers/pause:no-such-tag/json"
  [ "$status" -eq 0 ]
  [ "$output" -eq 404 ]
}

@test "GET /images HISTORY [200]" {
  run curl -s \
  -w "%{http_code}" \
  -o /dev/null \
  "http://${DOCKER_ENDPOINT}/images/gcr.io/google_containers/pause:latest/history"
  [ "$status" -eq 0 ]
  [ "$output" -eq 200 ]
}

@test "GET /images HISTORY [404]" {
  run curl -s \
  -w "%{http_code}" \
  -o /dev/null \
  "http://${DOCKER_ENDPOINT}/images/gcr.io/google_containers/pause:no-such-tag/history"
  [ "$status" -eq 0 ]
  [ "$output" -eq 404 ]
}

@test "GET /images HISTORY [200]" {
  run curl -s \
  -w "%{http_code}" \
  -o /dev/null \
  "http://${DOCKER_ENDPOINT}/images/gcr.io/google_containers/pause:latest/history"
  [ "$status" -eq 0 ]
  [ "$output" -eq 200 ]
}

# Why pause no out own image? Because we have not pushed out latest tag yet to registry.
# Also we might have tagged it differently
@test "POST /images PULL (via create API)" {
  run curl -s \
  -w "%{http_code}" \
  -o /dev/null \
  -X POST \
  "http://${DOCKER_ENDPOINT}/images/create?fromImage=gcr.io/google_containers/pause&tag=latest"
  [ "$status" -eq 0 ]
  [ "$output" -eq 200 ]
}

@test "POST /images PULL (via create API) [404]" {
  run curl -s \
  -w "%{http_code}" \
  -o /dev/null \
  -X POST \
  "http://${DOCKER_ENDPOINT}/images/create?fromImage=gcr.io/google_containers/pause&tag=no-such-tag"
  [ "$status" -eq 0 ]
  [ "$output" -eq 404 ]
}

@test "POST /images TAG [201]" {
  run curl -s \
  -w "%{http_code}" \
  -o /dev/null \
  -X POST \
  "http://${DOCKER_ENDPOINT}/images/gcr.io/google_containers/pause:latest/tag?repo=mika&tag=tauriel"
  [ "$status" -eq 0 ]
  [ "$output" -eq 201 ]
}

@test "POST /images TAG [404]" {
  run curl -s \
  -w "%{http_code}" \
  -o /dev/null \
  -X POST \
  "http://${DOCKER_ENDPOINT}/images/gcr.io/google_containers/pause:no-such-tag/tag?repo=mika&tag=tauriel"
  [ "$status" -eq 0 ]
  [ "$output" -eq 404 ]
}

@test "DELETE /images TAG [200]" {
  run curl -s \
  -w "%{http_code}" \
  -o /dev/null \
  -X DELETE \
  "http://${DOCKER_ENDPOINT}/images/gcr.io/google_containers/pause:latest"
  [ "$status" -eq 0 ]
  [ "$output" -eq 200 ]
}

@test "DELETE /images TAG [404]" {
  run curl -s \
  -w "%{http_code}" \
  -o /dev/null \
  -X DELETE \
  "http://${DOCKER_ENDPOINT}/images/gcr.io/google_containers/pause:latest"
  [ "$status" -eq 0 ]
  [ "$output" -eq 404 ]
}
