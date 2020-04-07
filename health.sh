#!/usr/bin/env bash

if test -f "/tmp/starting_nexus"; then
  # Starting file is still there so not healthy
  exit 1
fi

curl -s -f http://localhost:8081/service/rest/v1/status/writable
exit $?
