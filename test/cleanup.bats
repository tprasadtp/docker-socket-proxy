#!/usr/bin/env bats

@test "Kill Docker Image" {
  	run docker stop dockerproxy
    [ "$status" -eq 0 ]
}