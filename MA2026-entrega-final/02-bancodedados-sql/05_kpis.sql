-- 05_kpis.sql
-- KPIs da reconciliação SQL × DAX (E5.5): uma linha por KPI, no formato "kpi|valor".
-- As mesmas definições das medidas DAX do modelo (Total de Passageiros, Passageiros de Ônibus, Média Dia Útil…).
USE cheiU;
SET NOCOUNT ON;
WITH d AS (
    SELECT f.data, SUM(CAST(f.passageiros AS float)) AS p FROM dw.Fato_Transporte f GROUP BY f.data
), cl AS (
    SELECT data, SUM(precipitacao_mm) AS mm FROM dw.Fato_Clima_Horario GROUP BY data
), k AS (
    SELECT 1 AS ordem, 'Total de Passageiros' AS kpi, (SELECT SUM(CAST(passageiros AS float)) FROM dw.Fato_Transporte) AS valor
    UNION ALL SELECT 2, 'Passageiros de Ônibus', (SELECT SUM(CAST(passageiros AS float)) FROM dw.Fato_Transporte WHERE modalidade = N'Ônibus')
    UNION ALL SELECT 3, 'Conf Linhas Fato_Transporte', (SELECT CAST(COUNT(*) AS float) FROM dw.Fato_Transporte)
    UNION ALL SELECT 4, 'Passageiros Publicados', (SELECT SUM(CAST(passageiros_publicado AS float)) FROM dw.Fato_Referencia_Mensal)
    UNION ALL SELECT 5, 'Média Dia Útil', (SELECT AVG(d.p) FROM d JOIN dw.Dim_Calendario c ON c.data = d.data WHERE c.tipo_dia = N'Útil')
    UNION ALL SELECT 6, 'Média Fim de Semana', (SELECT AVG(d.p) FROM d JOIN dw.Dim_Calendario c ON c.data = d.data WHERE c.tipo_dia IN (N'Sábado', N'Domingo'))
    UNION ALL SELECT 7, 'Média Dia Útil com Chuva', (SELECT AVG(d.p) FROM d JOIN dw.Dim_Calendario c ON c.data = d.data JOIN cl ON cl.data = d.data WHERE c.tipo_dia = N'Útil' AND cl.mm >= 5)
    UNION ALL SELECT 8, 'Média Dia Útil sem Chuva', (SELECT AVG(d.p) FROM d JOIN dw.Dim_Calendario c ON c.data = d.data JOIN cl ON cl.data = d.data WHERE c.tipo_dia = N'Útil' AND cl.mm < 1)
)
SELECT kpi + '|' + CONVERT(varchar(40), CAST(valor AS decimal(20, 4))) FROM k ORDER BY ordem;
