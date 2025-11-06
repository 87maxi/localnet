-- Script de inicialización para Graph Node
SELECT 'CREATE DATABASE graph_node WITH ENCODING ''UTF8'' LC_COLLATE = ''C'' LC_CTYPE = ''C'''
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'graph_node')\gexec

\c graph_node;

CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS btree_gin;
CREATE EXTENSION IF NOT EXISTS btree_gist;

SELECT datname, datcollate, datctype FROM pg_database WHERE datname = 'graph_node';
