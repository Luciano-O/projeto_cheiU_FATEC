# 02-powerquery — Etapa 2 (Power Query)

`cheiU_02_PowerQuery.xlsx` lê os **366 arquivos diários da SPTrans de 2024**, os **12 mensais de embarcados da CPTM** e os cadastros da Etapa 1 (`cad_Etapa1`), trata os defeitos do catálogo e entrega as tabelas de saída que a Etapa 3 lê. Regra de ouro: nenhuma linha some sem explicação. Toda linha lida termina em `Fato_Transporte` ou em `Rejeitados`, e `Conf_Reconciliacao` prova que lidas − aceitas − rejeitadas = 0.

Plano: `docs/plano/etapa-2-powerquery.md`. Defeitos: `04-documentacao/catalogo-de-defeitos.md`.

## Como abrir e atualizar

1. Abra `cheiU_02_PowerQuery.xlsx`. A célula `CaminhoRepo` (aba `Parametros`) deriva a raiz do repositório do caminho do próprio arquivo: não precisa editar nada em outro clone.
2. Dados › Atualizar Tudo. A leitura dos 366 arquivos leva alguns minutos.

Para reconstruir a pasta de trabalho do zero a partir dos `.pq`:

```bash
powershell -NoProfile -ExecutionPolicy Bypass -File MA2026-entrega-parcial/02-powerquery/scripts/montar_etapa2.ps1
```

## Consultas

Os grupos ficam listados na aba `Parametros` (o COM não tem API para os grupos do Editor).

| Grupo | Consultas |
|---|---|
| `01_Parametros` | `pCaminhoRepo`, `pArquivoEtapa1`, `pPastaSPTrans`, `pPastaSPTransConvertido`, `pArquivoTotaisSPTrans`, `pPastaCPTM` |
| `02_Origem` | `stg_SPTrans_Bruto` (`Folder.Files` da pasta inteira), `fnLerSPTrans`, `stg_cptm_linhas` (toda linha da aba `Embarcados`, com `tipo_registro`) |
| `03_Cadastros` | `cad_Etapa1`, `cad_DePara_Grupo`, `cad_DePara_Coluna`, `cad_Feriados`, `lst_Grupo`, `cad_Linha_Trilho`, `cad_Estacao`, `cad_Pesos_Tipo_Dia` |
| `04_Tratamento` | `stg_sptrans_linhas` (tipagem e motivo), `stg_sptrans_diario` (grão data × linha), `stg_sptrans_referencia` (totais publicados despivotados), `stg_cptm_mensal_linha` (mês × linha), `stg_cptm_diario_estimado` (dia × linha, estimado) |
| `05_Saida` | `Fato_Transporte`, `Fato_Referencia_Mensal`, `Dim_Transporte`, `Dim_Grupo`, `Ref_Feriados`, `Rejeitados`, `stg_cptm_mensal_estacao` (mês × linha × estação, real) |
| `06_Conferencia` | `Conf_Reconciliacao`, `Conf_Motivos`, `Conf_Colunas`, `Conf_Etapas`, `Conf_Publicado`, `Conf_CPTM` |

Configuração: privacidade "Ignorar os níveis de privacidade" (`Queries.FastCombine`; todas as origens são arquivos da equipe) e localidade explícita (`"pt-BR"`) em toda conversão de tipo.

## Regras de rejeição

| Motivo | Regra |
|---|---|
| Linha vazia | as 16 colunas vazias (D3) |
| Data inválida | a data não converte por nenhuma regra (D6, D18) |
| Data diferente da data de referência do arquivo | a data da linha não bate com a do título do arquivo, ou com a do nome quando o título não tem data (D18) |
| Arquivo duplicado | a mesma data já foi lida em outro arquivo; vale o de menor nome (D13) |
| Linha sem código | a célula `Linha` não traz código |
| Grupo não cadastrado | a grafia do grupo não está em `Cad_DePara_Grupo` da Etapa 1 |
| Total não numérico | `Tot Passageiros Transportados` não converte para número |
| Mês não identificado no nome do arquivo | CPTM: o nome não traz `2024 - MM` (o mês vem do nome, D19) |
| Arquivo duplicado (mês já lido em outro arquivo) | CPTM: outro arquivo da pasta traz o mesmo mês; vale o de menor nome, como na SPTrans |
| Linha sem cadastro em Cad_Linha_Trilho | CPTM: o bloco `LINHA n` não está no cadastro da Etapa 1 |
| Estação sem de-para em Cad_Estacao | CPTM: a grafia da estação, naquela linha, não está no de-para da Etapa 1 (D23) |

## Conferência

| Verificação | Resultado |
|---|---|
| Arquivos lidos | 366 (6 deles pela cópia convertida, D17) |
| Lidas − aceitas − rejeitadas | 486.864 − 480.192 − 6.672 = 0 |
| Passageiros aceitos − passageiros na fato | 2.124.704.175 − 2.124.704.175 = 0 |
| `Conf_Colunas` | vazia |
| `Fato_Transporte` | 461.839 linhas (dia × linha), os 366 dias, sem duplicata no grão |
| `Dim_Transporte` | 1.437 linhas de ônibus e 5 de trem |
| Rejeitados | 6.672, todas "Linha vazia" (109 arquivos); nenhuma da CPTM |
| `.pq` × consultas da pasta | 26 × 26, 0 diferenças (`scripts/verificar_etapa2.ps1`) |
| Teste de reenvio | com uma cópia extra de `01ago2024.xlsx`: lidas 488.200, rejeitadas 8.008 (1.318 "Arquivo duplicado", 18 vazias a mais), aceitas e fato iguais, diferença 0; ao retirar, volta a 486.864 |
| Linhagem com a Etapa 1 | jan/2024 nos três grupos oficiais = 149.800.158 = total da amostra (149.820.742) − "OUTRO PC" (20.584) |

### CPTM (E2.4, 27/11/2026)

| Verificação | Resultado |
|---|---|
| Arquivos lidos | 12 (um por mês) |
| Linhas da aba `Embarcados` | 1.212 = 312 de estrutura (vazias, títulos, notas, cabeçalhos de linha) + 132 subtotais e totais + 768 de estação |
| Estações lidas − aceitas − rejeitadas | 768 − 768 − 0 = 0 (64 estações-linha por mês, todas no de-para) |
| Embarcados aceitos − embarcados na fato | 438.924.668 − 438.924.668 = 0 |
| `Conf_CPTM` (60 mês × linha + 12 totais do mês) | soma das estações = "Totais da Linha" e "Totais CPTM" do arquivo; soma diária estimada = total mensal; diferença 0 nas 72 linhas |
| `Fato_Transporte` | 463.669 linhas: 461.839 de ônibus (real) + 1.830 de trem (5 linhas × 366 dias, estimado) |

A estimativa diária distribui o total mensal de cada linha pelos dias do mês com os pesos de `Param_Pesos_Tipo_Dia` da Etapa 1 (Útil 1; Sábado 0,6; Domingo e Feriado 0,4), que são uma premissa até haver as razões do Metrô (decisão `0012`). Exemplo: L11 em janeiro de 2024, 10.823.084 embarcados, fica com 419.499 ou 419.500 por dia útil, 251.700 no sábado e 167.800 no domingo e nos feriados (01/01 e 25/01).

Referência externa (não é critério de aceite): a média de dia útil estimada × "Transportados (MDU) - 2024" da CPTM (`01-excel/dados-brutos/cptm/referencia/`). As métricas são diferentes: transportados contam também quem troca de linha dentro da CPTM (Brás, Tatuapé, Luz), e embarcados só contam a entrada na estação. Por isso a estimativa fica abaixo do publicado nas linhas com mais transferência interna.

| Linha | Média de dia útil estimada (2024) | MDU publicado (2024) | Razão (mín–máx nos meses) |
|---|---|---|---|
| L7 | 405.629 | 396.174 | 1,024 (1,012–1,042) |
| L10 | 315.023 | 364.189 | 0,865 (0,843–0,884) |
| L11 | 469.809 | 529.114 | 0,888 (0,871–0,908) |
| L12 | 221.482 | 255.322 | 0,867 (0,847–0,897) |
| L13 | 19.050 | 23.186 | 0,822 (0,810–0,839) |
| Total | 1.430.992 | 1.567.986 | 0,913 |

A razão varia pouco de um mês para outro em cada linha, então a distribuição por tipo de dia não cria saltos entre os meses. Com essa comparação não dá para separar a diferença de métrica do erro dos pesos: só as razões do Metrô (E2.3) testam a premissa.

### SPTrans × total publicado

Soma mensal dos três grupos × total publicado pela SPTrans (`Conf_Publicado`):

| Mês | Calculado | Publicado | Diferença |
|---|---|---|---|
| jan | 149.800.158 | 157.927.773 | −5,15% |
| fev | 162.792.322 | 167.586.038 | −2,86% |
| mar | 179.193.277 | 182.894.300 | −2,02% |
| abr | 182.577.502 | 189.033.899 | −3,42% |
| mai | 179.952.241 | 185.548.267 | −3,02% |
| jun | 175.602.499 | 181.441.727 | −3,22% |
| jul | 173.205.070 | 174.551.078 | −0,77% |
| ago | 191.750.208 | 192.518.102 | −0,40% |
| set | 185.822.982 | 186.530.358 | −0,38% |
| out | 196.212.472 | 197.007.222 | −0,40% |
| nov | 179.314.963 | 180.011.518 | −0,39% |
| dez | 165.367.757 | 165.800.152 | −0,26% |

## Pendências

- **Aceite de 0,5% contra o publicado não atingido de janeiro a julho.** De agosto a dezembro a diferença fica abaixo de 0,5%; no primeiro semestre vai de 2% a 5%, sempre para menos e nos três grupos. A soma confere com o consolidado de janeiro da própria SPTrans, então não é perda no tratamento. A causa ainda não foi confirmada com a SPTrans.
- Metrô (E2.3): sem arquivo (portal em manutenção). Quando ele chegar, as razões MSA/MDU e MDO/MDU do Metrô substituem os pesos provisórios da CPTM em `Param_Pesos_Tipo_Dia` da Etapa 1.
- CPTM: só o total é distribuído por dia; `pagantes`, `integracao` e `gratuidades` ficam vazias nas linhas de trem.
- `OUTRO PC`: linhas fora dos três grupos oficiais, no grupo "Outros" (3,1 milhões de passageiros no ano), aguardando esclarecimento.
- Grupos de consultas no Editor (`01_Parametros`…) e prints em `evidencias/`: exigem a interface do Excel.

Escopo respeitado: sem relacionamentos, DAX ou macro neste arquivo.

## Dados limpos

`dados_limpos/*.csv` (UTF-8), gerados por `scripts/exportar_dados_limpos.py` a partir das tabelas de saída. A `Fato_Transporte` sai em dois arquivos semestrais, abaixo de 25 MB cada.
