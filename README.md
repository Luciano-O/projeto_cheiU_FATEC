# cheiU — Mobilidade Urbana

Projeto evolutivo de **Microinformática Aplicada (ILP590)** — FATEC São Paulo, Análise e Desenvolvimento de Sistemas, Prof. Veríssimo, 2º semestre de 2026. Grupo 10.

> **Pergunta central**: como os dados do transporte público podem ser usados para identificar padrões de demanda, lotação e utilização e, a partir disso, apoiar a análise de diferentes alternativas de deslocamento na mobilidade urbana?

O projeto analisa a demanda de ônibus (SPTrans), Metrô e CPTM em São Paulo em 2024. A partir dos totais diários publicados e do perfil horário da Pesquisa Origem-Destino 2023, estima a demanda por hora e simula a lotação, para comparar alternativas como Ônibus → Metrô e Ônibus → Trem nos corredores Leste → Centro e Norte → Centro.

## Equipe

| Integrante | Função |
|---|---|
| Victor Lima Conceição | Gerente do projeto, programação de API |
| Nicolly Santos do Nascimento | Banco de dados SQL, Excel |
| Maryele Naara Freitas Meira | QA, automação VBA |
| Luciano Oliveira Gomes | Engenharia de dados, modelagem Power Query |

## Pipeline

Sete etapas, numeradas como as do professor. Cada uma lê a saída da anterior:

Dados brutos → 1 Excel → 2 Power Query → 3 Power Pivot/DAX → 4 VBA → 5 SQL Server → 6 API/Web → 7 Power BI

## Estrutura

```text
MA2026-entrega-parcial/
├── 01-excel/            amostra auditável, cadastros, parâmetros e dados brutos (Etapa 1)
├── 02-powerquery/       tratamento em Power Query, dados limpos e conferência (Etapa 2)
├── 03-powerpivot/       modelo dimensional e DAX (Etapa 3)
└── 04-documentacao/     ficha do projeto, dicionário, catálogo de defeitos, QA, relatório e apresentação da Parcial 1
MA2026-entrega-final/
├── 01-vba/              automação VBA (Etapa 4)
├── 02-bancodedados-sql/ SQL Server em Docker, DDL, carga e consultas (Etapa 5)
├── 03-api-web/          Open-Meteo, BrasilAPI e Olho Vivo (Etapa 6)
└── 04-powerbi-dashboard/ dashboard e relatório final (Etapa 7)
docs/plano/              plano de implementação passo a passo e o que o professor exige
docs/professor/          projeto modelo e guias práticos do professor (PDF)
memories/                decisões, glossário, fontes de dados e diário do projeto
```

## Status

| Etapa | Aulas | Situação |
|---|---|---|
| 0 — Ambiente | — | em andamento |
| 1 — Excel avançado | 2–3 | a fazer |
| 2 — Power Query | 4–5 | a fazer |
| 3 — Power Pivot e DAX | 6–7 | a fazer |
| Parcial 1 | 8 | a fazer |
| 4 — VBA | 10–11 | a fazer |
| 5 — SQL | 12–13 | a fazer |
| 6 — API/Web | 14–15 | a fazer |
| Parcial 2 | 16 | a fazer |
| 7 — Power BI | 18 | a fazer |
| Entrega final | 20 | a fazer |

O acompanhamento detalhado é feito no Linear (time TRA).

## Como contribuir

Leia o [AGENTS.md](AGENTS.md): ele vale para pessoas e agentes de IA. O passo a passo de cada etapa está em [docs/plano/](docs/plano/README.md). Cada integrante faz os commits do próprio trabalho: o histórico é avaliado.
