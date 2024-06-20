#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    CREATE USER dalgo_user WITH PASSWORD 'password';
    CREATE USER prefect_user WITH PASSWORD 'password';

    CREATE DATABASE dalgo;
    CREATE DATABASE prefect;

    GRANT ALL PRIVILEGES ON DATABASE dalgo TO dalgo_user;
    GRANT ALL PRIVILEGES ON DATABASE prefect TO prefect_user;

EOSQL

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "dalgo" <<-EOSQL

    GRANT ALL PRIVILEGES ON SCHEMA public TO dalgo_user;
    GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO dalgo_user;
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO dalgo_user;
EOSQL

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "prefect" <<-EOSQL

    GRANT ALL PRIVILEGES ON SCHEMA public TO prefect_user;
    GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO prefect_user;
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO prefect_user;
EOSQL