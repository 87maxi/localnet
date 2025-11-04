#!/bin/bash
# Healthcheck básico - solo verifica que Geth responda
curl -s --max-time 3 -f -X POST \
  -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"net_version","params":[],"id":1}' \
  http://localhost:8545 > /dev/null