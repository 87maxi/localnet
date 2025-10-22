#!/bin/bash
set -e

GENESIS_FILE="/genesis/genesis.ssz"
CONFIG_FILE="/config.yaml"

if [ ! -f "$GENESIS_FILE" ]; then
  /app/cmd/beacon-chain/beacon-chain \
    --interop \
    --interop-num-validators=8 \
    --chain-config-file="$CONFIG_FILE" \
    --genesis-state-output="$GENESIS_FILE"
  echo "✅ genesis.ssz generado"
else
  echo "⚠️ genesis.ssz ya existe"
fi