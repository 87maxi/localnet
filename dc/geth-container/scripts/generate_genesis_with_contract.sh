#!/bin/bash
set -e

echo "🔧 Generando genesis con DepositContract y cuenta dedicada..."

# =============================================================================
# CONFIGURACIÓN
# =============================================================================

CONTRACT_DIR="/app/init-contract"

GENESIS_TMP="$DATADIR_TMP/genesis.json"

CONTRACT_ADDRESS="0x0000000000000000000000000000000000000001"  # ✅ Dirección específica para contrato

# =============================================================================
# 1. GENERAR CUENTA DEDICADA PARA EL CONTRATO
# =============================================================================
echo "👤 Generando cuenta dedicada para el DepositContract..."

# Crear directorio temporal para generar cuenta
geth --datadir "$DATADIR_TMP" account new --password $PASSWORD_FILE

# Obtener la dirección generada
CONTRACT_ACCOUNT=$(geth --datadir "$DATADIR_TMP" account list | head -1 | awk -F'[{}]' '{print "0x" $2}')
echo "✅ Cuenta dedicada generada: $CONTRACT_ACCOUNT"

# Guardar la cuenta para uso futuro
echo "$CONTRACT_ACCOUNT" > /output/contract-account.txt

# Copiar keystore al directorio principal (opcional, si necesitas la clave después)
if [ -d "$DATADIR_TMP/keystore" ]; then
    mkdir -p "$DATADIR/keystore"
    cp "$DATADIR_TMP/keystore"/* "$DATADIR/keystore/" 2>/dev/null || true
fi



# =============================================================================
# 2. COMPILAR DEPOSIT CONTRACT
# =============================================================================
echo "📦 Compilando DepositContract..."
cd $CONTRACT_DIR;

if [ ! -f "DepositContract.sol" ]; then
    echo "❌ DepositContract.sol no encontrado"
    exit 1
fi

solc --bin --abi --optimize "$CONTRACT_DIR/DepositContract.sol" -o "$CONTRACT_DIR/build" --overwrite

if [ ! -f "$CONTRACT_DIR/build/DepositContract.bin" ]; then
    echo "❌ Error en compilación"
    exit 1
fi

BYTECODE=$(cat "$CONTRACT_DIR/build/DepositContract.bin")
echo "✅ Contract compiled - Bytecode: ${#BYTECODE} chars"

# =============================================================================
# 3. PREPARAR ALLOC CON CONTRATO Y CUENTA DEDICADA
# =============================================================================
echo "💰 Configurando alloc..."

# Crear alloc con cuenta dedicada (fondos para operar) y contrato
ALLOC_JSON=$(cat << EOF
{
  "$CONTRACT_ACCOUNT": {
    "balance": "1000000000000000000000000"
  },
  "$CONTRACT_ADDRESS": {
    "balance": "0",
    "code": "0x$BYTECODE"
  }
}
EOF
)

# =============================================================================
# 4. GENERAR GENESIS.JSON
# =============================================================================
echo "📄 Generando genesis.json..."
#GENESIS_FILE="$DATADIR/genesis.json"

# Parámetros del genesis
chainId="1337"
difficulty="0x0"
ttd="0"
gasLimit="29320384"
EXTRA_DATA="0x0000000000000000000000000000000000000000000000000000000000000000"

jq -n \
  --arg chainId "$chainId" \
  --arg difficulty "$difficulty" \
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
      "terminalTotalDifficulty": ($ttd | tonumber),
      "mergeForkBlock": 0,
      "terminalTotalDifficultyPassed": true
    },
    nonce: "0x0",
    timestamp: "0x0",
    extraData: $extraData,
    gasLimit: "0x1c9c380",
    difficulty: $difficulty,
    mixHash: "0x0000000000000000000000000000000000000000000000000000000000000000",
    coinbase: "0x0000000000000000000000000000000000000000",
    alloc: $alloc
  }' > $GENESIS_TMP

echo "✅ Genesis generado: $GENESIS_TMP"

# =============================================================================
# 5. GUARDAR METADATA COMPLETA
# =============================================================================
echo "💾 Guardando metadata..."
mkdir -p /output
echo "$CONTRACT_ADDRESS" > /output/contract-address.txt
echo "$CONTRACT_ACCOUNT" > /output/contract-owner.txt
cp -r /app/init-contract/build /output/

# Crear archivo de configuración
cat > /output/deployment-info.json << EOF
{
  "depositContract": {
    "address": "$CONTRACT_ADDRESS",
    "bytecodeLength": ${#BYTECODE}
  },
  "contractOwner": {
    "address": "$CONTRACT_ACCOUNT",
    "balance": "1000000000000000000000000"
  },
  "network": {
    "chainId": 1337,
    "genesisFile": "$GENESIS"
  }
}
EOF

# =============================================================================
# 6. VERIFICACIÓN
# =============================================================================
echo "🔍 Verificando..."
echo "📋 Resumen del despliegue:"
echo "   DepositContract: $CONTRACT_ADDRESS"
echo "   Cuenta dedicada: $CONTRACT_ACCOUNT" 
echo "   Balance cuenta: 1,000,000 ETH"
echo "   Bytecode: ${#BYTECODE} bytes"

cp -r $DATADIR_TMP /output;

cat $GENESIS_TMP;

# Verificaciones
if grep -q "$CONTRACT_ADDRESS" "$GENESIS_TMP"; then
    echo "✅ Contrato incluido en genesis"
else
    echo "❌ Error: Contrato no encontrado en genesis"
    exit 1
fi

if grep -q "$CONTRACT_ACCOUNT" "$GENESIS_TMP"; then
    echo "✅ Cuenta dedicada incluida en genesis"
else
    echo "❌ Error: Cuenta no encontrada en genesis"
    exit 1
fi


echo "🚀 GENESIS CON CONTRATO Y CUENTA DEDICADA GENERADO EXITOSAMENTE"