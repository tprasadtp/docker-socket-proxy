#!/usr/bin/env bats

export exec_id="$(curl -s -H "Content-Type: application/json" -X POST -d '{"Cmd": [ "id" ]}' "http://${DOCKER_ENDPOINT}/containers/dockerproxy/exec" | jq .Id)"

@test "POST /exec DISABLED [SHOULD RETURN 403]" {
  run curl -s \
    -H "Content-Type: application/json" \
    -X POST \
    -w "%{http_code}" \
    -o /dev/null \
    -d '{"Detach": true, "Tty": false}' \
    "http://${DOCKER_ENDPOINT}/exec/${exec_id}/start"
  [ "$status" -eq 0 ]
  [ "$output" -eq 403 ]

}

@test "POST /exec DISABLED [SHOULD RETURN 403]" {
  run curl -s \
    -H "Content-Type: application/json" \
    -X POST \
    -w "%{http_code}" \
    -o /dev/null \
    -d '{"Detach": true, "Tty": false}' \
    "http://${DOCKER_ENDPOINT}/exec/${exec_id}/json"
  [ "$status" -eq 0 ]
  [ "$output" -eq 403 ]

}
