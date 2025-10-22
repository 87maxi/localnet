#!/bin/bash
set -euo pipefail

# ----------------------------
# Configuración inicial
# ----------------------------

ACCOUNTS=""


# ----------------------------
# Helper para extraer addresses de keystore
# ----------------------------
extract_address_from_file() {
  local file="$1"
  basename "$file" | awk -F'--' '{print $NF}' | tr '[:upper:]' '[:lower:]'
}

# ----------------------------
# Crear cuentas nuevas
# ----------------------------
create_accounts() {
  local n="$1"
  local PASSFILE="$2" 
  echo "🔐 Creando $n cuentas en $KEYSTORE ..."
  for i in $(seq 1 "$n"); do
    out=$(geth account new --datadir "$DATADIR" --password "$PASSFILE" 2>&1)
    addr=$(echo "$out" | grep -oE "0x[a-fA-F0-9]{40}" | head -n1 | tr '[:upper:]' '[:lower:]')
    echo "  ✅ $addr"
  done
}


generate_genesis() {
  local GENESIS_FILE="$1"
  local ACCOUNTS=()
  local ALLOC_JSON="{}"

  # Recopilar direcciones del keystore
  for f in "$KEYSTORE"/UTC*; do
    [ -f "$f" ] || continue
    addr=$(extract_address_from_file "$f")
    ACCOUNTS+=("$addr")
  done

  if [ ${#ACCOUNTS[@]} -eq 0 ]; then
    echo "❌ No hay cuentas en el keystore."
    exit 1
  fi

  # Construir alloc usando jq
  for addr in "${ACCOUNTS[@]}"; do
    ALLOC_JSON=$(echo "$ALLOC_JSON" | jq --arg a "$addr" '. + {($a): {"balance": "0x1337000000000000000000"}}')
  done
# Solo la primera cuenta será el signer
SIGNER_ADDR=$(echo "${ACCOUNTS[0]}" | sed 's/^0x//')

# Construir extraData para Clique con un solo signer
EXTRA_ZEROS_32=$(printf '0%.0s' {1..64})   # 32 bytes = 64 caracteres hex
EXTRA_ZEROS_65=$(printf '0%.0s' {1..130})  # 65 bytes = 130 caracteres hex
#EXTRA_DATA="0x${EXTRA_ZEROS_32}${SIGNER_ADDR}${EXTRA_ZEROS_65}"
  # ✅ extraData para PoS: vacío o 32 bytes de ceros
  EXTRA_DATA="0x0000000000000000000000000000000000000000000000000000000000000000"

chainId=1337
difficulty=1  # decimal equivalente de 0x4000
ttd=0 #288230376151711744  # decimal equivalente de 0x4000000000000000
gasLimit=29320384  # decimal equivalente de 0x1c9c380


  # Generar genesis.json válido
  jq -n \
    --arg chainId "1337"  \
    --argjson difficulty "$difficulty" \
    --argjson ttd "$ttd" \
    --argjson gasLimit "$gasLimit" \
    --arg extraData "$EXTRA_DATA" \
    --argjson alloc "$ALLOC_JSON" \
    '{
      config: {
        "chainId": ($chainId | tonumber),
        "homesteadBlock": 0,
        "eip150Block": 0,
        "eip155Block": 0,
        "eip158Block": 0,
        "byzantiumBlock": 0,
        "constantinopleBlock": 0,
        "petersburgBlock": 0,
        "istanbulBlock": 0,
        "berlinBlock": 0,
        "londonBlock": 0,
        "shanghaiTime": 0,
        "terminalTotalDifficulty": $ttd,
        "mergeForkBlock": 0,        
        "terminalTotalDifficultyPassed": true
      },
      nonce: "0x0",
      timestamp: "0x0",
      extraData: $extraData,
      gasLimit: "0x2FEFD8",
      difficulty: "0x0",
      mixHash: "0x0000000000000000000000000000000000000000000000000000000000000000",
      coinbase: "0x0000000000000000000000000000000000000000",
      baseFeePerGas: "0x7",
      alloc: $alloc
    }' > "$GENESIS_FILE"

  echo "✅ Genesis.json generado en $GENESIS_FILE"
  cat $GENESIS_FILE;
}

# ----------------------------
# Elegir etherbase
# ----------------------------

choose_etherbase() {
  ETHERBASE="0x${ACCOUNTS[0]}"
  echo "⛏️ Minando con etherbase: $ETHERBASE"
}



