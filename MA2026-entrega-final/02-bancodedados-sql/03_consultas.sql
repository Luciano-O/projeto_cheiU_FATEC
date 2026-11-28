-- 03_consultas.sql
-- Consultas analíticas (DML) sobre o dw. Cada uma diz a pergunta que responde.
-- Demanda por hora, lotação e alternativas de percurso dependem do perfil horário da OD 2023 e da oferta
-- (E2.6–E2.8), ainda sem dados. O clima da Etapa 6 entra nas consultas 12 e 13.
USE cheiU;
GO

-- 1. Quantos passageiros cada modalidade teve em cada mês de 2024?
SELECT c.mes_rotulo, f.modalidade, SUM(f.passageiros) AS passageiros
FROM dw.Fato_Transporte f
JOIN dw.Dim_Calendario c ON c.data = f.data
GROUP BY c.mes, c.mes_rotulo, f.modalidade
ORDER BY c.mes, f.modalidade;
GO

-- 2. Qual é a média diária por tipo de dia (útil, sábado, domingo, feriado) em cada modalidade?
WITH dia AS (
    SELECT f.data, f.modalidade, SUM(f.passageiros) AS passageiros
    FROM dw.Fato_Transporte f
    GROUP BY f.data, f.modalidade
)
SELECT d.modalidade, c.tipo_dia, COUNT(*) AS dias, AVG(CAST(d.passageiros AS decimal(18, 0))) AS media_diaria
FROM dia d
JOIN dw.Dim_Calendario c ON c.data = d.data
GROUP BY d.modalidade, c.tipo_dia
ORDER BY d.modalidade, media_diaria DESC;
GO

-- 3. Quanto da demanda de um dia útil sobra no fim de semana (razão fim de semana ÷ útil)?
WITH dia AS (
    SELECT f.data, SUM(f.passageiros) AS passageiros FROM dw.Fato_Transporte f GROUP BY f.data
)
SELECT AVG(CASE WHEN c.tipo_dia = N'Útil' THEN CAST(d.passageiros AS float) END) AS media_util,
       AVG(CASE WHEN c.tipo_dia IN (N'Sábado', N'Domingo') THEN CAST(d.passageiros AS float) END) AS media_fim_de_semana,
       AVG(CASE WHEN c.tipo_dia IN (N'Sábado', N'Domingo') THEN CAST(d.passageiros AS float) END)
         / AVG(CASE WHEN c.tipo_dia = N'Útil' THEN CAST(d.passageiros AS float) END) AS razao_fim_de_semana_util
FROM dia d
JOIN dw.Dim_Calendario c ON c.data = d.data;
GO

-- 4. Quais são as 10 linhas mais usadas no ano, com o ranking dentro da modalidade?
WITH linha AS (
    SELECT t.linha_rotulo, t.modalidade, SUM(f.passageiros) AS passageiros
    FROM dw.Fato_Transporte f
    JOIN dw.Dim_Transporte t ON t.id_linha = f.id_linha
    GROUP BY t.linha_rotulo, t.modalidade
)
SELECT TOP (10) linha_rotulo, modalidade, passageiros,
       RANK() OVER (ORDER BY passageiros DESC) AS ranking_geral,
       RANK() OVER (PARTITION BY modalidade ORDER BY passageiros DESC) AS ranking_na_modalidade
FROM linha
ORDER BY passageiros DESC;
GO

-- 5. A demanda subiu ou caiu em relação ao mês anterior (variação mensal com LAG)?
WITH mes AS (
    SELECT c.mes, c.mes_rotulo, SUM(f.passageiros) AS passageiros
    FROM dw.Fato_Transporte f
    JOIN dw.Dim_Calendario c ON c.data = f.data
    GROUP BY c.mes, c.mes_rotulo
)
SELECT mes_rotulo, passageiros, LAG(passageiros) OVER (ORDER BY mes) AS mes_anterior,
       CAST(passageiros - LAG(passageiros) OVER (ORDER BY mes) AS float) / LAG(passageiros) OVER (ORDER BY mes) AS variacao
FROM mes
ORDER BY mes;
GO

-- 6. Os dados tratados da SPTrans batem com o total publicado (só ônibus dos três grupos oficiais)?
WITH calculado AS (
    SELECT c.mes_inicio, SUM(f.passageiros) AS passageiros
    FROM dw.Fato_Transporte f
    JOIN dw.Dim_Calendario c ON c.data = f.data
    JOIN dw.Dim_Transporte t ON t.id_linha = f.id_linha
    JOIN dw.Dim_Grupo g ON g.grupo = t.grupo
    WHERE g.grupo_oficial = 1
    GROUP BY c.mes_inicio
), publicado AS (
    SELECT mes_inicio, SUM(passageiros_publicado) AS passageiros FROM dw.Fato_Referencia_Mensal GROUP BY mes_inicio
)
SELECT p.mes_inicio, c.passageiros AS calculado, p.passageiros AS publicado,
       CAST(c.passageiros - p.passageiros AS float) / p.passageiros AS diferenca
FROM publicado p
LEFT JOIN calculado c ON c.mes_inicio = p.mes_inicio
ORDER BY p.mes_inicio;
GO

-- 7. Quanto cada grupo representa do total do ano?
SELECT g.grupo, g.modalidade, SUM(f.passageiros) AS passageiros,
       CAST(SUM(f.passageiros) AS float) / SUM(SUM(f.passageiros)) OVER () AS participacao
FROM dw.Fato_Transporte f
JOIN dw.Dim_Transporte t ON t.id_linha = f.id_linha
JOIN dw.Dim_Grupo g ON g.grupo = t.grupo
GROUP BY g.grupo, g.modalidade, g.ordem
ORDER BY passageiros DESC;
GO

-- 8. Quais foram os 5 dias de maior demanda e em que dia da semana caíram?
SELECT TOP (5) c.data, c.nome_dia, c.tipo_dia, SUM(f.passageiros) AS passageiros
FROM dw.Fato_Transporte f
JOIN dw.Dim_Calendario c ON c.data = f.data
GROUP BY c.data, c.nome_dia, c.tipo_dia
ORDER BY passageiros DESC;
GO

-- 9. Qual é a média por dia da semana (segunda a domingo), só em dias que não são feriado?
WITH dia AS (
    SELECT f.data, SUM(f.passageiros) AS passageiros FROM dw.Fato_Transporte f GROUP BY f.data
)
SELECT c.dia_semana, c.nome_dia, COUNT(*) AS dias, AVG(CAST(d.passageiros AS decimal(18, 0))) AS media
FROM dia d
JOIN dw.Dim_Calendario c ON c.data = d.data
WHERE c.tipo_dia <> N'Feriado'
GROUP BY c.dia_semana, c.nome_dia
ORDER BY c.dia_semana;
GO

-- 10. Como se divide a demanda por origem do dado (real, estimado, simulado)?
SELECT f.modalidade, f.origem_dado, COUNT(*) AS linhas, SUM(f.passageiros) AS passageiros
FROM dw.Fato_Transporte f
GROUP BY f.modalidade, f.origem_dado
ORDER BY f.modalidade, f.origem_dado;
GO

-- 11. Quais linhas de ônibus mais perderam e mais ganharam passageiros do 1º para o 2º semestre?
WITH sem AS (
    SELECT t.linha_rotulo,
           SUM(CASE WHEN MONTH(f.data) <= 6 THEN f.passageiros ELSE 0 END) AS s1,
           SUM(CASE WHEN MONTH(f.data) > 6 THEN f.passageiros ELSE 0 END) AS s2
    FROM dw.Fato_Transporte f
    JOIN dw.Dim_Transporte t ON t.id_linha = f.id_linha
    WHERE t.modalidade = N'Ônibus'
    GROUP BY t.linha_rotulo
    HAVING SUM(CASE WHEN MONTH(f.data) <= 6 THEN f.passageiros ELSE 0 END) >= 1000000
), ordenado AS (
    SELECT linha_rotulo, s1, s2, CAST(s2 - s1 AS float) / s1 AS variacao,
           ROW_NUMBER() OVER (ORDER BY CAST(s2 - s1 AS float) / s1) AS pior,
           ROW_NUMBER() OVER (ORDER BY CAST(s2 - s1 AS float) / s1 DESC) AS melhor
    FROM sem
)
SELECT linha_rotulo, s1, s2, variacao FROM ordenado WHERE pior <= 5 OR melhor <= 5 ORDER BY variacao;
GO

-- 12. A chuva muda a demanda de um dia útil? (Etapa 6: clima do Open-Meteo; dia com chuva = 5 mm ou mais no dia, seco = menos de 1 mm)
WITH dia AS (
    SELECT f.data, SUM(f.passageiros) AS passageiros FROM dw.Fato_Transporte f GROUP BY f.data
), clima AS (
    SELECT data, SUM(precipitacao_mm) AS chuva_mm FROM dw.Fato_Clima_Horario GROUP BY data
)
SELECT CASE WHEN cl.chuva_mm >= 5 THEN N'com chuva (>= 5 mm)' WHEN cl.chuva_mm < 1 THEN N'seco (< 1 mm)' ELSE N'chuva fraca (1 a 5 mm)' END AS faixa,
       COUNT(*) AS dias_uteis, AVG(CAST(d.passageiros AS decimal(18, 0))) AS media_dia_util
FROM dia d
JOIN dw.Dim_Calendario c ON c.data = d.data
JOIN clima cl ON cl.data = d.data
WHERE c.tipo_dia = N'Útil'
GROUP BY CASE WHEN cl.chuva_mm >= 5 THEN N'com chuva (>= 5 mm)' WHEN cl.chuva_mm < 1 THEN N'seco (< 1 mm)' ELSE N'chuva fraca (1 a 5 mm)' END
ORDER BY media_dia_util DESC;
GO

-- 13. Em que horas do dia mais chove em São Paulo (para cruzar com o perfil horário quando ele existir)?
SELECT h.hora_rotulo, h.periodo, SUM(cl.precipitacao_mm) AS chuva_mm_ano, SUM(CAST(cl.chovendo AS int)) AS horas_com_chuva
FROM dw.Fato_Clima_Horario cl
JOIN dw.Dim_Horario h ON h.hora = cl.hora
GROUP BY h.hora, h.hora_rotulo, h.periodo
ORDER BY h.hora;
GO
