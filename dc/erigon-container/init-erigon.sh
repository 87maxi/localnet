#!/bin/bash
mkdir -p /data/erigon/chaindata /data/erigon/keystore /data/erigon/logs
chown -R erigon:erigon /data/erigon

DATADIR="/data/erigon"
KEYSTORE="$DATADIR/keystore"
GENESIS="$DATADIR/genesis.json"
PASSFILE="$DATADIR/password.txt"

mkdir -p "$KEYSTORE"

echo "Initializing Erigon with genesis..."
erigon init --datadir="$DATADIR" "$GENESIS"

echo "Starting Erigon..."
exec erigon \
  --datadir="$DATADIR" \
  --http \
  --http.addr=0.0.0.0 \
  --http.port=8545 \
  --http.api=eth,net,web3,erigon \
  --chain="$GENESIS" \
  --networkid=1337 \
  --mine \
  --miner.etherbase=0x0bde814f7a4e6178c14507b5b85b4be0332181a1 \
  --miner.gaslimit=5000000 \
  --nodiscover \
  --verbosity=3






