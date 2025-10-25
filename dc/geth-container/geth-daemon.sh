

echo "✅ genesis daemon loaded " 

# 👇 SOLO inicializar si no existe la cadena
if [ ! -d "$DATADIR/geth/chaindata" ]; then
  echo "🔄 Inicializando cadena con genesis.json..."
  geth init --datadir "$DATADIR" "$GENESIS"
else
  echo "✅ La cadena ya está inicializada. Saltando 'geth init'."
fi

echo "✅ list  DATADIR "
ls -la "$DATADIR";


MASTER_ACCOUNT=$(cat /output/contract-owner.txt);

echo "✅ account $MASTER_ACCOUNT."

echo "🏃 Iniciando Geth (modo merge)..."
exec geth \
    --datadir="$DATADIR" \
    --http \
    --http.addr=0.0.0.0 \
    --http.port=8545 \
    --http.corsdomain="*" \
    --http.vhosts="*" \
    --http.api=web3,eth,net,engine,admin,debug,txpool,personal,miner \
    --ws \
    --ws.addr=0.0.0.0 \
    --ws.port=8546 \
    --ws.origins="*" \
    --ws.api=web3,eth,net \
    --authrpc.addr=0.0.0.0 \
    --authrpc.port=8551 \
    --authrpc.vhosts="*" \
    --authrpc.jwtsecret="$JWT_SECRET" \
    --syncmode=full \
    --networkid=1337 \
    --port=30303 \
    --nodiscover \
    --maxpeers=0 \
    --verbosity=3 \
    --metrics \
    --metrics.addr=0.0.0.0 \
    --metrics.port=6060 \
    --pprof \
    --pprof.addr=0.0.0.0 \
    --pprof.port=6070 \
