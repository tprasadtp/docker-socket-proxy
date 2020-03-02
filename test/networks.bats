#!/usr/bin/env bats

@test "GET /networks NETWORKS [200]" {
  run curl -s -o /dev/null -w "%{http_code}" "http://${DOCKER_ENDPOINT}/networks"
  [ "$status" -eq 0 ]
  [ "$output" -eq 200 ]
}

@test "GET /networks INSPECT [200]" {
  run curl -s -o /dev/null -w "%{http_code}" "http://${DOCKER_ENDPOINT}/networks/none"
  [ "$status" -eq 0 ]
  [ "$output" -eq 200 ]
}

@test "GET /networks INSPECT [404]" {
  run curl -s -o /dev/null -w "%{http_code}" "http://${DOCKER_ENDPOINT}/networks/no-such-network"
  [ "$status" -eq 0 ]
  [ "$output" -eq 404 ]
}


@test "POST /networks CREATE [201|409]" {
  run curl -s \
  -w "%{http_code}" \
  -o /dev/null \
  -H "Content-Type: application/json" \
  -X POST \
  -d '{"Name": "delete-this-network", "Internal": true, "CheckDuplicate" : true}' \
  "http://${DOCKER_ENDPOINT}/networks/create"
  [ "$status" -eq 0 ]
  [ "$output" -eq 201 ] || [ "$output" -eq 409 ]
}

@test "POST /networks CREATE (default-networks) [403]" {
  run curl -s \
  -w "%{http_code}" \
  -o /dev/null \
  -H "Content-Type: application/json" \
  -X POST \
  -d '{"Name": "none", "Internal": true, "CheckDuplicate" : true}' \
  "http://${DOCKER_ENDPOINT}/networks/create"
  [ "$status" -eq 0 ]
  [ "$output" -eq 403 ]
}

@test "POST /networks CONNECT [200]" {
  run curl -s \
  -w "%{http_code}" \
  -o /dev/null \
  -H "Content-Type: application/json" \
  -X POST \
  -d '{"Container": "dockerproxy"}' \
  "http://${DOCKER_ENDPOINT}/networks/delete-this-network/connect"
  [ "$status" -eq 0 ]
  [ "$output" -eq 200 ]
}

@test "POST /networks DISCONNECT [200]" {
  run curl -s \
  -w "%{http_code}" \
  -o /dev/null \
  -H "Content-Type: application/json" \
  -X POST \
  -d '{"Container": "dockerproxy"}' \
  "http://${DOCKER_ENDPOINT}/networks/delete-this-network/disconnect"
  [ "$status" -eq 0 ]
  [ "$output" -eq 200 ]
}

@test "DELETE /networks RM [204]" {
  run curl -s \
  -w "%{http_code}" \
  -o /dev/null \
  -X DELETE \
  "http://${DOCKER_ENDPOINT}/networks/delete-this-network"
  [ "$status" -eq 0 ]
  [ "$output" -eq 204 ]
}

@test "DELETE /networks RM [403]" {
  run curl -s \
  -w "%{http_code}" \
  -o /dev/null \
  -X DELETE \
  "http://${DOCKER_ENDPOINT}/networks/bridge"
  [ "$status" -eq 0 ]
  [ "$output" -eq 403 ]
}
