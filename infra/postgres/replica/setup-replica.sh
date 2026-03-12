#!/bin/bash
set -e

echo "📌 Configurando Replica PostgreSQL..."

# Variáveis do Primary
PRIMARY_HOST=${POSTGRES_PRIMARY_HOST:-postgres-primary}
REPL_USER=repl_user
REPL_PASSWORD=repl_password

# Aguarda Primary
until pg_isready -h $PRIMARY_HOST -U $POSTGRES_USER; do
  echo "⏳ Aguardando Primary $PRIMARY_HOST..."
  sleep 2
done

# Limpa dados antigos
rm -rf /var/lib/postgresql/data/*

# Faz base do dump do Primary
PGPASSWORD=$POSTGRES_PASSWORD pg_basebackup -h $PRIMARY_HOST -D /var/lib/postgresql/data -U $REPL_USER -v -P --wal-method=stream

# Cria recovery.conf (Postgres < 12) ou standby.signal + primary_conninfo (Postgres >=12)
echo "primary_conninfo = 'host=$PRIMARY_HOST port=5432 user=$REPL_USER password=$REPL_PASSWORD'" >> /var/lib/postgresql/data/postgresql.auto.conf
touch /var/lib/postgresql/data/standby.signal

chown -R postgres:postgres /var/lib/postgresql/data

echo "✅ Replica configurada e pronta."
