#!/usr/bin/env bats

@test "GET /info [403]" {
  run curl -s -o /dev/null -w "%{http_code}" "http://${DOCKER_PROXY_ENDPOINT}/plugins"
  [ "$status" -eq 0 ]
  [ "$output" -eq 403 ]
}

@test "GET /info [200]" {
  run curl -s -o /dev/null -w "%{http_code}" "http://${DOCKER_PROXY_ENDPOINT}/info"
  [ "$status" -eq 0 ]
  [ "$output" -eq 200 ]
}

@test "GET /version [200]" {
  run curl -s -o /dev/null -w "%{http_code}" "http://${DOCKER_PROXY_ENDPOINT}/version"
  [ "$status" -eq 0 ]
  [ "$output" -eq 200 ]
}

@test "GET /_ping [200]" {
  run curl -s -o /dev/null -w "%{http_code}" "http://${DOCKER_PROXY_ENDPOINT}/_ping"
  [ "$status" -eq 0 ]
  [ "$output" -eq 200 ]
}

@test "HEAD /_ping [200]" {
  run curl -s -o /dev/null -w "%{http_code}" "http://${DOCKER_PROXY_ENDPOINT}/_ping"
  [ "$status" -eq 0 ]
  [ "$output" -eq 200 ]
}

@test "GET /system/df [200]" {
  run curl -s -o /dev/null -w "%{http_code}" "http://${DOCKER_PROXY_ENDPOINT}/system/df"
  [ "$status" -eq 0 ]
  [ "$output" -eq 200 ]
}
