FROM  ethereum/client-go:v1.13.15

WORKDIR /app

ENV NUM_ACCOUNT=8


ENV SOLC_VERSION=v0.8.19

# Instalar utilidades
RUN apk add --no-cache bash jq wget curl python3 py3-pip 

#solidity


# Verificar instalación


RUN cd /tmp && wget https://github.com/argotorg/solidity/releases/download/${SOLC_VERSION}/solc-static-linux
RUN mv /tmp/solc-static-linux /usr/local/bin/solc
RUN chmod +x /usr/local/bin/solc

# Añadir librerías compatibles para Alpine musl
RUN apk add --no-cache libstdc++ gcompat

RUN solc --version

COPY ./init-contract /init-contract

RUN chmod +x -R /init-contract


# Copiar scripts
COPY geth-init.sh /app/geth-init.sh
COPY geth-daemon.sh /app/geth-daemon.sh
COPY generate_keystore_and_genesis.sh /app/generate_keystore_and_genesis.sh
COPY generate_genesis_with_contract.sh /app/generate_genesis_with_contract.sh
COPY healthcheck-deposit.sh /app/healthcheck-deposit.sh
COPY password.txt /password.txt
COPY wallet-password.txt /wallet-password.txt
COPY jwt.hex /jwt.hex
# Permisos
RUN chmod +x -R /app

EXPOSE 8545 8546 30303



