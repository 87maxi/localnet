#!/usr/bin/env bash
set -euo pipefail

ERIGON_DATA=../dc/erigon-data

KEYSTORE="${1:-./keystore}"   # default si no pasás arg
DEST_KEYSTORE=${ERIGON_DATA}/keystore;
rm -rf $DEST_KEYSTORE;
mkdir $DEST_KEYSTORE;

# usar nullglob para que no quede el literal si no hay matches
shopt -s nullglob

# recoger archivos en un array (maneja espacios en nombres)
files=( "$KEYSTORE"/* )



if [ ${#files[@]} -eq 0 ]; then
  echo "No se encontraron archivos en: $KEYSTORE"
  exit 0
fi

for f in "${files[@]}"; do
  base=$(basename "$f")
  # extraer la parte final después del último '--' y sacar .json si existe
  addr=$(printf '%s' "$base" | awk -F'--' '{print $NF}' | sed 's/\.json$//I' | tr '[:upper:]' '[:lower:]')
  cp $f $DEST_KEYSTORE;
  echo "0x$addr -> $f"
done

cp password.txt   ${ERIGON_DATA};
cp ./data/erigon/genesis.json   ${ERIGON_DATA};