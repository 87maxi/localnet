#!/bin/bash
set -e

# Crear múltiples bases de datos para diferentes propósitos
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    -- Base de datos para Blockscout
    CREATE DATABASE blockscout;
    
    -- Base de datos para aplicación DAO
    CREATE DATABASE dao_app;
    
    -- Base de datos para indexadores
    CREATE DATABASE indexer_db;
    
    -- Otorgar permisos
    GRANT ALL PRIVILEGES ON DATABASE blockscout TO postgres;
    GRANT ALL PRIVILEGES ON DATABASE dao_app TO postgres;
    GRANT ALL PRIVILEGES ON DATABASE indexer_db TO postgres;
EOSQL

echo "✅ Bases de datos creadas: blockscout, dao_app, indexer_db"