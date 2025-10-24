#!/bin/bash
set -euo pipefail

echo "🏗️  Compilando y desplegando DepositContract..."

# =============================================================================
# 1. INSTALAR SOLC COMPATIBLE
# =============================================================================
echo "🔧 Instalando solc compatible con Alpine..."

# Verificar si ya está instalado
if ! command -v solc &> /dev/null; then
    echo "📦 Instalando solc desde repositorio Alpine..."
    apk add --no-cache solidity
fi

# Verificar instalación
SOLC_COMPILER=$(command -v solc)
echo "✅ Compilador: $SOLC_COMPILER"
solc --version

# =============================================================================
# 2. CAMBIAR VERSIÓN DEL CONTRATO SI ES NECESARIO
# =============================================================================
cd /init-contract

echo "📝 Ajustando versión del contrato para compatibilidad..."
CONTRACT_VERSION=$(solc --version | grep -o "0.8.[0-9]*" | head -1)
echo "🔍 Versión de solc instalada: $CONTRACT_VERSION"

# Hacer backup del contrato original
cp DepositContract.sol DepositContract.sol.backup

# Cambiar pragma a versión compatible
sed -i "s/^0.8.24/$CONTRACT_VERSION/" DepositContract.sol
echo "🔁 Cambiado pragma a $CONTRACT_VERSION"

# =============================================================================
# 3. COMPILAR
# =============================================================================
echo "📦 Compilando contrato..."

if ! solc --bin --abi DepositContract.sol --overwrite --optimize; then
    echo "❌ Error compilando, probando sin optimizaciones..."
    if ! solc --bin --abi DepositContract.sol --overwrite; then
        echo "❌ Error crítico en compilación"
        # Restaurar contrato original
        cp DepositContract.sol.backup DepositContract.sol
        exit 1
    fi
fi

# Restaurar contrato original
cp DepositContract.sol.backup DepositContract.sol

BYTECODE=$(cat DepositContract.bin)
echo "✅ Contrato compilado, bytecode length: ${#BYTECODE}"

# =============================================================================
# 4. DESPLEGAR
# =============================================================================
echo "🚀 Desplegando contrato..."

PASSWORD=$(cat "$PASSWORD_FILE")

geth --exec "
console.log('🔧 Iniciando despliegue...');

// Verificar conexión
console.log('🌐 Block number:', eth.blockNumber);

// Desbloquear cuenta
if (!personal.unlockAccount('$ADDRESSES', '$PASSWORD', 300)) {
    throw new Error('❌ No se pudo desbloquear cuenta');
}

// Desplegar contrato
var txHash = eth.sendTransaction({
    from: '$ADDRESSES',
    data: '0x$BYTECODE',
    gas: 4000000,
    gasPrice: '0x0'
});

console.log('📫 Transacción:', txHash);

// Esperar confirmación
var receipt = null;
for (var i = 0; i < 25; i++) {
    receipt = eth.getTransactionReceipt(txHash);
    if (receipt) {
        console.log('✅ Confirmado en bloque', i+1);
        break;
    }
    admin.sleep(1);
}

if (!receipt) throw new Error('❌ Timeout en despliegue');

console.log('🎉 CONTRATO DESPLEGADO:', receipt.contractAddress);

// Fundir contrato
eth.sendTransaction({
    from: '$ADDRESSES',
    to: receipt.contractAddress,
    value: web3.toWei(1000, 'ether'),
    gas: 100000,
    gasPrice: '0x0'
});

// Guardar dirección
require('fs').writeFileSync('/output/contract_address.txt', receipt.contractAddress);
console.log('📄 Dirección guardada');

" attach http://localhost:8545

echo "🏁 Despliegue completado exitosamente"