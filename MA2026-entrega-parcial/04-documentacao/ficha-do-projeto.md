# Ficha do projeto — cheiU (Grupo 10, Mobilidade Urbana)

| Campo | Conteúdo |
|---|---|
| **Contexto** | São Paulo transporta ~2,2 bilhões de passageiros por ano só nos ônibus municipais (SPTrans, 2024), mas os dados públicos saem em centenas de planilhas diárias, com layouts que mudam ao longo do ano. Sem consolidar e padronizar, não dá para comparar linhas, grupos, dias e modalidades. |
| **Pergunta central** | Como os dados do transporte público de São Paulo revelam padrões de demanda, lotação e utilização e apoiam a comparação de alternativas de deslocamento? |
| **Fontes de dados** | SPTrans: passageiros transportados por dia e linha (366 arquivos de 2024) e totais mensais publicados por grupo. Previstas: Metrô (entradas por estação), CPTM (embarcados por estação), Pesquisa Origem-Destino 2023 (perfil horário e cadeias modais) e GTFS SPTrans (oferta). |
| **Dados utilizados** | 2024 inteiro, ~480 mil registros dia × linha × empresa, ~1.300 linhas de ônibus. Cada registro de fato leva `origem_dado` (`real`, `estimado` ou `simulado`). |
| **Indicadores / KPIs** | Total de passageiros (quanto o sistema transportou?); média diária (qual o volume típico de um dia?); média em dia útil e no fim de semana, e a razão entre elas (quanto a demanda cai no fim de semana?); participação da linha e do grupo (quem concentra a demanda?); variação sobre o mês anterior (a demanda está subindo?); ranking das linhas (quais são as mais usadas?); diferença sobre o total publicado (os dados tratados batem com o oficial?). Depois da N1: demanda estimada por hora, lotação simulada e alternativas por corredor. |
| **Dados externos / API** | Open-Meteo (clima horário de SP, para cruzar demanda com chuva) e BrasilAPI (feriados), via Power Query. API Olho Vivo (SPTrans) para linhas e posição dos ônibus, via VBA. |
| **Automação (VBA)** | Macro de resumo diário: pede uma data, valida, monta a aba `Resumo_dd-mm-aaaa` com os KPIs do dia e o top 3 de linhas, pinta o que estiver abaixo da média e exporta o PDF. |
| **Banco de dados / SQL** | SQL Server em Docker: DDL do modelo dimensional, carga dos CSVs tratados e consultas de análise (ranking, realizado × publicado com JOIN, demanda em dias com e sem chuva com CASE, linhas acima da média com HAVING). |
| **Resultado no Power BI** | Três páginas: visão geral da demanda, linhas e grupos, padrões por dia e horário. Títulos em forma de pergunta, filtros sincronizados e tooltip com KPIs. |

## Correspondência com o projeto modelo (CaféData → cheiU)

| CaféData | cheiU |
|---|---|
| Fato de vendas (`fVendas`) | `Fato_Transporte`: passageiros por dia e linha |
| Metas mensais (`fMetas`, ligada por `Mes_Inicio`) | `Fato_Referencia_Mensal`: total publicado pela SPTrans por mês e grupo |
| Dimensão produto | `Dim_Transporte` (linha) |
| Dimensão filial | `Dim_Grupo` (grupo SPTrans); depois, região e estação |
| Dimensão calendário | `Dim_Calendario` (2024, com feriados e tipo de dia) |
| Ticket médio, vendas abaixo da meta | média diária por linha, diferença sobre o publicado; depois, atraso médio em dias com e sem chuva |
| API de clima | Open-Meteo (clima horário) e BrasilAPI (feriados) |
