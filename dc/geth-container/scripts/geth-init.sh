#!/bin/bash
set -e

source generate_keystore_and_genesis.sh

export DATADIR="/geth-data"
export DATADIR_TMP="/geth-data/geth-tmp"
export KEYSTORE="$DATADIR_TMP/keystore"
export PASSWORD_FILE="$DATADIR/password.txt"
export WALLET_PASSWORD_FILE="$DATADIR/wallet-password.txt"
export GENESIS="$DATADIR/genesis.json"
export GENESIS_POW="$DATADIR_TMP/genesis.json"
export ETHERBASE=""
export JWT_PATH="/jwt-secret"
export INIT_CONTRACT="/init-contract"




echo  $GETH_PASSWORD > $PASSWORD_FILE;
echo  $GETH_WALLET_PASSWORD > $WALLET_PASSWORD_FILE;

unset GETH_PASSWORD
unset GETH_WALLET_PASSWORD



rm -rf $DATADIR_TMP;
mkdir -p $DATADIR_TMP;
mkdir $KEYSTORE

# Crear JWT si no existe
if [ ! -f "$JWT_PATH" ] && [ -d "/app" ]; then
    echo "🔐 Generando JWT secret..."
    cp /app/jwt.hex "$JWT_PATH" 2>/dev/null || echo "⚠️  No se pudo copiar JWT"
fi

mkdir -p "$DATADIR"



ls -l "$DATADIR"

export ADDRESSES


log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

run_script() {
    local script_name="$1"
    log "🚀 EJECUTANDO: $script_name"
    
    if source "$script_name"; then
        log "✅ COMPLETADO: $script_name"
    else
        log "❌ FALLÓ: $script_name"
        exit 1
    fi
}

# Exportar todas las variables necesarias para los scripts hijos
export DATADIR \
KEYSTORE \
DATADIR_TMP \
PASSWORD_FILE \
GENESIS \
ETHERBASE \
JWT_PATH \
NUM_ACCOUNT \
ACCOUNTS_CREATED_delete \
WALLET_PASSWORD_FILE \
INIT_CONTRACT




# Ejecutar scripts
#run_script "/app/generate_genesis_with_contract.sh"




echo $GENESIS


#cp $GENESIS_TMP $DATADIR;

echo "🎉 Todos los scripts completados exitosamente"

echo "🔄 Inicializando Geth con genesis..."
if [ -f "$DATADIR/genesis.json" ]; then
    geth --datadir "$DATADIR" init "$DATADIR/genesis.json"
    echo "✅ Geth inicializado"
else
    echo "❌ Genesis.json no encontrado en $DATADIR"
    exit 1
fi

# =============================================================================
# 3. MOSTRAR INFORMACIÓN DEL DESPLIEGUE
# =============================================================================
echo "🔍 Información del despliegue:"
if [ -f "/output/deployment-info.json" ]; then
    echo "📄 Detalles guardados en /output/deployment-info.json"
    cat /output/deployment-info.json
fi

if [ -f "/output/contract-address.txt" ]; then
    CONTRACT_ADDRESS=$(cat /output/contract-address.txt)
    echo "✅ DepositContract: $CONTRACT_ADDRESS"
fi

if [ -f "/output/contract-owner.txt" ]; then
    CONTRACT_ACCOUNT=$(cat /output/contract-owner.txt)
    echo "✅ Cuenta dedicada: $CONTRACT_ACCOUNT"
fi





echo ""
echo "🚀 PROCESO COMPLETADO"
echo "🎯 DepositContract listo en dirección fija"
echo "👤 Cuenta dedicada generada con fondos"


source "/app/generate_genesis_with_contract.sh";


echo "#################### $NUM_ACCOUNT"

generate_accounts;


cp -r $KEYSTORE  $DATADIR;

run_script "/app/genesis-sepolia.sh"