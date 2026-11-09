# 02-powerquery — Etapa 2 (Power Query)

`cheiU_02_PowerQuery.xlsx` lê os **366 arquivos diários da SPTrans de 2024** e os cadastros da Etapa 1 (`cad_Etapa1`), trata os defeitos do catálogo e entrega as tabelas de saída que a Etapa 3 lê. Regra de ouro: nenhuma linha some sem explicação. Toda linha lida termina em `Fato_Transporte` ou em `Rejeitados`, e `Conf_Reconciliacao` prova que lidas − aceitas − rejeitadas = 0.

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
| `01_Parametros` | `pCaminhoRepo`, `pArquivoEtapa1`, `pPastaSPTrans`, `pPastaSPTransConvertido`, `pArquivoTotaisSPTrans` |
| `02_Origem` | `stg_SPTrans_Bruto` (`Folder.Files` da pasta inteira), `fnLerSPTrans` |
| `03_Cadastros` | `cad_Etapa1`, `cad_DePara_Grupo`, `cad_DePara_Coluna`, `cad_Feriados`, `lst_Grupo` |
| `04_Tratamento` | `stg_sptrans_linhas` (tipagem e motivo), `stg_sptrans_diario` (grão data × linha), `stg_sptrans_referencia` (totais publicados despivotados) |
| `05_Saida` | `Fato_Transporte`, `Fato_Referencia_Mensal`, `Dim_Transporte`, `Dim_Grupo`, `Ref_Feriados`, `Rejeitados` |
| `06_Conferencia` | `Conf_Reconciliacao`, `Conf_Motivos`, `Conf_Colunas`, `Conf_Etapas`, `Conf_Publicado` |

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

## Conferência

| Verificação | Resultado |
|---|---|
| Arquivos lidos | 366 (6 deles pela cópia convertida, D17) |
| Lidas − aceitas − rejeitadas | 486.864 − 480.192 − 6.672 = 0 |
| Passageiros aceitos − passageiros na fato | 2.124.704.175 − 2.124.704.175 = 0 |
| `Conf_Colunas` | vazia |
| `Fato_Transporte` | 461.839 linhas (dia × linha), os 366 dias, sem duplicata no grão |
| `Dim_Transporte` | 1.437 linhas de ônibus |
| Rejeitados | 6.672, todas "Linha vazia" (109 arquivos) |
| `.pq` × consultas da pasta | 26 × 26, 0 diferenças (`scripts/verificar_etapa2.ps1`) |
| Teste de reenvio | com uma cópia extra de `01ago2024.xlsx`: lidas 488.200, rejeitadas 8.008 (1.318 "Arquivo duplicado", 18 vazias a mais), aceitas e fato iguais, diferença 0; ao retirar, volta a 486.864 |
| Linhagem com a Etapa 1 | jan/2024 nos três grupos oficiais = 149.800.158 = total da amostra (149.820.742) − "OUTRO PC" (20.584) |

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
- Metrô e CPTM (E2.3, E2.4): sem arquivo; a `Fato_Transporte` tem só Ônibus.
- `OUTRO PC`: linhas fora dos três grupos oficiais, no grupo "Outros" (3,1 milhões de passageiros no ano), aguardando esclarecimento.
- Grupos de consultas no Editor (`01_Parametros`…) e prints em `evidencias/`: exigem a interface do Excel.

Escopo respeitado: sem relacionamentos, DAX ou macro neste arquivo.

## Dados limpos

`dados_limpos/*.csv` (UTF-8), gerados por `scripts/exportar_dados_limpos.py` a partir das tabelas de saída. A `Fato_Transporte` sai em dois arquivos semestrais, abaixo de 25 MB cada.
