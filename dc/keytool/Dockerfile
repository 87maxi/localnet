# ---------------------------------------------------------
# Imagen Keytool - Generador de artefactos para Prysm localnet
# ---------------------------------------------------------
FROM  python:3.11-slim AS keytool

ARG TARGETARCH=amd64
ARG GO_VERSION=1.23.1
ARG PRYSM_VERSION=v5.0.4
ENV GETH_WALLET_PASSWORD="no_tiene_wallet_password"

WORKDIR /app

# ---------------------------------------------------------
# Instalar dependencias del sistema
# ---------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
      build-essential \
      libffi-dev \
      libssl-dev \
      wget \
      git \
      vim \
      jq \
      yq \
      curl \
      ca-certificates \
      && rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------
# Actualizar pip y dependencias Python
# ---------------------------------------------------------
RUN python3 -m pip install --upgrade pip setuptools wheel \
 && pip install eth-account
 


# ---------------------------------------------------------
# Instalar Go (descarga oficial)
# ---------------------------------------------------------
#RUN cd /tmp \
# && wget https://go.dev/dl/go${GO_VERSION}.linux-${TARGETARCH}.tar.gz \
# && tar -C /usr/local -xzf go${GO_VERSION}.linux-${TARGETARCH}.tar.gz \
# && ln -s /usr/local/go/bin/go /usr/local/bin/go \
# && rm -f go${GO_VERSION}.linux-${TARGETARCH}.tar.gz

#ENV PATH="/usr/local/go/bin:${PATH}"


# ---------------------------------------------------------
# Instalar Prysm herramientas (multiarquitectura)
# ---------------------------------------------------------
RUN wget https://github.com/OffchainLabs/prysm/releases/download/${PRYSM_VERSION}/prysmctl-${PRYSM_VERSION}-linux-${TARGETARCH} -O /usr/local/bin/prysmctl \
 && chmod +x /usr/local/bin/prysmctl


RUN wget https://github.com/OffchainLabs/prysm/releases/download/${PRYSM_VERSION}/validator-${PRYSM_VERSION}-linux-${TARGETARCH} -O /usr/local/bin/validator \
 && chmod +x /usr/local/bin/validator

# ---------------------------------------------------------
# Copiar scripts de conversión
# ---------------------------------------------------------
COPY convert_keys.py /usr/local/bin/convert_keys
COPY execute_convert.sh /execute_convert.sh
#COPY generate_keystores.py /usr/local/bin/generate_keystores
RUN chmod +x /usr/local/bin/convert_keys /execute_convert.sh \
 && sed -i 's/\r$//' /execute_convert.sh

#wallet memonics tener en cuenta que estos memonics estan relacionados a la password que se defina inicialmente en geth con lo cual cuando los genere tiene que estar con esa password

COPY validator_keys/ /app/validator_keys


# ---------------------------------------------------------
# Entrypoint por defecto
# ---------------------------------------------------------
WORKDIR /data/keytool
#ENTRYPOINT ["/execute_convert.sh"]