#!/usr/bin/env bats

@test "GET /volumes VOLUME (Check with existing  volume)" {
  run curl -s -o /dev/null -w "%{http_code}" "http://${DOCKER_PROXY_ENDPOINT}/volumes"
  [ "$status" -eq 0 ]
  [ "$output" -eq 200 ]
}

@test "POST /volumes CREATE [201]" {
  run curl -s \
  -w "%{http_code}" \
  -o /dev/null \
  -H "Content-Type: application/json" \
  -X POST \
  -d '{"Name": "delete-this-volume", "Driver": "local"}' \
  "http://${DOCKER_PROXY_ENDPOINT}/volumes/create"
  [ "$status" -eq 0 ]
  [ "$output" -eq 201 ] || [ "$output" -eq 409 ]
}

@test "GET /networks INSPECT (Check with existing  volume)" {
  run curl -s -o /dev/null -w "%{http_code}" "http://${DOCKER_PROXY_ENDPOINT}/volumes/delete-this-volume"
  [ "$status" -eq 0 ]
  [ "$output" -eq 200 ]
}

@test "GET /volumes INSPECT (Check with non-existing  volume)" {
  run curl -s -o /dev/null -w "%{http_code}" "http://${DOCKER_PROXY_ENDPOINT}/volumes/no-such-volume"
  [ "$status" -eq 0 ]
  [ "$output" -eq 404 ]
}

@test "DELETE /volumes RM [204]" {
  run curl -s -o /dev/null \
    -X DELETE \
    -w "%{http_code}" \
    "http://${DOCKER_PROXY_ENDPOINT}/volumes/delete-this-volume"
  [ "$status" -eq 0 ]
  [ "$output" -eq 204 ]
}

@test "DELETE /volumes RM (Check with non-existing  volume)" {
  run curl -s -o /dev/null \
    -X DELETE \
    -w "%{http_code}" \
    "http://${DOCKER_PROXY_ENDPOINT}/volumes/no-such-volume"
  [ "$status" -eq 0 ]
  [ "$output" -eq 404 ]
}
