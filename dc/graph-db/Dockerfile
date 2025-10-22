FROM postgres:14

# Limpiar datos antiguos solo si querés reiniciar desde cero
RUN rm -rf /var/lib/postgresql/data/*

# Locale para Graph Node
ENV LANG=C
ENV LC_ALL=C

# ⚠️ Cambiar SQL_ASCII a UTF8
ENV POSTGRES_INITDB_ARGS="--encoding=UTF8 --locale=C"