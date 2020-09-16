#!/usr/bin/env bats

@test "GET /networks NETWORKS (Check with existing  network)" {
  run curl -s -o /dev/null -w "%{http_code}" "http://${DOCKER_PROXY_ENDPOINT}/networks"
  [ "$status" -eq 0 ]
  [ "$output" -eq 200 ]
}

@test "GET /networks INSPECT (Check with existing  network)" {
  run curl -s -o /dev/null -w "%{http_code}" "http://${DOCKER_PROXY_ENDPOINT}/networks/none"
  [ "$status" -eq 0 ]
  [ "$output" -eq 200 ]
}

@test "GET /networks INSPECT (Check with non-existing  network)" {
  run curl -s -o /dev/null -w "%{http_code}" "http://${DOCKER_PROXY_ENDPOINT}/networks/no-such-network"
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
  "http://${DOCKER_PROXY_ENDPOINT}/networks/create"
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
  "http://${DOCKER_PROXY_ENDPOINT}/networks/create"
  [ "$status" -eq 0 ]
  [ "$output" -eq 403 ]
}

@test "POST /networks CONNECT (Check with existing  network)" {
  run curl -s \
  -w "%{http_code}" \
  -o /dev/null \
  -H "Content-Type: application/json" \
  -X POST \
  -d '{"Container": "dockerproxy"}' \
  "http://${DOCKER_PROXY_ENDPOINT}/networks/delete-this-network/connect"
  [ "$status" -eq 0 ]
  [ "$output" -eq 200 ]
}

@test "POST /networks DISCONNECT (Check with existing  network)" {
  run curl -s \
  -w "%{http_code}" \
  -o /dev/null \
  -H "Content-Type: application/json" \
  -X POST \
  -d '{"Container": "dockerproxy"}' \
  "http://${DOCKER_PROXY_ENDPOINT}/networks/delete-this-network/disconnect"
  [ "$status" -eq 0 ]
  [ "$output" -eq 200 ]
}

@test "DELETE /networks RM [204]" {
  run curl -s \
  -w "%{http_code}" \
  -o /dev/null \
  -X DELETE \
  "http://${DOCKER_PROXY_ENDPOINT}/networks/delete-this-network"
  [ "$status" -eq 0 ]
  [ "$output" -eq 204 ]
}

@test "DELETE /networks RM [403]" {
  run curl -s \
  -w "%{http_code}" \
  -o /dev/null \
  -X DELETE \
  "http://${DOCKER_PROXY_ENDPOINT}/networks/bridge"
  [ "$status" -eq 0 ]
  [ "$output" -eq 403 ]
}
