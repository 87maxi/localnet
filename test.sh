#!/bin/bash

curl -X POST http://localhost:8551/ \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer 4ed27c91b0a8712145f805dbe27fc227d6a008dc3cc5b5868690587e8041fa95" \
  --data '{
    "jsonrpc": "2.0",
    "method": "engine_exchangeTransitionConfigurationV1",
    "params": [{
      "terminalTotalDifficulty": "0x0"
    }],
    "id": 1
  }'
