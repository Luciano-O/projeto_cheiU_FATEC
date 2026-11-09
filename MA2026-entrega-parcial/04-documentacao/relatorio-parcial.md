# cheiU — Relatório parcial (N1)

Microinformática Aplicada (ILP590) · FATEC São Paulo · Prof. Veríssimo · 2º semestre de 2026 · Grupo 10 (Mobilidade Urbana)
Integrantes: Victor Lima Conceição, Maryele Naara Freitas Meira, Luciano Oliveira Gomes.
Entrega parcial de 07/11/2026: Etapas 1 (Excel), 2 (Power Query) e 3 (Power Pivot e DAX).

Responsável: Victor Lima Conceição. Revisão dos integrantes: pendente.

## 1. Ficha do projeto

Ficha completa: `MA2026-entrega-parcial/04-documentacao/ficha-do-projeto.md`.

- **Pergunta central**: como os dados do transporte público de São Paulo revelam padrões de demanda, lotação e utilização e apoiam a comparação de alternativas de deslocamento?
- **Recorte da N1**: demanda diária dos ônibus municipais (SPTrans) em 2024, por linha, grupo e tipo de dia, comparada com o total oficial publicado.

## 2. Fontes, cobertura e limitações

| Fonte | Cobertura | `origem_dado` | Situação |
|---|---|---|---|
| SPTrans, passageiros transportados por dia e linha | 366 arquivos diários de 2024 | real | usada |
| SPTrans, totais mensais publicados por grupo | 12 meses de 2024 × 3 grupos | real | usada como referência ("esperado") |
| Metrô, entradas por estação | — | real | pendente: portal em manutenção em 06/11 |
| CPTM, embarcados por estação | — | estimado (mensal → diário) | pendente: download só pelo navegador |
| Pesquisa OD 2023 (perfil horário) | — | estimado | depois da N1 |

Limitações:
- a soma dos arquivos diários fica abaixo do total publicado em todos os meses: de 0,26% a 0,77% de julho a dezembro e de 2,02% a 5,15% de janeiro a junho. Janeiro confere com o consolidado da própria SPTrans, então a diferença não vem do tratamento; a causa ainda não foi confirmada com a SPTrans;
- 6 dos 366 arquivos diários só foram lidos por uma cópia `.xlsx` feita valor por valor (D17);
- a modalidade Ônibus é a única no modelo por enquanto;
- linhas 4 e 5 do Metrô (concessionárias privadas) não publicam dados.

## 3. Catálogo de defeitos

`04-documentacao/catalogo-de-defeitos.md` lista 18 defeitos reais (D1–D18), cada um com o arquivo de exemplo e a etapa que o trata. Os principais:
- cabeçalho em 8 posições diferentes (linhas 3 a 10);
- duas grafias dos nomes de coluna;
- data como texto, inclusive no formato americano em dezembro;
- código e nome da linha na mesma célula;
- grupo com e sem acento;
- seis `.xls` que o Power Query abre vazios;
- aba de dados oculta no consolidado.

## 4. Etapa 1 — base auditável em Excel

`01-excel/cheiU_01_Excel.xlsx`, amostra de jan/2024 (41.968 registros), abas `Bruto`, `Tratado`, `Cadastros` e `Auditoria`:

| Verificação | Resultado |
|---|---|
| Problemas detectados × registrados | 579 × 579, diferença 0 em todos os tipos |
| Erros de fórmula | 0 |
| Células originais alteradas | 0 |
| Linhas sorteadas achadas no `Bruto` | 3171 e 5793 |

## 5. Etapa 2 — tratamento em Power Query

`02-powerquery/cheiU_02_PowerQuery.xlsx`: 26 consultas, gêmeos em `scripts_m/`.

| Verificação | Resultado |
|---|---|
| Arquivos lidos | 366 |
| Lidas − aceitas − rejeitadas | 486.864 − 480.192 − 6.672 = 0 |
| Passageiros aceitos − na fato | 2.124.704.175 − 2.124.704.175 = 0 |
| `Fato_Transporte` | 461.839 linhas (dia × linha), todos os 366 dias |
| Colunas sem de-para | 0 |
| Teste de reenvio | as contagens mudam com um arquivo extra (diferença 0) e voltam ao retirá-lo |

Rejeitados por motivo: 6.672 "Linha vazia" (109 arquivos); nenhum outro motivo.

Linhagem: o total de jan/2024 dos três grupos oficiais na Etapa 2 é igual ao da amostra da Etapa 1 sem o "OUTRO PC" (149.800.158).

## 6. Etapa 3 — modelo dimensional e medidas

`03-powerpivot/cheiU_03_PowerPivot.xlsx`: modelo em estrela com `Fato_Transporte` e `Fato_Referencia_Mensal` (ligada por `mes_inicio`), `Dim_Calendario`, `Dim_Transporte` e `Dim_Grupo`, com 5 relações 1:N em direção única. Diagrama e relações em `03-powerpivot/docs/modelo_relacional.md`.

| Verificação | Etapa 2 | Modelo | Diferença |
|---|---|---|---|
| Linhas de `Fato_Transporte` | 461.839 | 461.839 | 0 |
| Passageiros (soma) | 2.124.704.175 | 2.124.704.175 | 0 |
| Linhas de `Rejeitados` | 6.672 | 6.672 | 0 |
| Órfãs nas 5 relações, PK duplicada, grão duplicado | 0 | 0 | 0 |

Teste de linhagem: uma mudança na Etapa 2 apareceu na Etapa 3 depois de atualizar e voltou ao desfazer.

## 7. KPIs iniciais (do modelo)

Os números abaixo vêm das tabelas dinâmicas da aba `Validacao`. Os prints dessas tabelas estão pendentes, porque exigem a interface do Excel.

| Indicador | 2024 |
|---|---|
| Total de passageiros | 2.124.704.175 |
| Média diária | 5.805.203 |
| Média em dia útil | 6.894.203 |
| Média em sábado e domingo | 3.505.315 |
| Fim de semana ÷ dia útil | 50,84% |
| Participação por grupo | Distribuição 42,14%; Estrutural 32,91%; Articulação 24,80%; Outros 0,15% |
| Mês de maior demanda | outubro (196.539.678) |
| Maior alta e maior queda mensal | agosto (+10,69%) e novembro (−8,61%) |
| Linha mais usada | 607C-10, Jd Miriam/Shopp Morumbi (10.117.677; 0,48%) |
| Calculado × publicado no ano | −1,82% |

## 8. Onde está cada exigência da Parcial 1

| Exigência | Evidência |
|---|---|
| Base bruta documentada | `01-excel/dados-brutos/` + `manifesto.csv`, `04-documentacao/dicionario-de-dados.md`, `catalogo-de-defeitos.md` |
| Base tratada em Excel | `01-excel/cheiU_01_Excel.xlsx` (painel da `Auditoria`), `04-documentacao/qa/etapa-1.md` |
| Base tratada em Power Query | `02-powerquery/cheiU_02_PowerQuery.xlsx`, `scripts_m/`, `dados_limpos/`, `Conf_Reconciliacao` |
| Modelo estrela com ≥ 5 medidas DAX | `03-powerpivot/cheiU_03_PowerPivot.xlsx`, `dax/medidas_preliminares.dax` (27 medidas: 11 de análise e 16 de conferência) |
| Ficha do projeto | `04-documentacao/ficha-do-projeto.md` |

## 9. Próximos passos

- Metrô e CPTM em `Fato_Transporte`, quando os dados estiverem disponíveis.
- Pesquisa OD 2023: perfil horário, demanda estimada por hora e cadeias modais.
- Oferta (GTFS) e lotação simulada; alternativas nos corredores Leste → Centro e Norte → Centro.
- Etapas 4–7: VBA, SQL Server, APIs (clima e feriados) e Power BI.
