-- 02_carga.sql
-- Procedure dw.usp_carregar_tudo: limpa o stg, carrega os CSVs de /carga (gerados pela macro ExportarParaCarga, E4.5)
-- com BULK INSERT, converte os tipos e grava no dw numa transação. Rodar duas vezes dá o mesmo resultado.
-- Termina com a conferência de linhas stg × dw por tabela (dw.vw_conf_carga).
USE cheiU;
GO
-- O BULK INSERT do SQL Server no Linux não aceita CODEPAGE e lê o arquivo como OEM 437, convertendo cada byte
-- UTF-8 num caractere ("Útil" chega como "├Ütil"). A 437 cobre os 256 bytes, então a conversão se desfaz:
-- volta o texto para os bytes 437 originais e lê esses bytes como UTF-8.
CREATE OR ALTER FUNCTION stg.fn_utf8 (@s varchar(8000))
RETURNS nvarchar(4000)
WITH SCHEMABINDING
AS
BEGIN
    RETURN NULLIF(CONVERT(nvarchar(4000), CONVERT(varchar(8000), CONVERT(varbinary(8000), CONVERT(varchar(8000), @s COLLATE SQL_Latin1_General_CP437_BIN)))
        COLLATE Latin1_General_100_CI_AI_SC_UTF8), N'');
END;
GO
CREATE OR ALTER PROCEDURE dw.usp_carregar_tudo
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    TRUNCATE TABLE stg.Dim_Calendario;
    TRUNCATE TABLE stg.Dim_Grupo;
    TRUNCATE TABLE stg.Dim_Transporte;
    TRUNCATE TABLE stg.Fato_Transporte;
    TRUNCATE TABLE stg.Fato_Referencia_Mensal;
    TRUNCATE TABLE stg.Rejeitados;
    TRUNCATE TABLE stg.Dim_Horario;
    TRUNCATE TABLE stg.Fato_Clima_Horario;

    BULK INSERT stg.Dim_Calendario         FROM '/carga/Dim_Calendario.csv'         WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDQUOTE = '"', ROWTERMINATOR = '0x0a', TABLOCK);
    BULK INSERT stg.Dim_Grupo              FROM '/carga/Dim_Grupo.csv'              WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDQUOTE = '"', ROWTERMINATOR = '0x0a', TABLOCK);
    BULK INSERT stg.Dim_Transporte         FROM '/carga/Dim_Transporte.csv'         WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDQUOTE = '"', ROWTERMINATOR = '0x0a', TABLOCK);
    BULK INSERT stg.Fato_Transporte        FROM '/carga/Fato_Transporte.csv'        WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDQUOTE = '"', ROWTERMINATOR = '0x0a', TABLOCK);
    BULK INSERT stg.Fato_Referencia_Mensal FROM '/carga/Fato_Referencia_Mensal.csv' WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDQUOTE = '"', ROWTERMINATOR = '0x0a', TABLOCK);
    BULK INSERT stg.Dim_Horario            FROM '/carga/Dim_Horario.csv'            WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDQUOTE = '"', ROWTERMINATOR = '0x0a', TABLOCK);
    BULK INSERT stg.Fato_Clima_Horario     FROM '/carga/Fato_Clima_Horario.csv'     WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDQUOTE = '"', ROWTERMINATOR = '0x0a', TABLOCK);
    BULK INSERT stg.Rejeitados             FROM '/carga/Rejeitados.csv'             WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDQUOTE = '"', ROWTERMINATOR = '0x0a', TABLOCK);

    BEGIN TRANSACTION;
        DELETE FROM dw.Fato_Transporte;
        DELETE FROM dw.Fato_Clima_Horario;
        DELETE FROM dw.Dim_Horario;
        DELETE FROM dw.Fato_Referencia_Mensal;
        DELETE FROM dw.Rejeitados;
        DELETE FROM dw.Dim_Transporte;
        DELETE FROM dw.Dim_Grupo;
        DELETE FROM dw.Dim_Calendario;
        DBCC CHECKIDENT ('dw.Rejeitados', RESEED, 0) WITH NO_INFOMSGS;

        INSERT INTO dw.Dim_Calendario (data, feriado_nome, fonte_feriado, ano, mes, nome_mes, mes_rotulo, mes_inicio, dia, dia_semana, nome_dia, semana_ano, tipo_dia)
        SELECT CONVERT(date, data, 23), stg.fn_utf8(feriado_nome), stg.fn_utf8(fonte_feriado), CONVERT(smallint, ano), CONVERT(tinyint, mes), stg.fn_utf8(nome_mes), stg.fn_utf8(mes_rotulo),
               CONVERT(date, mes_inicio, 23), CONVERT(tinyint, dia), CONVERT(tinyint, dia_semana), stg.fn_utf8(nome_dia), CONVERT(tinyint, semana_ano), stg.fn_utf8(tipo_dia)
        FROM stg.Dim_Calendario;

        INSERT INTO dw.Dim_Grupo (grupo, modalidade, ordem, grupo_oficial)
        SELECT stg.fn_utf8(grupo), stg.fn_utf8(modalidade), CONVERT(tinyint, ordem), CONVERT(bit, grupo_oficial)
        FROM stg.Dim_Grupo;

        INSERT INTO dw.Dim_Transporte (id_linha, codigo_linha, nome_linha, modalidade, operador, grupo, lote, primeiro_dia, ultimo_dia,
            dias_com_operacao, grupos_no_ano, linha_rotulo)
        SELECT stg.fn_utf8(id_linha), stg.fn_utf8(codigo_linha), stg.fn_utf8(nome_linha), stg.fn_utf8(modalidade), stg.fn_utf8(operador), stg.fn_utf8(grupo), stg.fn_utf8(lote),
               TRY_CONVERT(date, NULLIF(primeiro_dia, ''), 23), TRY_CONVERT(date, NULLIF(ultimo_dia, ''), 23),
               TRY_CONVERT(smallint, NULLIF(dias_com_operacao, '')), TRY_CONVERT(tinyint, NULLIF(grupos_no_ano, '')), stg.fn_utf8(linha_rotulo)
        FROM stg.Dim_Transporte;

        INSERT INTO dw.Fato_Transporte (data, id_linha, modalidade, passageiros, pagantes, integracao, gratuidades, tipo_metrica, origem_dado)
        SELECT CONVERT(date, data, 23), stg.fn_utf8(id_linha), stg.fn_utf8(modalidade), CONVERT(bigint, passageiros),
               TRY_CONVERT(bigint, NULLIF(pagantes, '')), TRY_CONVERT(bigint, NULLIF(integracao, '')), TRY_CONVERT(bigint, NULLIF(gratuidades, '')),
               stg.fn_utf8(tipo_metrica), stg.fn_utf8(origem_dado)
        FROM stg.Fato_Transporte;

        INSERT INTO dw.Fato_Referencia_Mensal (mes_inicio, grupo, passageiros_publicado, origem_dado, fonte)
        SELECT CONVERT(date, mes_inicio, 23), stg.fn_utf8(grupo), CONVERT(bigint, passageiros_publicado), stg.fn_utf8(origem_dado), stg.fn_utf8(fonte)
        FROM stg.Fato_Referencia_Mensal;

        INSERT INTO dw.Dim_Horario (hora, hora_rotulo, periodo, ordem_periodo)
        SELECT CONVERT(tinyint, hora), stg.fn_utf8(hora_rotulo), stg.fn_utf8(periodo), CONVERT(tinyint, ordem_periodo)
        FROM stg.Dim_Horario;

        INSERT INTO dw.Fato_Clima_Horario (data, hora, temperatura_c, precipitacao_mm, chovendo, origem_dado)
        SELECT CONVERT(date, data, 23), CONVERT(tinyint, hora), CONVERT(decimal(5, 1), temperatura_c), CONVERT(decimal(6, 1), precipitacao_mm),
               CONVERT(bit, chovendo), stg.fn_utf8(origem_dado)
        FROM stg.Fato_Clima_Horario;

        INSERT INTO dw.Rejeitados (fonte, arquivo, linha_origem, motivo, data, valor_original)
        SELECT stg.fn_utf8(fonte), stg.fn_utf8(arquivo), TRY_CONVERT(int, NULLIF(linha_origem, '')), stg.fn_utf8(motivo), TRY_CONVERT(date, NULLIF(data, ''), 23), stg.fn_utf8(valor_original)
        FROM stg.Rejeitados;
    COMMIT TRANSACTION;

    SELECT * FROM dw.vw_conf_carga ORDER BY tabela;
END;
GO

-- Conferência da carga: linhas no stg (= linhas do CSV sem o cabeçalho) × linhas no dw.
CREATE OR ALTER VIEW dw.vw_conf_carga
AS
SELECT 'Dim_Calendario' AS tabela, (SELECT COUNT(*) FROM stg.Dim_Calendario) AS linhas_csv, (SELECT COUNT(*) FROM dw.Dim_Calendario) AS linhas_dw
UNION ALL SELECT 'Dim_Grupo', (SELECT COUNT(*) FROM stg.Dim_Grupo), (SELECT COUNT(*) FROM dw.Dim_Grupo)
UNION ALL SELECT 'Dim_Transporte', (SELECT COUNT(*) FROM stg.Dim_Transporte), (SELECT COUNT(*) FROM dw.Dim_Transporte)
UNION ALL SELECT 'Fato_Transporte', (SELECT COUNT(*) FROM stg.Fato_Transporte), (SELECT COUNT(*) FROM dw.Fato_Transporte)
UNION ALL SELECT 'Fato_Referencia_Mensal', (SELECT COUNT(*) FROM stg.Fato_Referencia_Mensal), (SELECT COUNT(*) FROM dw.Fato_Referencia_Mensal)
UNION ALL SELECT 'Dim_Horario', (SELECT COUNT(*) FROM stg.Dim_Horario), (SELECT COUNT(*) FROM dw.Dim_Horario)
UNION ALL SELECT 'Fato_Clima_Horario', (SELECT COUNT(*) FROM stg.Fato_Clima_Horario), (SELECT COUNT(*) FROM dw.Fato_Clima_Horario)
UNION ALL SELECT 'Rejeitados', (SELECT COUNT(*) FROM stg.Rejeitados), (SELECT COUNT(*) FROM dw.Rejeitados);
GO
