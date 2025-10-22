FROM erigontech/erigon:latest

USER root



COPY genesis.json /genesis.json
COPY init-erigon.sh /init-erigon.sh

RUN chmod +x /init-erigon.sh \
    && mkdir -p /data/erigon \
    && chown -R erigon:erigon /data/erigon /genesis.json /init-erigon.sh

USER erigon

ENTRYPOINT ["/init-erigon.sh"]