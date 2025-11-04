FROM  ethereum/client-go:v1.13.15

WORKDIR /app

ENV NUM_ACCOUNT=8
ENV GETH_PASSWORD="no_tiene_password"
ENV GETH_WALLET_PASSWORD="no_tiene_wallet_password"
ENV GETH_JWT_HEX="0000000000000000000000000000000000000000000000000000000"


ENV SOLC_VERSION=v0.8.19

# Instalar utilidades
RUN apk add --no-cache bash jq wget curl python3 py3-pip  openssl

#solidity


# Verificar instalación


RUN cd /tmp && wget https://github.com/argotorg/solidity/releases/download/${SOLC_VERSION}/solc-static-linux
RUN mv /tmp/solc-static-linux /usr/local/bin/solc
RUN chmod +x /usr/local/bin/solc

# Añadir librerías compatibles para Alpine musl
RUN apk add --no-cache libstdc++ gcompat

RUN solc --version

COPY ./init-contract /app/init-contract

RUN chmod +x -R /app/init-contract


# Copiar scripts
COPY ./scripts/* /app/

# Permisos
RUN chmod +x -R /app

EXPOSE 8545 8546 30303



