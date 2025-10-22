FROM  ethereum/client-go:v1.13.14

WORKDIR /app

# Instalar utilidades
RUN apk add --no-cache bash jq

# Copiar scripts
COPY geth-init.sh /app/geth-init.sh
COPY geth-daemon.sh /app/geth-daemon.sh
COPY generate_keystore_and_genesis.sh /app/generate_keystore_and_genesis.sh
COPY password.txt /password.txt
COPY wallet-password.txt /wallet-password.txt
COPY jwt.hex /jwt.hex
# Permisos
RUN chmod +x /app/geth-init.sh /app/generate_keystore_and_genesis.sh /app/geth-daemon.sh

EXPOSE 8545 8546 30303



