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
    out=$(geth account new --datadir "$DATADIR_TMP" --password "$PASSFILE" 2>&1)
    addr=$(echo "$out" | grep -oE "0x[a-fA-F0-9]{40}" | head -n1 | tr '[:upper:]' '[:lower:]')
    echo "  ✅ $addr"
  done
}


generate_genesis() {
  local ACCOUNTS=()
  local ALLOC_JSON="{}"

  # Recopilar direcciones del keystore
  #for f in "$KEYSTORE"/UTC*; do
  #  [ -f "$f" ] || continue
  #  addr=$(extract_address_from_file "$f")
  #  ACCOUNTS+=("$addr")
  #done

  #if [ ${#ACCOUNTS[@]} -eq 0 ]; then
  #  echo "❌ No hay cuentas en el keystore."
  #  exit 1
  #fi

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
difficulty="0x4000"  # decimal equivalente de 0x4000
ttd=0 #288230376151711744  # decimal equivalente de 0x4000000000000000
gasLimit=29320384  # decimal equivalente de 0x1c9c380


  # Generar genesis.json válido
# =============================================================================
# 1. GENERAR GENESIS PARA POW AUTÓNOMO (SIN BEACON)
# =============================================================================
echo "📄 Generando genesis.json para PoW autónomo..."
jq -n \
    --arg chainId "1337" \
    --arg difficulty "0x2000" \
    --arg gasLimit "0x1c9c380" \
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
        "londonBlock": 0
      },
      nonce: "0x0",
      timestamp: "0x0",
      extraData: $extraData,
      gasLimit: $gasLimit,
      difficulty: $difficulty,
      mixHash: "0x0000000000000000000000000000000000000000000000000000000000000000",
      coinbase: "0x0000000000000000000000000000000000000000",
      alloc: $alloc
    }' > $GENESIS_POW

echo "✅ Genesis PoW autónomo generado: $GENESIS_POW"

# =============================================================================
# 2. GENERAR GENESIS PARA POS (CON BEACON CHAIN)
# =============================================================================
echo "📄 Generando genesis.json para PoS..."
jq -n \
    --arg chainId "1337" \
    --arg difficulty "0x0" \
    --arg gasLimit "0x1c9c380" \
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
        "terminalTotalDifficulty": 0,
        "mergeForkBlock": 0,
        "terminalTotalDifficultyPassed": true
      },
      nonce: "0x0",
      timestamp: "0x0",
      extraData: $extraData,
      gasLimit: $gasLimit,
      difficulty: $difficulty,
      mixHash: "0x0000000000000000000000000000000000000000000000000000000000000000",
      coinbase: "0x0000000000000000000000000000000000000000",
      baseFeePerGas: "0x7",
      alloc: $alloc
    }' > $GENESIS

echo "✅ Genesis PoS generado: $GENESIS"

# Mostrar diferencias
echo ""
echo "🔍 COMPARACIÓN DE GENESIS:"
echo "PoW Autónomo:"
echo "  - Dificultad: 0x2000 (puede minar)"
echo "  - Sin configuración merge"
echo "  - Pre-merge completo"
echo ""
echo "PoS Beacon:"
echo "  - Dificultad: 0x0 (no mina)"
echo "  - Con configuración merge"
echo "  - TerminalTotalDifficulty: 0"
}

# ----------------------------
# Elegir etherbase
# ----------------------------

choose_etherbase() {
  ETHERBASE="0x${ACCOUNTS[0]}"
  echo "⛏️ Minando con etherbase: $ETHERBASE"
}



generate_accounts()

{

      # Verificar si hay cuentas existentes
    ACCOUNTS_CREATED=0
    if [ -d "$KEYSTORE" ]; then
        ACCOUNTS_CREATED=$(ls "$KEYSTORE" | wc -l)
    fi

    echo "📊 Cuentas existentes: $ACCOUNTS_CREATED, Esperadas: $NUM_ACCOUNT"

    # Lógica para manejar cuentas
    if [ "$ACCOUNTS_CREATED" -eq 0 ]; then
        echo "🔐 Iniciando keystore desde cero"
        create_accounts "$NUM_ACCOUNT" "$PASSWORD_FILE"

        
    elif [ "$ACCOUNTS_CREATED" -lt "$NUM_ACCOUNT" ]; then
        echo "🔐 Añadiendo cuentas al keystore"
        create_accounts $(($NUM_ACCOUNT - $ACCOUNTS_CREATED)) "$PASSWORD_FILE"

        
    elif [ "$ACCOUNTS_CREATED" -gt "$NUM_ACCOUNT" ]; then
        echo "🔐 Reseteando keystore (demasiadas cuentas)"
        rm -rf "$KEYSTORE"
        create_accounts "$NUM_ACCOUNT" "$PASSWORD_FILE"

    else
        echo "✅ Número correcto de cuentas existentes"
    fi

}


get_first_account_from_keystore()
{

      # Obtener dirección SIN USAR GETH ACCOUNT LIST - Método directo del keystore
    echo "🔍 Obteniendo dirección de la primera cuenta..."

    # Método 1: Buscar directamente en el keystore (más confiable)
    if [ -d "$KEYSTORE" ] && [ "$(ls -A "$KEYSTORE")" ]; then
        # Obtener el primer archivo del keystore y extraer la dirección
        FIRST_KEYFILE=$(ls "$KEYSTORE" | head -1)
        echo "📄 Primer archivo de clave: $FIRST_KEYFILE"
        
        # Extraer dirección del nombre del archivo (formato: UTC--2023-10-23T17-44-00.000000000Z--a1b2c3...)
        ADDRESSES=$(echo "$FIRST_KEYFILE" | grep -o '[a-fA-F0-9]\{40\}$')
        
        # Añadir prefijo 0x si no lo tiene
        if [[ ${#ADDRESSES} -eq 40 ]]; then
            ADDRESSES="0x$ADDRESSES"
        fi
        
        echo "✅ Dirección extraída del keystore: $ADDRESSES"
    else
        echo "❌ ERROR: No hay archivos en el keystore"
        exit 1
    fi

    # Verificar que es una dirección válida
    if [[ -z "$ADDRESSES" || ${#ADDRESSES} -ne 42 || ! "$ADDRESSES" =~ ^0x[a-fA-F0-9]{40}$ ]]; then
        echo "❌ ERROR: Dirección de cuenta inválida: '$ADDRESSES'"
        echo "📋 Contenido del keystore:"
        ls -la "$KEYSTORE/"
        exit 1
    fi

    echo "✅ Dirección válida obtenida: $ADDRESSES"

}




