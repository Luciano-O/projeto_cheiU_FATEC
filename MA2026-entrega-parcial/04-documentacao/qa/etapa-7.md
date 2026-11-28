# QA da Etapa 7 — Power BI

Conferência do painel `MA2026-entrega-final/04-powerbi-dashboard/cheiU_dashboard.pbix`, gerado a partir do projeto `.pbip`. Responsável pelo QA no plano: Maryele Naara Freitas Meira. Feito em 28/11/2026, com os commits na conta do Luciano (decisão `0015`).

| # | Item | Resultado esperado | Como verificar | Obtido | Status |
|---|---|---|---|---|---|
| 1 | Conexão | modelo importa as views `dw.vw_*` do SQL Server | Home › Refresh no Desktop | 7 tabelas carregadas, sem erro | Concluído |
| 2 | Relações | as da Etapa 3, com a dimensão de calendário marcada | `relationships.tmdl` | 7 relações; `Calendario` com `dataCategory: Time` e hierarquia Ano › Mês › Dia | Concluído |
| 3 | Medidas | migradas da Etapa 3 e da Etapa 6, em pastas por tema | `tables/*.tmdl` | 19 medidas em 4 pastas (Demanda, Linhas, Publicado, Clima) | Concluído |
| 4 | KPIs × SQL | diferença 0 | `scripts/conferir_kpis.ps1` | 8 KPIs, diferença 0 (`evidencias/conferencia_kpis.txt`) | Concluído |
| 5 | Títulos em pergunta | todos os visuais de dados | PDF exportado | 15 de 15 | Concluído |
| 6 | Visuais por página | no máximo 6 | PDF exportado | 6, 5, 5, 6 e 1 (sem contar a barra de navegação) | Concluído |
| 7 | Filtros sincronizados | mês e modalidade iguais em todas as páginas | `syncGroup` nos `visual.json` das segmentações | grupos `mes` e `modalidade` | Concluído |
| 8 | Dica de ferramenta | KPIs principais no tooltip | campo `Tooltips` dos gráficos | Média diária e % estimado em 7 gráficos | Concluído |
| 9 | Navegação | todas as páginas alcançáveis por botão | navegador de páginas no rodapé | 5 de 5 | Concluído |
| 10 | Desempenho | nenhum visual acima de 2 s | consultas DAX dos visuais por ADOMD | máximo 71 ms (`evidencias/desempenho_consultas.txt`) | Concluído |
| 11 | Sobre os dados | fontes, premissas, `origem_dado` e limitações | página 5 | presente | Concluído |
| 12 | Tema único | `tema-cheiU.json` aplicado | `report.json` | aplicado | Concluído |

Reconciliação Power BI × SQL (`05_kpis.sql`):

| KPI | Power BI | SQL | Diferença |
|---|---|---|---|
| Total de passageiros | 2.564.533.459 | 2.564.533.459 | 0 |
| Passageiros de ônibus | 2.125.608.791 | 2.125.608.791 | 0 |
| Linhas da fato | 463.876 | 463.876 | 0 |
| Passageiros publicados | 2.160.850.434 | 2.160.850.434 | 0 |
| Média de dia útil | 8.328.609 | 8.328.609 | 0 |
| Média de fim de semana | 4.225.515 | 4.225.515 | 0 |
| Média de dia útil com chuva | 8.069.711 | 8.069.711 | 0 |
| Média de dia útil seco | 8.496.127 | 8.496.127 | 0 |

Fora do painel por falta de dado (Metrô e Pesquisa OD 2023, E1.3): curva horária, pico × fora do pico, lotação, mapa de estações, matriz por região e a página "Alternativas de percurso". A página "Sobre os dados" registra isso.

Observação: o Power BI Desktop desta máquina está em inglês, então os números saem no formato americano (`2,564,533,459`). Num Desktop em português, o mesmo arquivo mostra `2.564.533.459`.
