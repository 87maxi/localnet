#!/usr/bin/env python3
import os
import json
from eth_account import Account

KEYSTORE_DIR = "/app/geth/keystore"
PASSWORD_FILE = "/app/geth/password.txt"
OUTPUT_FILE = "/app/output/accounts.txt"

# Leer la contraseña
with open(PASSWORD_FILE, "r") as pf:
    password = pf.read().strip()

os.makedirs("/output", exist_ok=True)

with open(OUTPUT_FILE, "w") as out:
    for filename in os.listdir(KEYSTORE_DIR):
        if filename.startswith("UTC--"):
            filepath = os.path.join(KEYSTORE_DIR, filename)
            try:
                with open(filepath, "r") as f:
                    key_data = json.load(f)

                # Desencriptar usando la contraseña
                private_key_bytes = Account.decrypt(key_data, password)
                private_key_hex = private_key_bytes.hex()

                # Obtener la dirección desde la clave
                acct = Account.from_key(private_key_bytes)
                out.write(f"Address: {acct.address}\nPrivateKey: {private_key_hex}\n\n")

                print(f"✅ Extraída {acct.address}")

            except Exception as e:
                print(f"⚠️ Error procesando {filename}: {e}")

print(f"\n🔒 Claves exportadas a: {OUTPUT_FILE}")
