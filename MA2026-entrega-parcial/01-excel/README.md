# 01-excel — Etapa 1 (Excel avançado)

`cheiU_01_Excel.xlsx` transforma um arquivo bruto real da SPTrans numa base auditável, só com fórmulas e sem alterar nenhum valor original. Também guarda os cadastros e parâmetros que o Power Query da Etapa 2 lê (`cad_Etapa1`).

Plano: `docs/plano/etapa-1-excel.md`. Exigências do professor: `docs/plano/referencia-professor.md`. Defeitos encontrados: `04-documentacao/catalogo-de-defeitos.md`.

## Amostra

Consolidado SPTrans de **janeiro de 2024** (`dados-brutos/sptrans/2024/mensal/Consolidado 01-Janeiro-2024.xls`, aba `Geral_Consolidado`): 41.968 registros dia × linha × empresa, com 149.820.742 passageiros. O ano inteiro (366 arquivos diários) só entra no Power Query da Etapa 2.

## Abas

| Aba | Conteúdo |
|---|---|
| `Bruto` | Cópia fiel da aba original, feita por Mover ou Copiar. A aba vem oculta no arquivo publicado (D16) e foi só reexibida. |
| `Tratado` | Tabela `Tab_Transporte`: `Linha_Origem` (valor fixo = linha do `Bruto`), as 16 colunas originais como vieram e as colunas calculadas abaixo. |
| `Cadastros` | Cadastros, de-para, parâmetros e listas de valores válidos, lidos pela Etapa 2. |
| `Auditoria` | `Tab_Auditoria` (um registro por problema, com a ação necessária) e o painel de conferência. |

Colunas calculadas de `Tab_Transporte`:

| Coluna | Técnica | Defeito |
|---|---|---|
| `Data_Trat` | `LET` + `TEXTSPLIT` + `DATA`; "Data inválida" se a data não existe | D6 |
| `Mes`, `Dia_Semana`, `Tipo_Dia` | `MÊS`, `ESCOLHER(DIA.DA.SEMANA)`, feriado por `CORRESPX` em `Cad_Feriados_2024` | — |
| `Grupo_Trat` | `PROCX` em `Cad_DePara_Grupo`, com retorno "Não cadastrado" | D8, D9 |
| `Codigo_Linha_Trat`, `Nome_Linha_Trat` | `TEXTOANTES`/`TEXTODEPOIS`, `ARRUMAR`, `PRI.MAIUSCULA`; código no formato do letreiro (`917M-10`) | D7 |
| `Status_Vazio_Zero`, `Status_Empresa`, `Status_Grupo`, `Status_Fora_Limite`, `Status_Data` | `SE`/`OU`, limite em `Param_Limite_Max` | D9, D10 |
| `Problemas` | `UNIRTEXTO` dos status diferentes de OK, ou "Sem problemas" | — |

Formatação condicional: total vazio ou zero (vermelho), total acima do limite (laranja), linha com problema (amarelo), diferença diferente de 0 no painel (vermelho). Validação de dados em lista: `Tab_Auditoria[Tipo_Problema]`, `Tab_Auditoria[Situacao]` e as colunas de destino de `Cad_DePara_Grupo`.

## Cadastros

| Tabela | Linhas | Uso |
|---|---|---|
| `Tab_Configuracao` | 1 | célula nomeada `CaminhoRepo`: a raiz do repositório, derivada de `CÉL("nomearquivo")`, sem edição manual |
| `Cad_DePara_Grupo` | 6 | grafias do grupo → grupo padronizado e modalidade; só grafias confirmadas |
| `Cad_DePara_Coluna` | 18 | nome da coluna em cada layout → nome padrão (D4), usado pela `fnLerSPTrans` |
| `Cad_Feriados_2024` | 15 | nacionais, 25/01 (município), 09/07 (estado) e pontos facultativos; provisório até a BrasilAPI (Etapa 6) |
| `Param_Limites` | 1 | `limite_max_passageiros_dia_linha` = 30.000 (premissa: máximo de jan/24 = 33.411; percentil 99,9 = 22.473) |
| `Param_Pesos_Tipo_Dia` | 4 | pesos para distribuir a CPTM mensal por dia (premissa até haver dados do Metrô) |
| `Tab_Grupo`, `Tab_Modalidade`, `Tab_Tipo_Dia`, `Tab_Tipo_Problema`, `Tab_Situacao` | 4, 3, 4, 6, 3 | listas `Lista_*` no Gerenciador de Nomes |

## Conferência (06/11/2026)

| Verificação | Resultado |
|---|---|
| Painel Tipo × Detectado × Registrado × Diferença | 579 detectados, 579 registrados, diferença 0 em todos os tipos |
| Erros de fórmula (`SOMARPRODUTO(--ÉERROS(Tab_Transporte))`) | 0 |
| Linhas de dados no `Bruto` − linhas de `Tab_Transporte` | 0 |
| Soma do total no `Bruto` − soma em `Tab_Transporte` | 0 |
| Células originais diferentes do `Bruto` | 0 |
| Linhas sem problema | 41.395 de 41.968 |
| Linhas sorteadas (semente 20261106) achadas no `Bruto` | `Linha_Origem` 3171 (03/01/2024, 305110, 486 passageiros) e 5793 (05/01/2024, 801021, 100) |

Problemas registrados na `Tab_Auditoria`:

| Tipo | Linhas | Situação |
|---|---|---|
| Empresa como código | 554 | Pendente de esclarecimento: confirmar com a SPTrans o nome da operadora; a empresa não entra no modelo |
| Acima do limite | 14 | Pendente de esclarecimento: conferir com a média da linha; valor mantido |
| Grupo fora dos oficiais (`OUTRO PC`) | 6 | Pendente de esclarecimento; grupo "Outros" na Etapa 2 |
| Vazio ou zero | 5 | Aceito como está |

## Como reconstruir

A pasta de trabalho é gerada por `scripts/montar_etapa1.ps1` (o gêmeo em texto: fórmulas, cadastros, validações e formatação estão nele):

```bash
powershell -NoProfile -ExecutionPolicy Bypass -File MA2026-entrega-parcial/01-excel/scripts/montar_etapa1.ps1
```

Os dados brutos vêm de `scripts/baixar_sptrans.py` (idempotente, grava `dados-brutos/manifesto.csv`). O perfil de layout de cada arquivo sai de `scripts/perfilar_sptrans.py`.

## Pendências

- Metrô e CPTM (E1.2): o portal do Metrô estava em manutenção em 06/11 e a CPTM só permite download pelo navegador. Entram na Etapa 2 quando houver arquivo.
- Prints de evidência em `evidencias/` (painel, Rastrear Precedentes, Gerenciador de Nomes): exigem a interface do Excel.
- Escopo respeitado: sem Power Query, DAX ou macro neste arquivo.
