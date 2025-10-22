#!/usr/bin/env python3
import os
import json
from eth_account import Account
from eth_utils import keccak
from typing import List
from hashlib import sha256

# Instalar con: pip install eth-account eth-utils

# Mnemónico estándar de pruebas
MNEMONIC = "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
PASSWORD = "password1234"  # debe coincidir con tu wallet-password.txt
NUM_VALIDATORS = 8
KEYSTORE_DIR = "/data/keytool/validator_keys"

# Derivación BIP-32/44 para Ethereum 2 (EIP-2333)
def derive_child_SK(seed: bytes, index: int) -> int:
    from py_ecc.bls import G2ProofOfPossession as bls
    return bls.Keygen(seed)(index)

def mnemonic_to_seed(mnemonic: str) -> bytes:
    from eth2deposit.utils.mnemonic import get_seed
    return get_seed(mnemonic, "")

def generate_keystores():
    os.makedirs(KEYSTORE_DIR, exist_ok=True)
    
    try:
        seed = mnemonic_to_seed(MNEMONIC)
    except Exception:
        # Fallback manual si eth2deposit no está disponible
        from hashlib import pbkdf2_hmac
        salt = "mnemonic".encode('utf-8')
        seed = pbkdf2_hmac('sha512', MNEMONIC.encode('utf-8'), salt, 2048, 64)
    
    from py_ecc.bls import G2ProofOfPossession as bls
    
    for i in range(NUM_VALIDATORS):
        sk = derive_child_SK(seed, i)
        pk = bls.SkToPk(sk)
        
        # Crear keystore usando eth_account (aunque es para Eth1, el formato es compatible)
        private_key_bytes = sk.to_bytes(32, 'big')
        acct = Account.from_key(private_key_bytes)
        keystore = acct.encrypt(PASSWORD)
        
        # Asegurar que el keystore tenga el campo "pubkey" en formato BLS (hex sin 0x)
        pubkey_hex = pk.hex()
        keystore['pubkey'] = pubkey_hex
        
        filename = f"keystore-{i:06d}.json"
        filepath = os.path.join(KEYSTORE_DIR, filename)
        with open(filepath, "w") as f:
            json.dump(keystore, f)
        print(f"✅ Generado: {filepath}")

if __name__ == "__main__":
    generate_keystores()