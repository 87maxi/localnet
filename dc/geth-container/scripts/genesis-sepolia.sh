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





