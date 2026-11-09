# Dicionário de dados

Fontes baixadas em 06/11/2026 para `MA2026-entrega-parcial/01-excel/dados-brutos/`, com o `manifesto.csv` (fonte, url, arquivo, tamanho, sha256, data de download, data de referência). Os defeitos de cada fonte estão em `catalogo-de-defeitos.md`.

## Inventário

| Fonte | Pasta | Arquivos | Grão | Situação |
|---|---|---|---|---|
| SPTrans — passageiros transportados, diário | `sptrans/2024/diario/` | 366 (um por dia de 2024; 243 `.xls`, 123 `.xlsx`) | dia × linha × empresa/lote | baixado |
| SPTrans — consolidado mensal | `sptrans/2024/mensal/` | 12 | jan–jun: dia × linha; jul–dez: mês × linha | baixado (só referência e amostra da Etapa 1) |
| SPTrans — totais mensais por grupo | `sptrans/referencia/totais_mensais.html` | 1 página (2013 a set/2026) | mês × grupo | baixado |
| Metrô — entradas diárias por estação, entrada por linha mensal | `metro/2024/` | — | dia × estação; mês × linha | **pendente**: portal em manutenção (HTTP 503) |
| CPTM — embarcados acumulados | `cptm/2024/` | — | mês × estação | **pendente**: download só pelo navegador |

Script de download: `01-excel/scripts/baixar_sptrans.py`. Perfil de layout: `01-excel/scripts/perfilar_sptrans.py` → `sptrans/2024/perfil_layout.csv`.

## SPTrans — arquivo diário

- **Formato**: Excel, uma aba. O formato real (BIFF `.xls` ou OOXML `.xlsx`) nem sempre bate com a extensão.
- **Cabeçalho**: em posição variável (linha 3 a 10). Acima dele fica um título de relatório.
- **Linhas**: de 1.097 a 1.540 linhas de dado por dia; 480.192 no ano (461.839 no grão dia × linha).
- **Unidade**: passageiros (contagem por validação).

| Coluna original | Tipo | Descrição |
|---|---|---|
| `Data` | data (texto `dd/mm/aaaa` nos `.xls`) | dia de operação |
| `Grupo` | texto | subsistema: Estrutural, Local de Articulação Regional, Local de Distribuição (com e sem acento) ou `OUTRO PC` |
| `Lote` | texto | lote de concessão (`E0x`, `AR…`, `D0x`, `D1x`; numérico em `OUTRO PC`) |
| `Empresa` | texto | operadora (às vezes um código numérico) |
| `Linha` | texto | `CÓDIGO - NOME`; o código sem hífen (`917M10`) corresponde ao letreiro `917M-10` |
| `Passageiros Pagtes Em Dinheiro` | inteiro | pagantes em dinheiro |
| `Passageiros Comum e VT` | inteiro | Bilhete Único comum e vale-transporte |
| `Passageiros Pgts Bu Comum M` | inteiro | Bilhete Único comum mensal |
| `Passageiros Pagtes Estudante` | inteiro | estudante pagante |
| `Passageiros Pgts Bu Est Mensal` | inteiro | estudante mensal |
| `Passageiros Pgts Bu Vt Mensal` | inteiro | vale-transporte mensal |
| `Passageiros Pagantes` | inteiro | soma dos pagantes |
| `Passageiros Int Ônibus->Ônibus` | inteiro | integrações ônibus → ônibus (não pagam de novo) |
| `Passageiros Com Gratuidade` | inteiro | gratuidades (idosos, PcD etc.) |
| `Passageiros Com Gratuidade Est` | inteiro | gratuidade estudantil |
| `Tot Passageiros Transportados` | inteiro | total = pagantes + integração + gratuidades (identidade confirmada na amostra) |

## SPTrans — totais mensais por grupo (referência)

Página HTML com uma tabela por ano. Colunas: `MÊS` (`Jan/24`), `Grupo Estrutural`, `Grupo Local de Articulação Regional`, `Grupo Local de Distribuição` e `Total`, com ponto de milhar e uma linha "Total" no fim. Encoding Latin-1. 2024: 2.160.850.434 passageiros no ano; jan/24 = 157.927.773.

## Formato-alvo das tabelas tratadas (Etapa 2)

| Tabela | Colunas | Chave |
|---|---|---|
| `Fato_Transporte` | `data` (data), `id_linha` (texto, ex. `ONI-917M-10`), `modalidade` (texto), `passageiros` (inteiro), `pagantes`, `integracao`, `gratuidades` (inteiros), `tipo_metrica` (`transportados`), `origem_dado` (`real`) | `data` + `id_linha` |
| `Fato_Referencia_Mensal` | `mes_inicio` (data, dia 1), `grupo` (texto), `passageiros_publicado` (inteiro), `origem_dado` | `mes_inicio` + `grupo` |
| `Dim_Transporte` | `id_linha`, `codigo_linha`, `nome_linha`, `modalidade`, `grupo`, `lote` | `id_linha` |
| `Dim_Grupo` | `grupo`, `modalidade`, `ordem` | `grupo` |
| `Rejeitados` | `fonte`, `arquivo`, `linha_origem`, `motivo`, `valor_original` | — |
