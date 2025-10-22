#!/usr/bin/env bash
set -euo pipefail

# manage_keystore.sh
# Uso:
#   Crear N cuentas nuevas:
#     ./manage_keystore.sh new -n 5 -d ./data/erigon -p ./password.txt
#
#   Importar claves privadas desde un archivo (una key hex por línea, sin 0x):
#     ./manage_keystore.sh import -k privs.txt -d ./data/erigon -p ./password.txt
#
# Opciones:
#   -d KEYS_DIR   Directorio datadir para geth (se creará KEYS_DIR/keystore)
#   -p PASS_FILE  Archivo con la contraseña para cifrar las keys (si no existe se creará con la contraseña por defecto)
#   -n N          Número de cuentas a crear (modo new)
#   -k KEYS_FILE  Archivo con claves privadas (modo import) - una por línea, sin 0x

usage(){
  cat <<EOF
Usage:
  Create N new accounts:
    $0 new -n 5 -d ./data/erigon -p ./password.txt

  Import private keys from a file (one per line, hex, no 0x):
    $0 import -k privs.txt -d ./data/erigon -p ./password.txt

Options:
  -d KEYS_DIR   datadir para geth (default: ./data/erigon)
  -p PASS_FILE  archivo con la contraseña (default: ./password.txt)
  -n N          número de cuentas a crear (modo new)
  -k KEYS_FILE  archivo con claves privadas (modo import)
EOF
  exit 1
}

# defaults
DATADIR="./data/erigon"
PASSFILE="./password.txt"
MODE=""
N=0
KEYS_FILE=""

# parse args
if [ $# -lt 1 ]; then usage; fi
MODE="$1"; shift

while getopts ":d:p:n:k:h" opt; do
  case $opt in
    d) DATADIR="$OPTARG" ;;
    p) PASSFILE="$OPTARG" ;;
    n) N="$OPTARG" ;;
    k) KEYS_FILE="$OPTARG" ;;
    h) usage ;;
    \?) echo "Invalid option -$OPTARG" >&2; usage ;;
  esac
done

# ensure geth available
if ! command -v geth >/dev/null 2>&1; then
  echo "ERROR: geth no está instalado o no está en PATH." >&2
  exit 2
fi

mkdir -p "${DATADIR}"
mkdir -p "${DATADIR}/keystore"

# ensure password file exists (if not, create a random one and show it)
if [ ! -f "${PASSFILE}" ]; then
  echo "password" > "${PASSFILE}"
  chmod 600 "${PASSFILE}"
  echo "⚠️  Password file no existía. Se creó ${PASSFILE} con valor 'password'. Cámbialo si lo necesitas."
fi

# helper para parsear direccion del output de geth
extract_address_from_output() {
  # recibe stdout de geth en stdin, imprime la dirección en formato 0x...
  # geth suele mostrar: Address: {f39fd6...}
  grep -oE "0x[a-fA-F0-9]{40}|[a-fA-F0-9]{40}" | head -n1 | sed 's/{//g; s/}//g; s/^/0x/' 
}

# crear cuentas nuevas
create_accounts() {
  local count=$1
  echo "🔐 Creando ${count} cuentas en ${DATADIR}/keystore (password: ${PASSFILE})..."
  for i in $(seq 1 "${count}"); do
    # geth account new prints the address to stdout
    out=$(geth account new --datadir "${DATADIR}" --password "${PASSFILE}" 2>&1)
    addr=$(printf "%s" "$out" | extract_address_from_output)
    # buscar archivo json recientemente creado asociable a esa dirección
    # geth guarda en datadir/keystore/UTC--...--<address>.json (address sin 0x, lowercase)
    if [ -n "$addr" ]; then
      file=$(ls -1 "${DATADIR}/keystore" | grep -i "$(echo "$addr" | sed 's/^0x//I')" | tail -n1 || true)
      echo "  ✅ $addr -> ${DATADIR}/keystore/${file}"
    else
      echo "  ❌ No pude extraer dirección (output de geth):"
      echo "$out"
    fi
  done
}

# importar claves privadas
import_keys() {
  local keysfile="$1"
  if [ ! -f "$keysfile" ]; then
    echo "ERROR: archivo de claves ${keysfile} no encontrado." >&2
    exit 3
  fi
  echo "🔐 Importando claves de ${keysfile} en ${DATADIR}/keystore (password: ${PASSFILE})..."
  while IFS= read -r key || [ -n "$key" ]; do
    # quitar espacios y 0x
    key=$(echo "$key" | tr -d '[:space:]' | sed 's/^0x//I')
    [ -z "$key" ] && continue
    if ! [[ "$key" =~ ^[A-Fa-f0-9]{64}$ ]]; then
      echo "  ⚠️ Omitiendo línea no válida: $key"
      continue
    fi
    tmp=$(mktemp)
    echo "$key" > "$tmp"
    out=$(geth account import --datadir "${DATADIR}" --password "${PASSFILE}" "$tmp" 2>&1) || true
    rm -f "$tmp"
    addr=$(printf "%s" "$out" | extract_address_from_output)
    if [ -n "$addr" ]; then
      file=$(ls -1 "${DATADIR}/keystore" | grep -i "$(echo "$addr" | sed 's/^0x//I')" | tail -n1 || true)
      echo "  ✅ $addr -> ${DATADIR}/keystore/${file}"
    else
      echo "  ❌ Error importando key (output):"
      echo "$out"
    fi
  done < "$keysfile"
}

# ejecutar modo
case "$MODE" in
  new)
    if [ "$N" -le 0 ]; then
      echo "ERROR: tenés que pasar -n N (número de cuentas a crear)."
      usage
    fi
    create_accounts "$N"
    ;;
  import)
    if [ -z "$KEYS_FILE" ]; then
      echo "ERROR: tenés que pasar -k KEYS_FILE con las claves privadas (una por línea)."
      usage
    fi
    import_keys "$KEYS_FILE"
    ;;
  *)
    echo "ERROR: modo desconocido: $MODE"
    usage
    ;;
esac

echo "✅ Hecho."
