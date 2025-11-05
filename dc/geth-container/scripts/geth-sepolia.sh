#!/bin/sh
set -e

echo "=== INICIANDO GETH PARA SEPOLIA TESTNET ==="

JWT_SECRET="/jwt-secret/jwt.hex"
DATADIR="/geth-data"

# Crear directorios si no existen
mkdir -p /jwt-secret "$DATADIR" /output

# INSTALAR OPENSSL SI NO EXISTE
if ! command -v openssl >/dev/null 2>&1; then
    echo "Instalando openssl..."
    apk update && apk add openssl curl
fi

# Crear JWT secret si no existe
if [ ! -f "$JWT_SECRET" ]; then
    echo "Creando JWT secret..."
    openssl rand -hex 32 | tr -d '\n' > "$JWT_SECRET"
    echo "JWT secret creado en: $JWT_SECRET"
fi

# Verificar formato del JWT
JWT_CONTENT=$(cat "$JWT_SECRET")
JWT_LENGTH=${#JWT_CONTENT}
if [ "$JWT_LENGTH" -ne 64 ]; then
    echo "JWT con formato incorrecto ($JWT_LENGTH chars), regenerando..."
    openssl rand -hex 32 | tr -d '\n' > "$JWT_SECRET"
fi

# Copiar JWT secret para otros servicios
cp "$JWT_SECRET" /output/jwt.hex

echo "=== CONFIGURACIÓN GETH ==="
echo "Red: Sepolia"
echo "Datadir: $DATADIR" 
echo "JWT: $JWT_SECRET ($(wc -c < "$JWT_SECRET") bytes)"

echo "=== INICIANDO GETH ==="

# EJECUTAR GETH EN PRIMER PLANO
exec geth \
    --sepolia \
    --datadir="$DATADIR" \
    --syncmode=snap \
    --http \
    --http.addr=0.0.0.0 \
    --http.port=8545 \
    --http.api=eth,net,web3,engine,admin,debug \
    --http.corsdomain="*" \
    --http.vhosts="*" \
    --ws \
    --ws.addr=0.0.0.0 \
    --ws.port=8546 \
    --ws.api=eth,net,web3,engine \
    --ws.origins="*" \
    --authrpc.addr=0.0.0.0 \
    --authrpc.port=8551 \
    --authrpc.vhosts="*" \
    --authrpc.jwtsecret="$JWT_SECRET" \
    --maxpeers=50