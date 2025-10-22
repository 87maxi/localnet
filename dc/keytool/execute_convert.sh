#!/bin/bash
set -euo pipefail

echo "──────────────────────────────────────────────"
echo " 🦉  Inicializando Prysm Localnet (v5.0.4 oficial)"
echo "──────────────────────────────────────────────"

DATA_DIR="/data/keytool"
CONFIG_FILE="/app/config.yaml"
PRYSMCTL_BIN="/usr/local/bin/prysmctl"
VALIDATOR_BIN="/usr/local/bin/validator"

WALLET_DIR="$DATA_DIR/wallet"
WALLET_PASS_FILE="/app/geth/wallet-password.txt"
GENESIS_SSZ="$DATA_DIR/genesis.ssz"
GENESIS_JSON="$DATA_DIR/genesis.json"
BLS_KEYS_DIR="$DATA_DIR/validator_keys"

mkdir -p "$DATA_DIR" "$BLS_KEYS_DIR" "$(dirname "$WALLET_PASS_FILE")"

# Copiar config
cp "$CONFIG_FILE" "$DATA_DIR/config.yaml";

cp -r /app/validator_keys/*  $BLS_KEYS_DIR;

cat "$DATA_DIR/config.yaml"

echo "estas en generate_keystores"
convert_keys;
# Generar TODO con prysmctl v5.0.4
$PRYSMCTL_BIN testnet generate-genesis \
  --num-validators=8 \
  --chain-config-file="$DATA_DIR/config.yaml" \
  --output-ssz=$GENESIS_SSZ \
  --output-json=$GENESIS_JSON

echo "✅ Génesis y keystores generados"

# Crear wallet e importar
#echo "password123" > "$WALLET_PASS_FILE"
chmod 600 "$WALLET_PASS_FILE"

$VALIDATOR_BIN wallet create \
  --wallet-dir "$WALLET_DIR" \
  --keymanager-kind imported \
  --wallet-password-file "$WALLET_PASS_FILE" \
  --accept-terms-of-use

$VALIDATOR_BIN accounts import \
  --wallet-dir "$WALLET_DIR" \
  --keys-dir "$BLS_KEYS_DIR" \
  --wallet-password-file "$WALLET_PASS_FILE" \
  --account-password-file "$WALLET_PASS_FILE" \
  --accept-terms-of-use || true

echo "✅ Listo"