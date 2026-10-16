# Plano de implementação — cheiU

Aqui está o **como** de cada passo. O status fica no Linear; o porquê das escolhas, em `memories/decisoes/`.

## Como usar

- Cada passo tem um ID (`E1.6`) e vira uma issue no Linear com título `[E1.6] …`. Para achar a issue, busque o ID no Linear.
- Cada etapa começa pelo passo `Ex.0 — Refinar o plano da etapa`: releia o arquivo da etapa à luz do que as etapas anteriores produziram e ajuste passos, saídas e aceites aqui e nas issues antes de executar.
- Formato de cada passo:
  - **Resp.** — integrante responsável (label `Resp: …`) e labels de ferramenta;
  - **Depende de** — passos que precisam estar prontos antes;
  - **Objetivo**;
  - **Saídas** — arquivos e tabelas produzidos;
  - **Passos**;
  - **Aceite** — condição verificável de pronto;
  - **Validar** — como produzir a evidência do Aceite.

## Arquivos do plano

| Etapa | Arquivo | Pasta de entrega | Aula no modelo do professor |
|---|---|---|---|
| 0 Ambiente | `etapa-0-ambiente.md` | — | — |
| 1 Excel e Power Query | `etapa-1-excel-powerquery.md` | `MA2026-entrega-parcial/01-excel`, `02-powerquery` | 5 |
| 2 Power Pivot e DAX | `etapa-2-powerpivot-dax.md` | `MA2026-entrega-parcial/03-powerpivot` | 7 |
| Parcial 1 | `entregas-academicas.md` | `MA2026-entrega-parcial/04-documentacao` | 8 |
| 3 VBA | `etapa-3-vba.md` | `MA2026-entrega-final/01-vba` | 11 |
| 4 SQL | `etapa-4-sql.md` | `MA2026-entrega-final/02-bancodedados-sql` | 13 |
| 5 API/Web | `etapa-5-api-web.md` | `MA2026-entrega-final/03-api-web` | 15 |
| Checkpoint | `entregas-academicas.md` | — | 16 |
| 6 Power BI | `etapa-6-powerbi.md` | `MA2026-entrega-final/04-powerbi-dashboard` | 18 |
| Entrega final | `entregas-academicas.md` | — | 20 |

As datas das aulas ainda não foram definidas. Quando forem, entram como data-alvo dos marcos no Linear.

## Arquitetura

```text
FONTES                     ETAPAS 1–2 (Excel)                         ETAPA 3        ETAPA 4+                      ETAPA 6
SPTrans diário  ─┐
Metrô diário     ├─ scripts Python ─► dados-brutos/ ─► Power Query ─► Power Pivot ─► VBA ──► CSV ─► SQL Server ─► views ─► Power BI
CPTM mensal      │  (só aquisição)                   stg_* → Fato_/   + DAX        atualiza,       (Docker)
OD 2023          │                                   Dim_/Param_                   valida,         stg → dw
GTFS SPTrans    ─┘                                                                 exporta           ▲
Open-Meteo, BrasilAPI (Power Query) · Olho Vivo (VBA) ─────────── ETAPA 5 ──────────────────────────┘
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
| `Dim_Calendario` | data | gerada + feriados | — |
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
| 0 Ambiente | Luciano | Victor (repositório do grupo, DevPlace) |
| 1 Excel e Power Query | Luciano (Power Query, aquisição) | Nicolly (Excel avançado) |
| 2 Power Pivot e DAX | Luciano | Nicolly |
| 3 VBA | Maryele | Luciano |
| 4 SQL | Nicolly | Luciano |
| 5 API/Web | Victor | Luciano |
| 6 Power BI | Grupo | — |
| QA de todas as etapas | Maryele | — |
| Entregas acadêmicas | Victor (coordena) | Grupo |
