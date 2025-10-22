#!/bin/bash
set -e

source generate_keystore_and_genesis.sh

DATADIR="/root/.ethereum";
KEYSTORE="$DATADIR/keystore";
PASSWORD_FILE="$DATADIR/password.txt";
GENESIS="$DATADIR/genesis.json";
ETHERBASE=""
JWT_PATH="/jwt"


cp /password.txt  $DATADIR;
cp /wallet-password.txt  $DATADIR;

# Crear JWT si no existe
if [ -d "$JWT_PATH" ]; then
  echo "🔐 Generando JWT secret..."
  cp /app/jwt.hex /jwt;
  JWT_SECRET=/jwt/jwt.hex
else
  echo "no esta montado el volumen jwt-secret ";
fi


mkdir -p "$DATADIR"
 

create_accounts 64  $PASSWORD_FILE;
generate_genesis $GENESIS ;
cat $GENESIS;


#ADDRESSES=$(geth --datadir "$DATADIR" account list | sed -n 's/.*{\([^}]*\)}.*/\1/p')



#echo "########################## $(echo "$ADDRESSES" | head -n1) &&&&&&&&&&&&&&&&&&&&";


