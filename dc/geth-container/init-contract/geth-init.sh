#!/bin/bash
set -e

echo "🚀 Inicializando Geth para despliegue... $ADDRESSES"

# Si no existe keystore, crear cuenta
if [ ! -d "$DATADIR_TMP/keystore" ]; then
    echo "📝 Creando nueva cuenta..."
    geth --datadir "$DATADIR_TMP" account new --password "$DATADIR/password.txt" <<< $'\\n' 2>/dev/null || true
fi


ACCOUNT_DEV=$(geth --datadir "$DATADIR_TMP" account list 2>/dev/null | head -1 | awk -F'[{}]' '{print "0x" $2}' || echo "0x93f2450aab936cdfd17a164a502b3d762b26e58e")
echo "💰 Usando cuenta: $ACCOUNT_DEV"

echo $ACCOUNT_DEV > /output/account_dev.txt;

# =============================================================================
# 1. INICIALIZAR CADENA
# =============================================================================
echo "📄 Inicializando cadena con genesis PoW..."
geth --datadir "$DATADIR_TMP" init $GENESIS_POW;
echo "geth --datadir "$DATADIR_TMP" init $GENESIS_POW;"
echo "✅ Cadena inicializada"

echo $GENESIS_POW; 
cat $GENESIS_POW;
mkdir -p /output/tmp;

cp  -r $DATADIR_TMP /output/tmp;
# =============================================================================
# 2. INICIAR GETH CON MINERÍA PoW
# =============================================================================
echo "🔄 Iniciando Geth con minería PoW... $ADDRESSES "
geth --datadir "$DATADIR_TMP" \
    --http \
    --http.addr 0.0.0.0 \
    --http.port 8545 \
    --http.corsdomain "*" \
    --http.vhosts "*" \
    --http.api web3,eth,net,admin,miner \
    --ws \
    --ws.addr 0.0.0.0 \
    --ws.port 8546 \
    --ws.origins "*" \
    --ws.api web3,eth,net,admin \
    --syncmode full \
    --networkid 1337 \
    --port 30303 \
    --nodiscover \
    --maxpeers 0 \
    --mine \
    --miner.etherbase="$ADDRESSES" \
    --miner.gasprice 1000000000 \
    --miner.gaslimit 30000000 \
    --verbosity 3 &

# Capturar PID inmediatamente
GETH_PID=$!
echo "📡 Geth PID: $GETH_PID"


# =============================================================================
# 3. ESPERAR A QUE GETH ESTÉ LISTO
# =============================================================================
echo "⏳ Esperando a que Geth esté listo..."
for i in {1..10}; do
    if curl -s -X POST -H "Content-Type: application/json" \
        --data '{"jsonrpc":"2.0","method":"net_version","params":[],"id":1}' \
        http://localhost:8545 > /dev/null; then
        echo "✅ Geth listo después de $i intentos"
        break
    fi
    if [ $i -eq 10 ]; then
        echo "❌ Geth no responde después de 10 intentos"
        kill $GETH_PID
        exit 1
    fi
    sleep 3
done

# =============================================================================
# 4. EJECUTAR DESPLIEGUE
# =============================================================================
echo "🏗️  Ejecutando despliegue..."
if /bin/bash /init-contract/deploy-contract.sh $ADDRESSES; then
    echo "✅ Despliegue ejecutado exitosamente"
else
    echo "❌ Error en el despliegue"
    kill $GETH_PID
    exit 1
fi

# =============================================================================
# 5. VERIFICAR QUE EL CONTRATO SE DESPLEGÓ
# =============================================================================
echo "🔍 Verificando despliegue..."
if [ -f "/output/contract_address.txt" ]; then
    CONTRACT_ADDRESS=$(cat /output/contract_address.txt)
    echo "🎉 Contrato desplegado en: $CONTRACT_ADDRESS"
else
    echo "⚠️  No se encontró la dirección del contrato"
fi

# =============================================================================
# 6. DETENER GETH
# =============================================================================
echo "🛑 Deteniendo Geth..."
kill $GETH_PID
# Esperar a que se cierre correctamente
if wait $GETH_PID 2>/dev/null; then
    echo "✅ Geth detenido correctamente"
else
    echo "⚠️  Geth ya estaba detenido"
fi

echo "🚀 PROCESO COMPLETADO"