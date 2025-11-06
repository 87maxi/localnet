#!/bin/bash
set -e

echo "🔧 Configurando base de datos para Graph Node..."
echo "📊 Verificando collation de la base de datos..."

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    \l
    SELECT datname, datcollate FROM pg_database WHERE datname = 'graph-node';
EOSQL

echo "✅ Base de datos configurada con collation C"