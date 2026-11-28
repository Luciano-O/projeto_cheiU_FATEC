# 03-api-web — Etapa 6 (APIs e dados da web)

Duas fontes externas integradas ao modelo (a Parcial 2 exige uma): feriados da **BrasilAPI**, chamada ao vivo pelo Power Query, e clima horário do **Open-Meteo**. As duas entram no modelo da Etapa 4 (`01-vba/cheiU_04_VBA.xlsm`), seguem para o SQL pela exportação da macro e chegam ao Power BI pelas views.

Plano: `docs/plano/etapa-6-api-web.md`. QA: `MA2026-entrega-parcial/04-documentacao/qa/etapa-6.md`. Decisão: `memories/decisoes/0016`.

## APIs

### BrasilAPI — feriados nacionais

| Item | Valor |
|---|---|
| Endpoint | `GET https://brasilapi.com.br/api/feriados/v1/2024` |
| Autenticação | nenhuma |
| Resposta | lista de `{date, name, type, weekday}`; exemplo em `exemplos/brasilapi_feriados_2024.json` (14 feriados) |
| Consulta | `scripts_m/api_brasilapi_feriados.pq` (`Web.Contents`, ao vivo) |
| Limite e erro | sem limite documentado; se a chamada falhar, a atualização para com erro (a lista manual da Etapa 1 fica como reserva em `Ref_Feriados`) |

Não traz os feriados locais (25/01 municipal, 09/07 estadual). `Ref_Feriados` junta a API com esses dois da lista manual, e `Conf_Feriados` (aba no `.xlsm`) explica cada diferença: 13 datas nas duas fontes, a Páscoa (31/03) só na API e os dois locais só na lista manual. O calendário passa a ter 16 feriados.

### Open-Meteo — clima horário

| Item | Valor |
|---|---|
| Endpoint | `GET https://archive-api.open-meteo.com/v1/archive?latitude=-23.55&longitude=-46.63&start_date=2024-01-01&end_date=2024-12-31&hourly=temperature_2m,precipitation,rain&timezone=America/Sao_Paulo` |
| Autenticação | nenhuma; uso não comercial gratuito |
| Resposta | `hourly.time`, `temperature_2m`, `precipitation`, `rain`, 8.784 horas sem nulos; exemplo em `exemplos/open_meteo_2024_primeiras_48h.json` |
| Aquisição | `01-excel/scripts/baixar_clima.py` grava `dados-brutos/clima/open_meteo_2024.json` e a linha no manifesto |
| Consulta | `scripts_m/api_open_meteo_clima.pq` lê o JSON salvo (`pArquivoClima`) |

Nesta máquina o `Web.Contents` do Excel falha com o Open-Meteo, embora o `curl` e o Python funcionem e a BrasilAPI funcione no próprio Power Query. Por isso a aquisição do clima é feita em Python (decisão `0004`), e a chamada direta fica documentada no `.pq`.

### Olho Vivo (SPTrans) — não feito

Exige token do DevPlace (E0.5, issue `Humano`): alguém do grupo precisa criar a conta. O módulo `modOlhoVivo` (E6.3) e o coletor (E6.4, extra) ficam para quando houver token em `.env` (`OLHOVIVO_TOKEN`).

## No modelo

| Tabela ou consulta | Conteúdo |
|---|---|
| `Fato_Clima_Horario` | data × hora: `temperatura_c`, `precipitacao_mm`, `chovendo` (≥ 0,1 mm), `origem_dado = estimado` (reanálise ERA5, não medição de estação) |
| `Dim_Horario` | hora 0–23, rótulo e período do dia |
| `Dim_Calendario` | versão da Etapa 6: feriados de `Ref_Feriados`, com a coluna `fonte_feriado` |
| Relações | `Fato_Clima_Horario[data]` → `Dim_Calendario`, `[hora]` → `Dim_Horario` |
| Medidas (`dax/medidas_clima.dax`) | Precipitação, Temperatura Média, Horas com Chuva, Média Dia Útil com Chuva (≥ 5 mm no dia), Média Dia Útil sem Chuva (< 1 mm), Efeito da Chuva % e duas de conferência |

`scripts/integrar_apis.ps1` injeta as consultas, carrega as tabelas, cria as relações e as medidas no `.xlsm`. É idempotente. Saída em `evidencias/integracao_etapa6.txt`.

## Resultado

Em 2024, um dia útil com chuva (≥ 5 mm, 50 dias) teve em média 8.069.711 passageiros, contra 8.496.127 num dia útil seco (< 1 mm, 157 dias): **−5,0%**. O número é igual no DAX e no SQL (consulta 12).
