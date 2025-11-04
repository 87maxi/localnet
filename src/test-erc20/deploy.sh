#!/bin/bash

# Set the JSON-RPC endpoint URL (e.g. localnet:8545)
JSON_RPC_URL="http://localhost:8545"

# Compile the contract
forge build

echo "Compilación finalizada"

# Deploy the contract
forge create ERC20Token --legacy --lib-paths ./src/ERC20Token.sol  --rpc-url $JSON_RPC_URL --private-key 0x$(cat /dev/urandom | tr -dc '0-9a-f' | fold -w 64 | head -n 1)

echo "Despliegue finalizado"
