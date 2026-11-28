-- 01_ddl.sql
-- Modelo dimensional da Etapa 3 no SQL Server: dw.Dim_*, dw.Fato_*, dw.Rejeitados e as tabelas stg.* com as mesmas
-- colunas, na ordem dos CSVs exportados pela macro ExportarParaCarga (E4.5), todas como texto.
-- Idempotente: apaga na ordem das chaves (fatos antes das dimensões) e recria.
USE cheiU;
GO
DROP TABLE IF EXISTS dw.Fato_Transporte;
DROP TABLE IF EXISTS dw.Fato_Clima_Horario;
DROP TABLE IF EXISTS dw.Fato_Referencia_Mensal;
DROP TABLE IF EXISTS dw.Rejeitados;
DROP TABLE IF EXISTS dw.Dim_Transporte;
DROP TABLE IF EXISTS dw.Dim_Grupo;
DROP TABLE IF EXISTS dw.Dim_Calendario;
DROP TABLE IF EXISTS dw.Dim_Horario;
DROP TABLE IF EXISTS stg.Fato_Transporte;
DROP TABLE IF EXISTS stg.Fato_Clima_Horario;
DROP TABLE IF EXISTS stg.Dim_Horario;
DROP TABLE IF EXISTS stg.Fato_Referencia_Mensal;
DROP TABLE IF EXISTS stg.Rejeitados;
DROP TABLE IF EXISTS stg.Dim_Transporte;
DROP TABLE IF EXISTS stg.Dim_Grupo;
DROP TABLE IF EXISTS stg.Dim_Calendario;
GO

-- ===== dw: tipado =====
CREATE TABLE dw.Dim_Calendario (
    data          date          NOT NULL CONSTRAINT PK_Dim_Calendario PRIMARY KEY,
    feriado_nome  nvarchar(60)  NULL,
    fonte_feriado nvarchar(40)  NULL,
    ano           smallint      NOT NULL,
    mes           tinyint       NOT NULL CHECK (mes BETWEEN 1 AND 12),
    nome_mes      nvarchar(15)  NOT NULL,
    mes_rotulo    nvarchar(20)  NOT NULL,
    mes_inicio    date          NOT NULL,
    dia           tinyint       NOT NULL,
    dia_semana    tinyint       NOT NULL CHECK (dia_semana BETWEEN 1 AND 7),
    nome_dia      nvarchar(15)  NOT NULL,
    semana_ano    tinyint       NOT NULL,
    tipo_dia      nvarchar(10)  NOT NULL CHECK (tipo_dia IN (N'Útil', N'Sábado', N'Domingo', N'Feriado'))
);
CREATE TABLE dw.Dim_Horario (
    hora           tinyint      NOT NULL CONSTRAINT PK_Dim_Horario PRIMARY KEY CHECK (hora BETWEEN 0 AND 23),
    hora_rotulo    nvarchar(5)  NOT NULL,
    periodo        nvarchar(15) NOT NULL,
    ordem_periodo  tinyint      NOT NULL
);
CREATE TABLE dw.Dim_Grupo (
    grupo          nvarchar(40) NOT NULL CONSTRAINT PK_Dim_Grupo PRIMARY KEY,
    modalidade     nvarchar(10) NOT NULL,
    ordem          tinyint      NOT NULL,
    grupo_oficial  bit          NOT NULL
);
CREATE TABLE dw.Dim_Transporte (
    id_linha           nvarchar(20)  NOT NULL CONSTRAINT PK_Dim_Transporte PRIMARY KEY,
    codigo_linha       nvarchar(12)  NOT NULL,
    nome_linha         nvarchar(80)  NULL,
    modalidade         nvarchar(10)  NOT NULL CHECK (modalidade IN (N'Ônibus', N'Metrô', N'Trem')),
    operador           nvarchar(20)  NOT NULL,
    grupo              nvarchar(40)  NOT NULL CONSTRAINT FK_Dim_Transporte_Grupo REFERENCES dw.Dim_Grupo (grupo),
    lote               nvarchar(10)  NULL,
    primeiro_dia       date          NULL,
    ultimo_dia         date          NULL,
    dias_com_operacao  smallint      NULL,
    grupos_no_ano      tinyint       NULL,
    linha_rotulo       nvarchar(100) NOT NULL
);
CREATE INDEX IX_Dim_Transporte_grupo ON dw.Dim_Transporte (grupo);
CREATE TABLE dw.Fato_Transporte (
    data          date         NOT NULL CONSTRAINT FK_Fato_Transporte_Calendario REFERENCES dw.Dim_Calendario (data),
    id_linha      nvarchar(20) NOT NULL CONSTRAINT FK_Fato_Transporte_Transporte REFERENCES dw.Dim_Transporte (id_linha),
    modalidade    nvarchar(10) NOT NULL,
    passageiros   bigint       NOT NULL CHECK (passageiros >= 0),
    pagantes      bigint       NULL,
    integracao    bigint       NULL,
    gratuidades   bigint       NULL,
    tipo_metrica  nvarchar(20) NOT NULL,
    origem_dado   nvarchar(10) NOT NULL CHECK (origem_dado IN ('real', 'estimado', 'simulado')),
    CONSTRAINT PK_Fato_Transporte PRIMARY KEY (data, id_linha)
);
CREATE INDEX IX_Fato_Transporte_id_linha ON dw.Fato_Transporte (id_linha);
CREATE TABLE dw.Fato_Referencia_Mensal (
    mes_inicio             date          NOT NULL CONSTRAINT FK_Fato_Referencia_Calendario REFERENCES dw.Dim_Calendario (data),
    grupo                  nvarchar(40)  NOT NULL CONSTRAINT FK_Fato_Referencia_Grupo REFERENCES dw.Dim_Grupo (grupo),
    passageiros_publicado  bigint        NOT NULL,
    origem_dado            nvarchar(10)  NOT NULL CHECK (origem_dado IN ('real', 'estimado', 'simulado')),
    fonte                  nvarchar(80)  NOT NULL,
    CONSTRAINT PK_Fato_Referencia_Mensal PRIMARY KEY (mes_inicio, grupo)
);
CREATE INDEX IX_Fato_Referencia_grupo ON dw.Fato_Referencia_Mensal (grupo);
CREATE TABLE dw.Fato_Clima_Horario (
    data             date          NOT NULL CONSTRAINT FK_Fato_Clima_Calendario REFERENCES dw.Dim_Calendario (data),
    hora             tinyint       NOT NULL CONSTRAINT FK_Fato_Clima_Horario REFERENCES dw.Dim_Horario (hora),
    temperatura_c    decimal(5, 1) NOT NULL,
    precipitacao_mm  decimal(6, 1) NOT NULL CHECK (precipitacao_mm >= 0),
    chovendo         bit           NOT NULL,
    origem_dado      nvarchar(10)  NOT NULL CHECK (origem_dado IN ('real', 'estimado', 'simulado')),
    CONSTRAINT PK_Fato_Clima_Horario PRIMARY KEY (data, hora)
);
CREATE INDEX IX_Fato_Clima_Horario_hora ON dw.Fato_Clima_Horario (hora);
CREATE TABLE dw.Rejeitados (
    id_rejeitado    int IDENTITY(1, 1) NOT NULL CONSTRAINT PK_Rejeitados PRIMARY KEY,
    fonte           nvarchar(40)  NOT NULL,
    arquivo         nvarchar(120) NOT NULL,
    linha_origem    int           NULL,
    motivo          nvarchar(120) NOT NULL,
    data            date          NULL,
    valor_original  nvarchar(400) NULL
);
GO

-- ===== stg: texto, na ordem das colunas do CSV =====
-- varchar com a collation UTF-8 do banco: o BULK INSERT do Linux não aceita CODEPAGE e grava os bytes UTF-8 como vieram.
CREATE TABLE stg.Dim_Calendario (data varchar(30), feriado_nome varchar(200), fonte_feriado varchar(200), ano varchar(30), mes varchar(30), nome_mes varchar(200),
    mes_rotulo varchar(200), mes_inicio varchar(30), dia varchar(30), dia_semana varchar(30), nome_dia varchar(200), semana_ano varchar(30),
    tipo_dia varchar(200));
CREATE TABLE stg.Dim_Grupo (grupo varchar(200), modalidade varchar(200), ordem varchar(30), grupo_oficial varchar(30));
CREATE TABLE stg.Dim_Transporte (id_linha varchar(200), codigo_linha varchar(200), nome_linha varchar(400), modalidade varchar(200),
    operador varchar(200), grupo varchar(200), lote varchar(200), primeiro_dia varchar(30), ultimo_dia varchar(30),
    dias_com_operacao varchar(30), grupos_no_ano varchar(30), linha_rotulo varchar(400));
CREATE TABLE stg.Fato_Transporte (data varchar(30), id_linha varchar(200), modalidade varchar(200), passageiros varchar(30),
    pagantes varchar(30), integracao varchar(30), gratuidades varchar(30), tipo_metrica varchar(200), origem_dado varchar(200));
CREATE TABLE stg.Fato_Referencia_Mensal (mes_inicio varchar(30), grupo varchar(200), passageiros_publicado varchar(30),
    origem_dado varchar(200), fonte varchar(400));
CREATE TABLE stg.Dim_Horario (hora varchar(30), hora_rotulo varchar(30), periodo varchar(60), ordem_periodo varchar(30));
CREATE TABLE stg.Fato_Clima_Horario (data varchar(30), hora varchar(30), temperatura_c varchar(30), precipitacao_mm varchar(30),
    chovendo varchar(30), origem_dado varchar(60));
CREATE TABLE stg.Rejeitados (fonte varchar(200), arquivo varchar(400), linha_origem varchar(30), motivo varchar(400), data varchar(30),
    valor_original varchar(8000));
GO
SELECT s.name + '.' + t.name AS tabela FROM sys.tables t JOIN sys.schemas s ON s.schema_id = t.schema_id ORDER BY s.name, t.name;
GO
