# cheiU — Mobilidade Urbana

Projeto evolutivo de **Microinformática Aplicada (ILP590)** — FATEC São Paulo, Análise e Desenvolvimento de Sistemas, Prof. Veríssimo, 2º semestre de 2026. Grupo 10.

> **Pergunta central**: como os dados do transporte público podem ser usados para identificar padrões de demanda, lotação e utilização e, a partir disso, apoiar a análise de diferentes alternativas de deslocamento na mobilidade urbana?

O projeto analisa a demanda de ônibus (SPTrans), Metrô e CPTM em São Paulo em 2024. A partir dos totais diários publicados e do perfil horário da Pesquisa Origem-Destino 2023, estima a demanda por hora e simula a lotação, para comparar alternativas como Ônibus → Metrô e Ônibus → Trem nos corredores Leste → Centro e Norte → Centro.

## Equipe

| Integrante | Função |
|---|---|
| Victor Lima Conceição | Gerente do projeto, programação de API |
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

Projeto concluído em 28/11/2026 (tag `final`). O escopo entregue é o que os dados disponíveis permitiram (decisões `0018` e `0019`).

| Etapa | Situação |
|---|---|
| 1 — Excel avançado | concluída: base auditável da amostra de jan/2024; CPTM cadastrada |
| 2 — Power Query | concluída: SPTrans (366 dias) e CPTM com estimativa diária; diferença contra o publicado explicada (decisão `0014`) |
| 3 — Power Pivot e DAX | concluída: modelo estrela e 28 medidas de demanda |
| 4 — VBA | concluída: atualização, QA (24/24 OK), resumo diário em PDF e exportação para o SQL |
| 5 — SQL | concluída: SQL Server em Docker, 13 consultas, 11 views; SQL × DAX com diferença 0 |
| 6 — API/Web | concluída: BrasilAPI e Open-Meteo no modelo e no SQL |
| 7 — Power BI | concluída: painel de 5 páginas; Power BI × SQL com diferença 0 |
| Entrega final | concluída: relatório final e painel em `MA2026-entrega-final/04-powerbi-dashboard` |

Fora do escopo final, por falta de dados ou de acesso: Metrô, Pesquisa OD 2023 (perfil horário, lotação, alternativas de percurso), Olho Vivo e GTFS da SPTrans.

O acompanhamento detalhado é feito no Linear (time TRA).

## Como contribuir

Leia o [AGENTS.md](AGENTS.md): ele vale para pessoas e agentes de IA. O passo a passo de cada etapa está em [docs/plano/](docs/plano/README.md). Cada integrante faz os commits do próprio trabalho: o histórico é avaliado.
