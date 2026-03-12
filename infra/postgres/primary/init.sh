#!/bin/bash
set -e

echo "📌 Inicializando Primary PostgreSQL..."

# Criar usuário de replicação
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    CREATE USER repl_user REPLICATION LOGIN ENCRYPTED PASSWORD 'repl_password';
EOSQL

echo "✅ Primary pronto com usuário de replicação."
