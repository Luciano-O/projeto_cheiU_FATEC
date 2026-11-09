# Catálogo de defeitos — fontes de 2024

Defeitos encontrados nos arquivos reais baixados em 06/11/2026 (`01-excel/dados-brutos/`). O levantamento vem de `01-excel/scripts/perfilar_sptrans.py` (saída em `dados-brutos/sptrans/2024/perfil_layout.csv`) e de uma varredura de conteúdo em 1 de cada 6 arquivos diários (80.978 linhas).

Legenda da coluna "Como cada etapa trata":
- **trata**: a etapa corrige;
- **sinaliza**: a etapa marca com fórmula, sem corrigir;
- **registra**: a etapa só anota na auditoria;
- **—**: a etapa não atua.

| ID | Defeito | Exemplo real | Fonte | Etapa 1 (Excel) | Etapa 2 (Power Query) |
|---|---|---|---|---|---|
| D1 | Cabeçalho fora da linha 1 e em posição variável | o cabeçalho está na linha 3 em 243 diários, na 4 em 87 e na 10 em 28 (ex. `diario/01ago2024.xlsx`); há ainda arquivos com o cabeçalho nas linhas 5 a 9 (`16ago2024`, `15ago2024`, `12jul2024`, `13ago2024`, `12ago2024`) | SPTrans diário | sinaliza: `Tipo_Registro` marca título e cabeçalho; registra | trata: `fnLerSPTrans` procura a linha cujo 1º valor é "Data" (E2.2) |
| D2 | Título de relatório acima do cabeçalho | linha 1 = "RELATÓRIO DE PASSAGEIROS PARA O PORTAL DE TRANSPARÊNCIA. Data : '01-JAN-2024' … Página 1 de 44" | SPTrans | sinaliza (`Tipo_Registro` = "Título"); registra | trata: descarta as linhas acima do cabeçalho (E2.2), conta em `Conf_Etapas` |
| D3 | Linhas vazias no meio e no fim da planilha | 6.672 linhas vazias nos diários; 221 só em `diario/25ago2024.xlsx` | SPTrans diário | sinaliza (`Tipo_Registro` = "Vazia") | trata: remove e conta em `Conf_Etapas` (E2.2) |
| D4 | Nomes de coluna com grafias diferentes entre arquivos | `Passageiros Comum e VT` (212 arquivos) × `Passageiros Comum E Vt` (154); `Int Ônibus->Ônibus` × `Int ÔNibus->ÔNibus`; espaços sobrando no fim (`Em Dinheiro `) nos consolidados | SPTrans | registra; cria `Cad_DePara_Coluna` | trata: de-para de colunas lido de `cad_Etapa1`; `Conf_Colunas` lista o que não casou (E2.2) |
| D5 | Extensão do arquivo não corresponde ao formato | os 6 consolidados de jan–jun têm extensão `.xls`, mas são `.xlsx` por dentro; 243 diários são `.xls` antigos (BIFF) e 123 são `.xlsx` | SPTrans | registra | trata: `Excel.Workbook` detecta o formato pelo conteúdo (E2.2) |
| D6 | Data como texto em parte dos arquivos | nos `.xls`, `Data` vem como texto `"01/04/2024"`; nos `.xlsx`, como data | SPTrans diário | trata: `Data_Trat` com LET + DATA, "Data inválida" se não converter | trata: tipagem com `"pt-BR"` (E2.2) |
| D7 | Código e nome da linha na mesma célula, e código sem o hífen do letreiro | `917M10 - MORRO GRANDE/METRO ANA ROSA` (letreiro `917M-10`) | SPTrans | trata: `Codigo_Linha_Trat` e `Nome_Linha_Trat` | trata: separa e normaliza (E2.2) |
| D8 | Grupo com e sem acento | `GRUPO DE DISTRIBUIÇÃO` × `GRUPO DE DISTRIBUICAO`; `GRUPO ARTICULAÇÃO` × `GRUPO ARTICULACAO` | SPTrans | trata: `Grupo_Trat` por PROCX em `Cad_DePara_Grupo` | trata: mesclagem com `cad_DePara_Grupo` (E2.2) |
| D9 | Grupo fora dos três grupos oficiais | `OUTRO PC` (137 linhas na amostra), com lote numérico (`0`, `19`, `90`) | SPTrans | sinaliza; registra como "Pendente de esclarecimento" | trata: grupo "Outros" em `Dim_Grupo`; diferença contra o total publicado explicada no README (E2.9) |
| D10 | Empresa como código numérico em vez de nome | `393` em `diario/01ABR2024.xls` (1.284 linhas na amostra) | SPTrans | sinaliza (`Status_Empresa_Codigo`); registra | — (a empresa não entra no modelo; a linha é agregada por data × linha) |
| D11 | A mesma linha aparece várias vezes no dia (uma por empresa ou lote) | a linha soma mais de um registro no mesmo dia quando é operada por mais de uma empresa | SPTrans | registra | trata: agrupa por data × linha, somando (E2.2) |
| D12 | Layout do consolidado muda no meio do ano | jan–jun: dia × linha (aba `Geral_Consolidado`, ~40 mil linhas); jul–dez: só mês × linha, sem a coluna `Data`; nov/2024 sem cabeçalho reconhecível | SPTrans consolidado | registra; a amostra usa jan/2024 | trata: a Etapa 2 lê os **diários** (layout único) e não usa os consolidados |
| D13 | Nomes de arquivo sem padrão, com erro de grafia, e links quebrados na página | `01JAN2024(1).xls`, `31dez2024-1.xls`, `22ul2024-xlsx` (jul); três links publicados como `https://https://…` ou relativos quebrados | SPTrans página 2024 | trata no download: `baixar_sptrans.py` corrige os links e deriva a data do nome (E1.1) | trata: a data vem do conteúdo, não do nome do arquivo (E2.2) |
| D14 | Tabela de referência larga, com totais e em Latin-1 | totais mensais: meses nas linhas, grupos nas colunas, linha "Total" no fim, números com ponto de milhar (`157.927.773`) | SPTrans totais mensais | — | trata: despivota, remove a linha "Total", converte com `"pt-BR"` (E2.2) |
| D15 | Portal fora do ar | Metrô `transparencia.metrosp.com.br`: HTTP 503 "Em manutenção" em 06/11; CPTM: bloqueio de download automático | Metrô, CPTM | registra como pendência (E1.2) | — (as fontes entram quando houver arquivo) |
| D16 | Aba de dados oculta no arquivo publicado | no consolidado de jan/2024 a aba `Geral_Consolidado` vem oculta; só a aba-resumo aparece ao abrir | SPTrans consolidado | trata: a cópia para `Bruto` é reexibida (o conteúdo não muda) | — (a Etapa 2 lê os diários) |
| D17 | `.xls` antigo que o Power Query abre vazio | `01JAN2024(1).xls`, `07JAN2024(1).xls`, `14JAN2024(2).xls`, `28JAN2024(1).xls`, `02MAI2024.xls` e `03MAI2024.xls`: o `Excel.Workbook` devolve zero abas, embora o Excel e o xlrd abram normalmente | SPTrans diário | trata na aquisição: `converter_xls_legado.py` copia valor por valor para `diario_convertido/*.xlsx`, sem tratamento | trata: `stg_SPTrans_Bruto` usa a cópia só quando o original vem vazio, e `Conf_Etapas` conta esses arquivos |
| D18 | Data em texto no formato americano | nos 31 `.xls` de dezembro (`01dez2024-1.xls`…), o Power Query recebe `Data` como texto `12/1/2024` (mês/dia). Lida como dia/mês, ela vira outra data até o dia 12 (o 11/12 cai no 12/11, e o 10/12 no 12/10, como falsas duplicatas) e não converte depois do dia 12 | SPTrans diário | — (a amostra é de janeiro) | trata: `fnLerSPTrans` toma como referência a data do título (`Data : '01-NOV-2024'`) ou, em dezembro, cujo título não tem data, a do nome do arquivo, e `stg_sptrans_linhas` escolhe a interpretação que bate com ela; se nenhuma bater, a linha vai para `Rejeitados` ("Data diferente da data de referência do arquivo") |

Verificações que **não** acharam defeito na amostra:
- `Tot Passageiros Transportados` = `Pagantes` + `Int Ônibus->Ônibus` + `Com Gratuidade` + `Com Gratuidade Est` em todas as 80.978 linhas;
- nenhum valor negativo; só 3 linhas com total zero;
- toda célula `Linha` segue o padrão `CÓDIGO - NOME`.
