#!/bin/bash

# El healthcheck más simple posible
curl -s -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"net_listening","params":[],"id":1}' \
  http://localhost:8545 > /dev/null

if [ $? -eq 0 ]; then
    exit 0  # Healthy
else
    exit 1  # Unhealthy
fi