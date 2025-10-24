#!/bin/bash
set -euo pipefail

echo "──────────────────────────────────────────────"
echo " 🦉  Inicializando Prysm Localnet (v5.0.4 oficial)"
echo "──────────────────────────────────────────────"

echo "──────────────────────────────────────────────"
echo " 🦉  Keytool - Generación Coordinada"
echo "──────────────────────────────────────────────"

DATA_DIR="/geth-data"
CONFIG_FILE="/app/config.yaml"
PRYSMCTL_BIN="/usr/local/bin/prysmctl"
VALIDATOR_BIN="/usr/local/bin/validator"
DUMPS="/app/output"


GENESIS_SSZ="$DATA_DIR/keytool/genesis.ssz"
GENESIS_JSON="$DATA_DIR/keytool/genesis.json"
BLS_KEYS_DIR="$DATA_DIR/keytool/validator_keys"
WALLET_PASS_FILE="$DATA_DIR/wallet-password.txt"
WALLET_DIR="$DATA_DIR/wallet"

# === TIMESTAMP COORDINADO ===
# Usar timestamp 2 minutos en el futuro para dar tiempo a Geth de iniciar
GENESIS_TIMESTAMP=$(date -d "+2 minutes" +%s)
echo "📅 Timestamp de genesis coordinado: $GENESIS_TIMESTAMP ($(date -d @$GENESIS_TIMESTAMP))"

# Actualizar config con timestamp coordinado
cp "$CONFIG_FILE" "$DATA_DIR/config.yaml"
# Tu comando corregido - así es como funciona yq:
sed -i "s/MIN_GENESIS_TIME:.*/MIN_GENESIS_TIME: $GENESIS_TIMESTAMP/" -i "$DATA_DIR/config.yaml"

#  =======================================================================================


if [ ! -d $BLS_KEYS_DIR ]; then
  mkdir -p $BLS_KEYS_DIR;
fi




# Copiar keys y generar genesis
cp -r /app/validator_keys/validator_keys/* "$BLS_KEYS_DIR/"

NUM_VALIDATORS=$(ls "$BLS_KEYS_DIR"/keystore-*.json | wc -l)
echo "📊 Validadores detectados: $NUM_VALIDATORS"

$PRYSMCTL_BIN testnet generate-genesis \
  --num-validators="$NUM_VALIDATORS" \
  --chain-config-file="$DATA_DIR/config.yaml" \
  --genesis-time="$GENESIS_TIMESTAMP" \
  --output-ssz="$GENESIS_SSZ" \
  --output-json="$GENESIS_JSON"

echo "✅ Genesis generado para timestamp: $GENESIS_TIMESTAMP"

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

# copia para debug 

cp -r $DATA_DIR $DUMPS;


echo "✅ Listo"