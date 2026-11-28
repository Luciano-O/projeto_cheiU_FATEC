# QA da Etapa 5 — SQL

Conferência do banco `cheiU` no SQL Server 2022 Express em Docker (`MA2026-entrega-final/02-bancodedados-sql`). Responsável pelo QA no plano: Maryele Naara Freitas Meira. Feito por script em 28/11/2026, com os commits na conta do Luciano (decisão `0015`).

| # | Item | Resultado esperado | Como verificar | Obtido | Status |
|---|---|---|---|---|---|
| 1 | Container | *healthy*, responde | `docker inspect`, `SELECT @@VERSION` | *healthy*; SQL Server 2022 RTM-CU28 | Concluído |
| 2 | DDL idempotente | roda duas vezes sem erro | `01_ddl.sql` duas vezes | sem erro | Concluído |
| 3 | Chaves e restrições | PK, FK, `CHECK` de `origem_dado` | `01_ddl.sql` | 8 PKs, 8 FKs, `CHECK` em `origem_dado`, `tipo_dia`, `modalidade`, `hora` | Concluído |
| 4 | Carga | linhas iguais em CSV, `stg` e `dw` | `EXEC dw.usp_carregar_tudo` (`dw.vw_conf_carga`) | 8 tabelas iguais; `Fato_Transporte` 463.876 | Concluído |
| 5 | Carga repetida | mesmo resultado | rodar a carga duas vezes | igual | Concluído |
| 6 | Acentos | texto igual ao do modelo | `stg.fn_utf8` (o `BULK INSERT` do Linux lê como OEM 437) | "Útil", "Ônibus", "Sábado" corretos | Concluído |
| 7 | Consultas analíticas | ≥ 4 (Parcial 2), sem erro | `03_consultas.sql` | 13 consultas; `evidencias/resultado_03_consultas.txt` | Concluído |
| 8 | Views para o Power BI | sem erro | `04_views.sql` | 10 views `dw.vw_*` | Concluído |
| 9 | SQL × DAX | KPIs iguais | `scripts/reconciliar_sql_dax.ps1` | 8 KPIs, diferença 0 (tabela abaixo) | Concluído |

Reconciliação SQL × DAX (modelo da Etapa 4):

| KPI | DAX | SQL | Diferença |
|---|---|---|---|
| Total de passageiros | 2.564.533.459 | 2.564.533.459 | 0 |
| Passageiros de ônibus | 2.125.608.791 | 2.125.608.791 | 0 |
| Linhas da fato | 463.876 | 463.876 | 0 |
| Passageiros publicados | 2.160.850.434 | 2.160.850.434 | 0 |
| Média de dia útil | 8.328.609 | 8.328.609 | 0 |
| Média de fim de semana | 4.225.515 | 4.225.515 | 0 |
| Média de dia útil com chuva (5 mm ou mais) | 8.069.711 | 8.069.711 | 0 |
| Média de dia útil seco (menos de 1 mm) | 8.496.127 | 8.496.127 | 0 |
