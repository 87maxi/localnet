

echo "✅ genesis loaded" 
ls -l  "$GENESIS";




# 👇 SOLO inicializar si no existe la cadena
if [ ! -d "$DATADIR/geth/chaindata" ]; then
  echo "🔄 Inicializando cadena con genesis.json..."
  geth init --datadir "$DATADIR" "$GENESIS"
else
  echo "✅ La cadena ya está inicializada. Saltando 'geth init'."
fi

echo "✅ list  DATADIR "
ls -la "$DATADIR";

# 4. Obtener primera cuenta
FIRST_ADDR=$(geth --datadir "$DATADIR" account list | head -n1 | sed -n 's/.*{\([^}]*\)}.*/\1/p')


echo "✅ account $FIRST_ADDR."

# 6. Iniciar Geth como Execution Client (¡sin minado!)
exec geth \
  --datadir "$DATADIR" \
  --http \
  --http.addr "0.0.0.0" \
  --http.port 8545 \
  --http.api eth,net,web3,debug,txpool,engine,admin \
  --ws \
  --ws.addr "0.0.0.0" \
  --ws.port 8546 \
  --ws.api eth,net,web3,debug,txpool,engine,admin \
  --authrpc.addr 0.0.0.0 \
  --authrpc.port 8551 \
  --authrpc.vhosts=* \
  --authrpc.jwtsecret "$JWT_SECRET" \
  --networkid 1337 \
  --syncmode full \
  --gcmode archive \
  --port 30303 \
  --ipcdisable \
  --verbosity 3 