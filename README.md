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

Dados brutos → Excel → Power Query → Power Pivot/DAX → VBA → SQL Server → API/Web → Power BI

## Estrutura

```text
MA2026-entrega-parcial/
├── 01-excel/            cadastros, parâmetros e dados brutos (Etapa 1)
├── 02-powerquery/       tratamento em Power Query (Etapa 1)
├── 03-powerpivot/       modelo dimensional e DAX (Etapa 2)
└── 04-documentacao/     dicionário de dados, QA, relatório e apresentação da Parcial 1
MA2026-entrega-final/
├── 01-vba/              automação VBA (Etapa 3)
├── 02-bancodedados-sql/ SQL Server em Docker, DDL, carga e consultas (Etapa 4)
├── 03-api-web/          Open-Meteo, BrasilAPI e Olho Vivo (Etapa 5)
└── 04-powerbi-dashboard/ dashboard e relatório final (Etapa 6)
docs/plano/              plano de implementação passo a passo
memories/                decisões, glossário, fontes de dados e diário do projeto
```

## Status

| Etapa | Situação |
|---|---|
| 0 — Ambiente | em andamento |
| 1 — Excel e Power Query | a fazer |
| 2 — Power Pivot e DAX | a fazer |
| Parcial 1 | a fazer |
| 3 — VBA | a fazer |
| 4 — SQL | a fazer |
| 5 — API/Web | a fazer |
| 6 — Power BI | a fazer |
| Entrega final | a fazer |

O acompanhamento detalhado é feito no Linear (time TRA).

## Como contribuir

Leia o [AGENTS.md](AGENTS.md): ele vale para pessoas e agentes de IA. O passo a passo de cada etapa está em [docs/plano/](docs/plano/README.md).
