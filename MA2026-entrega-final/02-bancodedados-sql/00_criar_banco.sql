-- 00_criar_banco.sql
-- Cria o banco cheiU e os schemas stg (texto, como veio do CSV) e dw (tipado, fonte da verdade, decisão 0002).
-- Idempotente. Rodar com:
--   docker exec cheiu-sql bash -c '/opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -i /scripts/00_criar_banco.sql'
IF DB_ID(N'cheiU') IS NULL
    CREATE DATABASE cheiU COLLATE Latin1_General_100_CI_AI_SC_UTF8;
GO
USE cheiU;
GO
IF SCHEMA_ID(N'stg') IS NULL EXEC(N'CREATE SCHEMA stg');
GO
IF SCHEMA_ID(N'dw') IS NULL EXEC(N'CREATE SCHEMA dw');
GO
SELECT name AS schema_criado FROM sys.schemas WHERE name IN (N'stg', N'dw') ORDER BY name;
GO
