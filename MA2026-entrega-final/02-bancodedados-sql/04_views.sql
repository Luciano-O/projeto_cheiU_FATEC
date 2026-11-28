-- 04_views.sql
-- Views dw.vw_* que o Power BI (Etapa 7) consome. O Power BI lê só estas views, nunca as tabelas.
USE cheiU;
GO
CREATE OR ALTER VIEW dw.vw_linhas AS
SELECT t.id_linha, t.codigo_linha, t.nome_linha, t.linha_rotulo, t.modalidade, t.operador, t.grupo, g.grupo_oficial, g.ordem AS ordem_grupo, t.lote
FROM dw.Dim_Transporte t
JOIN dw.Dim_Grupo g ON g.grupo = t.grupo;
GO
CREATE OR ALTER VIEW dw.vw_grupos AS
SELECT grupo, modalidade, ordem, grupo_oficial FROM dw.Dim_Grupo;
GO
CREATE OR ALTER VIEW dw.vw_demanda_diaria AS
SELECT f.data, f.id_linha, f.modalidade, f.passageiros, f.pagantes, f.integracao, f.gratuidades, f.tipo_metrica, f.origem_dado
FROM dw.Fato_Transporte f;
GO
CREATE OR ALTER VIEW dw.vw_referencia_mensal AS
SELECT mes_inicio, grupo, passageiros_publicado, origem_dado, fonte FROM dw.Fato_Referencia_Mensal;
GO
CREATE OR ALTER VIEW dw.vw_demanda_mensal_modalidade AS
SELECT c.ano, c.mes, c.mes_rotulo, c.mes_inicio, f.modalidade, SUM(f.passageiros) AS passageiros,
       COUNT(DISTINCT f.data) AS dias, SUM(f.passageiros) / COUNT(DISTINCT f.data) AS media_diaria
FROM dw.Fato_Transporte f
JOIN dw.Dim_Calendario c ON c.data = f.data
GROUP BY c.ano, c.mes, c.mes_rotulo, c.mes_inicio, f.modalidade;
GO
CREATE OR ALTER VIEW dw.vw_kpis AS
SELECT
    (SELECT SUM(passageiros) FROM dw.Fato_Transporte) AS total_passageiros,
    (SELECT SUM(passageiros) FROM dw.Fato_Transporte WHERE modalidade = N'Ônibus') AS passageiros_onibus,
    (SELECT SUM(passageiros) FROM dw.Fato_Transporte WHERE modalidade = N'Trem') AS passageiros_trem,
    (SELECT COUNT(*) FROM dw.Fato_Transporte) AS linhas_fato,
    (SELECT SUM(passageiros_publicado) FROM dw.Fato_Referencia_Mensal) AS passageiros_publicados,
    (SELECT COUNT(*) FROM dw.Rejeitados) AS linhas_rejeitadas;
GO
CREATE OR ALTER VIEW dw.vw_horario AS
SELECT hora, hora_rotulo, periodo, ordem_periodo FROM dw.Dim_Horario;
GO
CREATE OR ALTER VIEW dw.vw_clima_horario AS
SELECT data, hora, temperatura_c, precipitacao_mm, chovendo, origem_dado FROM dw.Fato_Clima_Horario;
GO
CREATE OR ALTER VIEW dw.vw_clima_diario AS
SELECT data, SUM(precipitacao_mm) AS chuva_mm, AVG(temperatura_c) AS temperatura_media_c, SUM(CAST(chovendo AS int)) AS horas_com_chuva,
       CASE WHEN SUM(precipitacao_mm) >= 5 THEN N'com chuva' WHEN SUM(precipitacao_mm) < 1 THEN N'seco' ELSE N'chuva fraca' END AS faixa_chuva
FROM dw.Fato_Clima_Horario
GROUP BY data;
GO
-- Calendário com a chuva do dia (Etapa 6), para o painel filtrar a demanda pela faixa de chuva.
CREATE OR ALTER VIEW dw.vw_calendario AS
SELECT c.data, c.ano, c.mes, c.nome_mes, c.mes_rotulo, c.mes_inicio, c.dia, c.dia_semana, c.nome_dia, c.semana_ano, c.tipo_dia,
       c.feriado_nome, c.fonte_feriado, cl.chuva_mm, cl.faixa_chuva
FROM dw.Dim_Calendario c
LEFT JOIN dw.vw_clima_diario cl ON cl.data = c.data;
GO
SELECT name AS view_criada FROM sys.views WHERE SCHEMA_NAME(schema_id) = N'dw' ORDER BY name;
GO
