# 02-bancodedados-sql — Etapa 5 (SQL)

SQL Server 2022 Express em Docker como fonte da verdade (decisão `0002`): modelo dimensional (`dw`), área de carga (`stg`), carga a partir dos CSVs exportados pela macro da Etapa 4, 13 consultas analíticas e as views que o Power BI lê.

Plano: `docs/plano/etapa-5-sql.md`. QA: `MA2026-entrega-parcial/04-documentacao/qa/etapa-5.md`.

## Do zero

1. Copie `.env.example` para `.env` na raiz e preencha `MSSQL_SA_PASSWORD` (8+ caracteres, maiúscula, minúscula, número e símbolo).
2. Suba o container nesta pasta e espere ficar *healthy*:

```powershell
docker compose --env-file ../../.env up -d
```

3. Gere os CSVs de carga: botão **Exportar para SQL** do `01-vba/cheiU_04_VBA.xlsm` (grava em `carga/`, fora do Git).
4. Rode os scripts na ordem (o container monta esta pasta em `/scripts` e `carga/` em `/carga`). Use `-f 65001`: os arquivos são UTF-8.

```powershell
docker exec cheiu-sql bash -c '/opt/mssql-tools18/bin/sqlcmd -C -f 65001 -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -b -i /scripts/00_criar_banco.sql -i /scripts/01_ddl.sql -i /scripts/02_carga.sql -i /scripts/04_views.sql'
```

```powershell
docker exec cheiu-sql bash -c '/opt/mssql-tools18/bin/sqlcmd -C -f 65001 -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -d cheiU -Q "EXEC dw.usp_carregar_tudo"'
```

5. Consultas: `-i /scripts/03_consultas.sql`. KPIs da reconciliação: `-i /scripts/05_kpis.sql`.

No Git Bash, ponha `MSYS_NO_PATHCONV=1` antes do comando, senão `/opt/...` vira um caminho do Windows.

## Scripts

| Arquivo | Conteúdo |
|---|---|
| `docker-compose.yml` | imagem `mcr.microsoft.com/mssql/server:2022-latest`, Express, porta 1433, volume nomeado, `carga/` e a pasta montados só para leitura, *healthcheck* |
| `00_criar_banco.sql` | banco `cheiU` (collation UTF-8) e schemas `stg` e `dw` |
| `01_ddl.sql` | 8 tabelas `dw` com PK, FK, `CHECK` (`origem_dado`, `tipo_dia`, `modalidade`) e índices nas FKs; 8 tabelas `stg` em texto; idempotente |
| `02_carga.sql` | `stg.fn_utf8`, `dw.usp_carregar_tudo` (TRUNCATE do stg, `BULK INSERT`, conversão e gravação no `dw` numa transação) e `dw.vw_conf_carga` |
| `03_consultas.sql` | 13 consultas, cada uma com a pergunta que responde: `GROUP BY`, CTEs, `RANK`, `LAG`, `ROW_NUMBER`, `SUM() OVER` |
| `04_views.sql` | 10 views `dw.vw_*` para o Power BI |
| `05_kpis.sql` | KPIs no formato `kpi|valor` para a reconciliação com o DAX |
| `scripts/reconciliar_sql_dax.ps1` | compara os KPIs do SQL com as medidas do modelo da Etapa 4 |

## Pegadinha: UTF-8 no `BULK INSERT` do Linux

O SQL Server no Linux não aceita `CODEPAGE` no `BULK INSERT` e lê o CSV como OEM 437: "Útil" chega como "├Ütil". Como a 437 cobre os 256 bytes, a conversão se desfaz. `stg.fn_utf8` volta o texto para os bytes 437 e lê esses bytes como UTF-8, e toda coluna de texto passa por ela na carga.

## Resultado (28/11/2026)

| Verificação | Resultado |
|---|---|
| Container | *healthy*; `SELECT @@VERSION` responde (SQL Server 2022 RTM-CU28) |
| DDL duas vezes seguidas | sem erro |
| Carga duas vezes seguidas | mesmo resultado; linhas iguais em CSV, `stg` e `dw` nas 8 tabelas (`Fato_Transporte` 463.876; `Fato_Clima_Horario` 8.784) |
| Consultas e views | 13 consultas e 10 views sem erro; saída em `evidencias/resultado_03_consultas.txt` |
| SQL × DAX | 8 KPIs iguais, diferença 0 (`qa/etapa-5.md`) |

Demanda por hora, lotação e alternativas de percurso dependem do perfil horário da OD 2023 e da oferta (E2.6–E2.8), que ainda não têm dados.
