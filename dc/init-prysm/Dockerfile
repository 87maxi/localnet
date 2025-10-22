FROM prysmaticlabs/prysm-beacon-chain:v6.1.2

COPY init.sh /init.sh
COPY config.yaml /config.yaml

RUN chmod +x /init.sh

VOLUME ["/genesis"]
ENTRYPOINT ["/init.sh"]