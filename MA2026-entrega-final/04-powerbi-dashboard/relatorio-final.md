# cheiU — Relatório final

Microinformática Aplicada (ILP590) · FATEC São Paulo · Prof. Veríssimo · 2º semestre de 2026 · Grupo 10 (Mobilidade Urbana)

Integrantes: Victor Lima Conceição (gerente do projeto, API), Maryele Naara Freitas Meira (QA, automação VBA), Luciano Oliveira Gomes (engenharia de dados, Power Query).


## 1. Pergunta central e resposta

**Pergunta**: como os dados do transporte público de São Paulo revelam padrões de demanda, lotação e utilização e apoiam a comparação de alternativas de deslocamento?

**Resposta**: com os dados de 2024 que conseguimos obter (ônibus municipais da SPTrans e trens da CPTM), o padrão de demanda é claro e estável:

1. **O dia útil concentra a demanda.** Um dia útil leva em média **8.328.609 passageiros**. O sábado leva 4.980.339 (60% do dia útil), e o domingo e os feriados ficam perto de 3,48 milhões (42%). O fim de semana inteiro tem **50,7%** da demanda de um dia útil.
2. **A semana é quase plana, e a quinta-feira é o pico.** Entre segunda e sexta a média vai de 7,9 a 8,3 milhões por dia. A quinta-feira é a maior, e a segunda, a menor.
3. **O ano tem dois vales.** Janeiro é o mês mais fraco (182 milhões somando ônibus e trem) por causa das férias escolares. A demanda sobe até abril, cai um pouco no meio do ano e chega ao máximo em outubro (237 milhões). Dezembro volta a cair.
4. **Os trens são poucos, mas carregam muito.** As 5 linhas da CPTM levam **17,1%** dos passageiros, e as quatro maiores (11-Coral com 144 milhões, 7-Rubi, 10-Turquesa e 12-Safira) superam qualquer linha de ônibus em mais de seis vezes. A linha de ônibus mais usada (607C-10, Jardim Miriam–Shopping Morumbi) levou 10 milhões no ano.
5. **A rede de ônibus é capilar.** As linhas locais de distribuição levam 35,0% de todos os passageiros, mais que as estruturais (27,3%) e as de articulação regional (20,5%).
6. **A chuva reduz a demanda.** Num dia útil com 5 mm de chuva ou mais, a média cai para 8.069.711 passageiros, **5,0% abaixo** de um dia útil seco (8.496.127). Os meses mais chuvosos foram dezembro (235,5 mm), novembro e janeiro.

A parte da pergunta sobre **lotação** e **alternativas de deslocamento** não pôde ser respondida: ela depende dos dados do Metrô e da Pesquisa Origem-Destino 2023, que não estavam disponíveis (portal do Metrô em manutenção durante todo o projeto). O modelo já tem o lugar desses dados (seção 8).

## 2. Fontes de dados

| Fonte | O que usamos | Cobertura | `origem_dado` |
|---|---|---|---|
| SPTrans, passageiros transportados | arquivos diários por linha | 366 dias de 2024, 1.437 linhas | real |
| SPTrans, consolidado mensal | total publicado por grupo (referência) e o dia 08/07 de 207 linhas | 12 meses | real / estimado |
| CPTM, embarcados acumulados | entradas mensais por estação, distribuídas pelos dias com pesos por tipo de dia | 12 meses, 5 linhas | estimado |
| Open-Meteo (API) | chuva e temperatura por hora (reanálise ERA5) | 8.784 horas | estimado |
| BrasilAPI (API) | feriados nacionais, mais os locais de São Paulo | 2024 | real |

Premissas registradas em `memories/decisoes/`: pesos da CPTM (decisão `0012`), diferença contra o total publicado (`0014`) e clima por arquivo (`0016`).

## 3. Pipeline

| Etapa | Ferramenta | Entrega | Conferência |
|---|---|---|---|
| 1 | Excel | base auditável da amostra de jan/2024 | 579 problemas detectados × 579 registrados |
| 2 | Power Query | 39 consultas, 366 arquivos lidos | `Conf_Reconciliacao` com diferença 0 |
| 3 | Power Pivot e DAX | modelo estrela e 28 medidas | KPIs iguais aos da Etapa 2 |
| 4 | VBA | atualização, QA (24 checagens), resumo diário em PDF e exportação | QA 24/24 OK |
| 5 | SQL Server (Docker) | banco `cheiU`, 13 consultas, 11 views | 8 KPIs SQL × DAX com diferença 0 |
| 6 | API | BrasilAPI ao vivo e Open-Meteo | `Conf_Feriados` OK |
| 7 | Power BI | painel de 5 páginas | 8 KPIs Power BI × SQL com diferença 0 |

Cada etapa lê a anterior. Todo binário tem um gêmeo em texto (`.pq`, `.dax`, `.bas`, `.sql`, TMDL e PBIR), e todo número deste relatório vem do modelo.

## 4. O painel

`cheiU_dashboard.pbix` (PDF em `cheiU_dashboard.pdf`), conectado às views `dw.vw_*` do SQL Server:

1. **Visão geral**: total de passageiros, média de dia útil, diferença contra o publicado e a linha mensal por modalidade.
2. **Padrões por dia**: média por dia da semana e por tipo de dia.
3. **Linhas e grupos**: as 10 linhas mais usadas, a participação dos grupos e a parte real × estimada.
4. **Chuva**: dia útil com chuva × seco e a chuva por mês.
5. **Sobre os dados**: fontes, premissas e limitações.

Segue os padrões do professor: tema único, títulos em pergunta, no máximo 6 visuais por página, segmentações de mês e modalidade sincronizadas e KPIs na dica de ferramenta. QA em `04-documentacao/qa/etapa-7.md`.

## 5. Números principais

| Indicador | Valor |
|---|---|
| Passageiros em 2024 (ônibus + CPTM) | 2.564.533.459 |
| Passageiros de ônibus | 2.125.608.791 |
| Passageiros da CPTM (estimado) | 438.924.668 |
| Média de dia útil | 8.328.609 |
| Média de fim de semana | 4.225.515 |
| Fim de semana / dia útil | 50,7% |
| Dia útil com chuva × seco | −5,0% |
| Diferença contra o total publicado da SPTrans (grupos oficiais) | −1,77% |
| Parte estimada da demanda | 17,15% |

Demanda mensal, em milhões de passageiros:

| Mês | Ônibus | Trem | Total |
|---|---|---|---|
| Jan | 149,8 | 32,4 | 182,3 |
| Fev | 163,0 | 33,4 | 196,4 |
| Mar | 179,4 | 36,0 | 215,4 |
| Abr | 182,8 | 37,4 | 220,2 |
| Mai | 180,2 | 36,9 | 217,1 |
| Jun | 175,9 | 36,4 | 212,2 |
| Jul | 174,4 | 36,9 | 211,3 |
| Ago | 192,0 | 38,8 | 230,9 |
| Set | 186,1 | 37,5 | 223,6 |
| Out | 196,5 | 40,1 | 236,7 |
| Nov | 179,6 | 37,4 | 217,1 |
| Dez | 165,7 | 35,7 | 201,4 |

## 6. Qualidade dos dados

- O catálogo de defeitos (`04-documentacao/catalogo-de-defeitos.md`) tem 25 defeitos reais das fontes, cada um com a etapa que o trata.
- Nenhuma linha some sem explicação: as rejeitadas vão para `Rejeitados` com o motivo, e as tabelas `Conf_*` fecham com diferença 0.
- A soma dos arquivos diários da SPTrans fica 2% a 5% abaixo do total publicado de janeiro a junho e menos de 0,8% abaixo de julho a dezembro. Janeiro confere com o consolidado da própria SPTrans, então a diferença vem da fonte (reprocessamento), não do tratamento (decisão `0014`).

## 7. Limitações

- **Sem Metrô e sem OD 2023**: não há perfil horário, pico, lotação, mapa nem comparação de alternativas de percurso.
- **Trem estimado**: a CPTM publica entradas mensais por estação; a distribuição pelos dias usa pesos por tipo de dia provisórios (decisão `0012`).
- **Clima de reanálise**: o Open-Meteo vem do modelo ERA5, não de uma estação de medição.
- **Olho Vivo**: a API em tempo real da SPTrans exige um token do DevPlace que o grupo não obteve; a posição dos ônibus ficou fora.
- **Efeito da chuva**: é uma comparação de médias, sem controle de mês ou de feriado próximo; mostra associação, não causa.

## 8. Trabalhos futuros

1. Carregar o Metrô e a Pesquisa OD 2023 quando o portal voltar: as tabelas `Fato_Perfil_Horario` e `Dim_Localizacao` já estão previstas no plano (E1.3, E2.5–E2.8).
2. Com a OD, montar as páginas "Padrões horários" e "Alternativas de percurso" do painel (E7.3, E7.5).
3. Obter o token do Olho Vivo e coletar posições para medir a pontualidade (E6.3, E6.4).
4. Substituir os pesos provisórios da CPTM pelo perfil diário real, se a CPTM publicar.
5. Testar o efeito da chuva por regressão, controlando mês e tipo de dia.

## 9. Onde está cada coisa

| Item | Caminho |
|---|---|
| Etapas 1–3 | `MA2026-entrega-parcial/01-excel`, `02-powerquery`, `03-powerpivot` |
| Etapa 4 | `MA2026-entrega-final/01-vba` |
| Etapa 5 | `MA2026-entrega-final/02-bancodedados-sql` |
| Etapa 6 | `MA2026-entrega-final/03-api-web` |
| Etapa 7 | `MA2026-entrega-final/04-powerbi-dashboard` |
| QA de cada etapa | `MA2026-entrega-parcial/04-documentacao/qa/` |
| Decisões | `memories/decisoes/` |
