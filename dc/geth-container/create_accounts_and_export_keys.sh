#!/usr/bin/env bash
set -euo pipefail

# Usage: ./create_accounts_and_export_keys.sh <n> <passfile> <datadir>
# Example: ./create_accounts_and_export_keys.sh 5 /password.txt /root/.ethereum

N="${1:-1}"
PASSFILE="${2:-/password.txt}"
DATADIR="${3:-/root/.ethereum}"
OUTFILE="${4:-/private_keys.txt}"

# ensure datadir exists
mkdir -p "$DATADIR"
mkdir -p "$DATADIR/keystore"

# create/overwrite outfile safely
: > "$OUTFILE"
chmod 600 "$OUTFILE"

echo "🔐 Creando $N cuentas en keystore ($DATADIR) y guardando private keys en $OUTFILE"

for i in $(seq 1 "$N"); do
  # create new account
  out=$(geth account new --datadir "$DATADIR" --password "$PASSFILE" 2>&1) || true
  addr=$(echo "$out" | grep -oE "0x[a-fA-F0-9]{40}" | head -n1 | tr '[:upper:]' '[:lower:]')

  if [ -z "$addr" ]; then
    echo "  ❌ No se obtuvo address para la cuenta $i. Output:"
    echo "$out"
    continue
  fi

  echo "  ✅ $addr"

  # find keystore file created for that address (pattern includes the address)
  ksfile=$(ls "$DATADIR/keystore/"*"$addr"* 2>/dev/null | head -n1 || true)
  if [ -z "$ksfile" ] || [ ! -f "$ksfile" ]; then
    echo "  ⚠️  No se encontró keystore para $addr (esperado en $DATADIR/keystore)."
    continue
  fi

  # decrypt using embedded python (web3)
  privhex=$(python3 - <<PYTHON -- "$ksfile" "$PASSFILE"
import sys, json
from web3 import Account

ks_path = sys.argv[1]
passfile = sys.argv[2]

# read password (first non-empty line)
with open(passfile, 'r') as f:
    lines = [l.strip() for l in f.readlines() if l.strip()!='']
    if not lines:
        sys.exit(0)
    passwd = lines[0]

with open(ks_path,'r') as kf:
    keystore = kf.read()

try:
    pk = Account.decrypt(keystore, passwd)  # bytes
    # print without 0x, in hex
    print(pk.hex())
except Exception as e:
    # signal failure by printing nothing
    sys.exit(0)
PYTHON
)

  if [ -z "$privhex" ]; then
    echo "  ⚠️  No se pudo descifrar la clave privada de $addr. ¿Contraseña correcta?"
    continue
  fi

  # append to outfile: 0x<privhex> <address>
  echo "0x${privhex}  ${addr}" >> "$OUTFILE"
  # zero variables
  privhex=""
done

echo "🔒 Private keys guardadas en: $OUTFILE (perm: $(stat -c '%a %n' "$OUTFILE"))"
echo "Importante: protege o elimina el archivo cuando termines: chmod 600 $OUTFILE  && shred -u $OUTFILE"
