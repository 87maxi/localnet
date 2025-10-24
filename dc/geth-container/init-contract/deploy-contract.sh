#!/bin/bash
set -e

INIT_PATH=/init-contract

DEPOSIT_CONTRACT="$INIT_PATH/DepositContract.sol"


echo "📦 Compilando contrato..."

# Verificar archivos
echo "📁 Archivos en el directorio:"
ls -la $INIT_PATH

BUILD="$INIT_PATH/build/"

# Verificar que el contrato existe
if [ ! -f $DEPOSIT_CONTRACT ]; then
    echo "❌ Error: DepositContract.sol no encontrado en $(pwd)"
    echo "📂 Contenido del directorio:"
    ls -la 
    exit 1
fi


# Compilar contrato
solc --bin --abi  $DEPOSIT_CONTRACT  -o  $BUILD  --overwrite

# Extraer bytecode
BYTECODE=$(cat "$BUILD/DepositContract.bin")
echo "✅ Bytecode extraído del output, length: ${#BYTECODE}"

# Usar la cuenta pre-fundada del genesis (NO intentar desbloquear)
ACCOUNT=$1;

echo "🔑 Iniciando despliegue con cuenta pre-fundada: $ACCOUNT"

# Deploy usando eth_sendTransaction (sin unlock)
DEPLOY_RESULT=$(curl -s -X POST \
  -H "Content-Type: application/json" \
  --data "{
    \"jsonrpc\":\"2.0\",
    \"method\":\"eth_sendTransaction\",
    \"params\":[{
      \"from\": \"$ACCOUNT\",
      \"data\": \"0x$BYTECODE\",
      \"gas\": \"0x1000000\"
    }],
    \"id\":1
  }" http://localhost:8545)

echo "📦 Resultado del despliegue: $DEPLOY_RESULT"

# Verificar si hubo error
if echo "$DEPLOY_RESULT" | grep -q "error"; then
    echo "❌ Error en despliegue: $DEPLOY_RESULT"
    exit 1
fi

# Extraer tx hash
TX_HASH=$(echo "$DEPLOY_RESULT" | python3 -c "
import sys, json
try:
    result = json.load(sys.stdin)
    print(result['result'])
except:
    print('')
")

if [ -z "$TX_HASH" ] || [ "$TX_HASH" == "null" ]; then
    echo "❌ No se pudo obtener transaction hash"
    echo "Raw result: $DEPLOY_RESULT"
    exit 1
fi

echo "📄 Transacción enviada: $TX_HASH"

# Esperar a que se mine (más tiempo)
echo "⏳ Esperando confirmación (15 segundos)..."
sleep 15

# Obtener receipt
RECEIPT_JSON=$(curl -s -X POST \
  -H "Content-Type: application/json" \
  --data "{
    \"jsonrpc\":\"2.0\",
    \"method\":\"eth_getTransactionReceipt\", 
    \"params\":[\"$TX_HASH\"],
    \"id\":1
  }" http://localhost:8545)

echo "📋 Receipt: $RECEIPT_JSON"

CONTRACT_ADDRESS=$(echo "$RECEIPT_JSON" | python3 -c "
import sys, json
try:
    result = json.load(sys.stdin)
    receipt = result['result']
    if receipt and 'contractAddress' in receipt:
        print(receipt['contractAddress'])
    else:
        print('')
except Exception as e:
    print('')
")

if [ -n "$CONTRACT_ADDRESS" ] && [ "$CONTRACT_ADDRESS" != "null" ]; then
    echo "✅ Contrato desplegado en: $CONTRACT_ADDRESS"
    mkdir -p /output
    echo "$CONTRACT_ADDRESS" > /output/contract-address.txt
    echo "💾 Dirección guardada en /output/contract-address.txt"
else
    echo "⚠️ No se pudo obtener la dirección del contrato"
    echo "💡 Puede que la transacción aún no se haya minado"
    # No salir con error para permitir continuar
fi