#!/bin/bash
set -e

echo "🔍 Diagnóstico de conexión Prysm-Geth"

echo "1. Verificando contrato en Geth..."
CONTRACT_CODE=$(curl -s -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"eth_getCode","params":["0x0000000000000000000000000000000000000001", "latest"],"id":1}' | jq -r '.result')

if [ -n "$CONTRACT_CODE" ] && [ "$CONTRACT_CODE" != "0x" ]; then
    echo "✅ Contrato encontrado en Geth: ${#CONTRACT_CODE} chars"
else
    echo "❌ Contrato NO encontrado en Geth"
fi

echo ""
echo "2. Verificando conexión Engine API..."
if docker exec prysm-beacon curl -s -f http://geth-daemon:8551 > /dev/null 2>&1; then
    echo "✅ Engine API accesible"
else
    echo "❌ No se puede acceder a Engine API"
fi

echo ""
echo "3. Verificando JWT secret..."
GETH_JWT=$(docker exec geth-daemon-1 cat /jwt-secret/jwt.hex 2>/dev/null | md5sum | cut -d' ' -f1)
PRYSM_JWT=$(docker exec prysm-beacon cat /jwt-secret/jwt.hex 2>/dev/null | md5sum | cut -d' ' -f1)

if [ "$GETH_JWT" = "$PRYSM_JWT" ] && [ -n "$GETH_JWT" ]; then
    echo "✅ JWT secrets coinciden"
else
    echo "❌ JWT secrets NO coinciden o faltan"
fi

echo ""
echo "4. Buscando errores en logs de Prysm..."
docker logs prysm-beacon 2>&1 | grep -i "error" | tail -5

echo ""
echo "5. Verificando estado de sincronización de Geth..."
SYNC_STATUS=$(curl -s -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}' | jq -r '.result')

if [ "$SYNC_STATUS" = "false" ]; then
    echo "✅ Geth sincronizado"
else
    echo "❌ Geth aún sincronizando: $SYNC_STATUS"
fi

echo ""
echo "6. Verificando que Prysm use la bandera --deposit-contract..."
docker logs prysm-beacon 2>&1 | grep "deposit-contract" | head -2
