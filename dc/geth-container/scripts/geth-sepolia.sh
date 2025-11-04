#!/bin/bash
set -euo pipefail

# ----------------------------
# Configuración para Sepolia
# ----------------------------

# Configuración de Sepolia
SEPOLIA_CHAIN_ID=11155111
SEPOLIA_GAS_LIMIT="0x1c9c380"

# ----------------------------
# Función generate_genesis modificada para Sepolia
# ----------------------------

generate_genesis() {
    # Para Sepolia no necesitamos alloc de cuentas pre-fundadas
    # ya que usaremos la genesis real de Sepolia
    
    echo "📄 Usando configuración de genesis para Sepolia..."

    # Genesis básico para Sepolia (Geth lo completará con --sepolia)
    cat > $GENESIS << 'EOF'
{
  "config": {
    "chainId": 11155111,
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
  "nonce": "0x0",
  "timestamp": "0x0",
  "extraData": "0x0000000000000000000000000000000000000000000000000000000000000000",
  "gasLimit": "0x1c9c380",
  "difficulty": "0x0",
  "mixHash": "0x0000000000000000000000000000000000000000000000000000000000000000",
  "coinbase": "0x0000000000000000000000000000000000000000",
  "alloc": {}
}
EOF

    echo "✅ Genesis para Sepolia generado: $GENESIS"
}





echo "=== INICIANDO GETH PARA SEPOLIA TESTNET ==="

# Crear JWT secret si no existe
if [ ! -f $JWT_SECRET ]; then
    echo "Creando JWT secret..."
    openssl rand -hex 32 | tr -d "\n" > /jwt-secret/jwt.hex
fi

# Iniciar Geth para Sepolia (NO usa genesis personalizado)
exec geth \
    --sepolia \
    --datadir /geth-data \
    --http \
    --http.addr 0.0.0.0 \
    --http.port 8545 \
    --http.api eth,net,web3,engine,admin,debug,txpool,personal \
    --http.corsdomain "*" \
    --ws \
    --ws.addr 0.0.0.0 \
    --ws.port 8546 \
    --ws.api eth,net,web3,engine,admin,debug,txpool \
    --authrpc.addr 0.0.0.0 \
    --authrpc.port 8551 \
    --authrpc.jwtsecret /jwt-secret/jwt.hex \
    --syncmode snap \
    --txlookuplimit 0 \
    --cache 2048 \
    --maxpeers 50 \
    --verbosity 3