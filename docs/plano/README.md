# Plano de implementação — cheiU

Aqui está o **como** de cada passo. O status fica no Linear; o porquê das escolhas, em `memories/decisoes/`. O que o professor exige em cada etapa (escopo, artefatos, conferências, checkpoints) está resumido em `referencia-professor.md`, com os PDFs originais em `docs/professor/`.

## Como usar

- Cada passo tem um ID (`E2.2`) e vira uma issue no Linear com título `[E2.2] …`. Para achar a issue, busque o ID no Linear.
- A numeração das etapas segue a do professor (Etapa 1 Excel … Etapa 7 Power BI). A correspondência com os IDs antigos está em `memories/decisoes/0008`.
- Cada etapa começa pelo passo `Ex.0 — Refinar o plano da etapa`: releia o arquivo da etapa à luz do que as etapas anteriores produziram e do guia do professor, e ajuste passos, saídas e aceites aqui e nas issues antes de executar.
- Cada etapa termina com a tabela de conferência do guia do professor (`04-documentacao/qa/etapa-N.md`).
- Formato de cada passo:
  - **Resp.** — integrante responsável (label `Resp: …`) e labels de ferramenta. O responsável faz os commits do passo (E0.9);
  - **Depende de** — passos que precisam estar prontos antes;
  - **Objetivo**;
  - **Saídas** — arquivos e tabelas produzidos;
  - **Passos**;
  - **Aceite** — condição verificável de pronto;
  - **Validar** — como produzir a evidência do Aceite.

## Arquivos do plano

| Etapa | Arquivo | Pasta de entrega | Aulas |
|---|---|---|---|
| 0 Ambiente | `etapa-0-ambiente.md` | — | — |
| 1 Excel avançado | `etapa-1-excel.md` | `MA2026-entrega-parcial/01-excel` | 2–3 |
| 2 Power Query | `etapa-2-powerquery.md` | `MA2026-entrega-parcial/02-powerquery` | 4–5 |
| 3 Power Pivot e DAX | `etapa-3-powerpivot-dax.md` | `MA2026-entrega-parcial/03-powerpivot` | 6–7 |
| Parcial 1 | `entregas-academicas.md` | `MA2026-entrega-parcial/04-documentacao` | 8 |
| 4 VBA | `etapa-4-vba.md` | `MA2026-entrega-final/01-vba` | 10–11 |
| 5 SQL | `etapa-5-sql.md` | `MA2026-entrega-final/02-bancodedados-sql` | 12–13 |
| 6 API/Web | `etapa-6-api-web.md` | `MA2026-entrega-final/03-api-web` | 14–15 |
| Parcial 2 | `entregas-academicas.md` | — | 16 |
| 7 Power BI | `etapa-7-powerbi.md` | `MA2026-entrega-final/04-powerbi-dashboard` | 18 |
| Entrega final | `entregas-academicas.md` | — | 20 |

As datas das aulas ainda não foram definidas. Quando forem, entram como data-alvo dos marcos no Linear.

## Arquitetura

Um arquivo por etapa, e cada um lê o anterior por parâmetro do Power Query. Uma correção feita na origem chega às etapas seguintes com "Atualizar Tudo".

```text
FONTES             ETAPA 1                 ETAPA 2                     ETAPA 3                 ETAPA 4         ETAPA 5               ETAPA 7
SPTrans diário ─┐
Metrô diário    ├─ Python ─► dados-brutos/ ─► cheiU_02_PowerQuery ─► cheiU_03_PowerPivot ─► VBA ──► CSV ─► SQL Server ─► views ─► Power BI
CPTM mensal     │  (só aquisição)  │          stg_* → Fato_/Dim_       modelo + DAX            .xlsm           (Docker)
OD 2023         │                  │          Rejeitados, Conf_*       Validacao, Conferencia               stg → dw
GTFS SPTrans   ─┘                  ▼               ▲                                                           ▲
                    cheiU_01_Excel (amostra auditável + Cadastros/Param_*) ── cad_Etapa1
Open-Meteo, BrasilAPI (Power Query) · Olho Vivo (VBA) ─────────── ETAPA 6 ───────────────────────────────────┘
```

## Modelo de dados alvo

Detalhes em `memories/decisoes/0005-constelacao-de-fatos-e-demanda-horaria-calculada.md`.

| Tabela | Grão | Origem | `origem_dado` |
|---|---|---|---|
| `Fato_Transporte` | dia × linha × modalidade | SPTrans; Metrô (entradas por estação somadas por linha); CPTM (mensal distribuído por dia) | real; estimado (CPTM) |
| `Fato_Perfil_Horario` | hora × modalidade × tipo de dia | OD 2023 ponderada por `FE_VIA` | estimado (útil); simulado (fim de semana) |
| `Fato_Viagem_OD` | hora de saída × cadeia modal × região O × região D | OD 2023 | real (amostra expandida) |
| `Fato_Oferta` | hora × linha × tipo de dia | GTFS `frequencies`; headways oficiais dos trilhos | real; simulado |
| `Fato_Clima_Horario` | data × hora | Open-Meteo | real |
| `Fato_Operacao_Onibus` (extra) | coleta × veículo | Olho Vivo | real |
| `Dim_Calendario` | data | gerada no arquivo da Etapa 3 + feriados | — |
| `Dim_Horario` | hora 0–23 | gerada + `Param_Faixas_Horarias` | — |
| `Dim_Transporte` | linha | fontes + Olho Vivo | — |
| `Dim_Localizacao` | estação ou parada | `Cad_Estacao` + shapefile OD + Olho Vivo | — |
| `Dim_Cadeia_Modal` | cadeia (ex. Ônibus → Metrô) | OD 2023 | — |
| `Param_Capacidade`, `Param_Faixas_Lotacao`, `Param_Faixas_Horarias`, `Param_Pesos_Tipo_Dia` | — | premissas com fonte citada | — |

**Demanda estimada por hora** = média diária (`Fato_Transporte`) × participação da hora (`Fato_Perfil_Horario`).
**Lotação** = demanda estimada por hora ÷ (viagens/h de `Fato_Oferta` × `Param_Capacidade`).
As duas são calculadas como medidas DAX e views SQL, no momento da consulta.

Período: 2024. Cobertura: SPTrans (todas as linhas), Metrô L1/L2/L3/L15, CPTM L7/L10/L11/L12/L13.
Corredores de análise: Leste → Centro (L3 × L11/L12) e Norte → Centro (L1 × L7).

## Responsáveis

| Etapa | Responsável principal | Apoio |
|---|---|---|
| 0 Ambiente | Luciano | Victor (repositório do grupo, DevPlace, acesso dos integrantes) |
| 1 Excel avançado | Nicolly (cadastros, amostra auditável) | Luciano (aquisição, dicionário, catálogo de defeitos) |
| 2 Power Query | Luciano | Maryele (QA) |
| 3 Power Pivot e DAX | Luciano | Nicolly (validação e conferência) |
| 4 VBA | Maryele | Luciano |
| 5 SQL | Nicolly | Luciano |
| 6 API/Web | Victor | Luciano |
| 7 Power BI | Grupo | — |
| QA de todas as etapas | Maryele | — |
| Entregas acadêmicas | Victor (coordena) | Grupo |

Cada responsável faz os commits do próprio passo: o histórico de commits é avaliado pelo professor (E0.9).
