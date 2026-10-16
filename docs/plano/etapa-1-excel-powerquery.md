# Etapa 1 — Excel e Power Query

Entregável do professor (aula 5): planilha limpa e tratada em `01-excel` e `02-powerquery`. Marco no Linear: **Etapa 1 — Excel e Power Query**.

Layout dos arquivos desta etapa:

```text
MA2026-entrega-parcial/
├── 01-excel/
│   ├── cheiU_cadastros.xlsx      # Excel avançado: cadastros, parâmetros, auditoria
│   ├── dados-brutos/             # sptrans/ metro/ cptm/ od2023/ gtfs/ + manifesto.csv
│   └── scripts/                  # Python de aquisição + requirements.txt
└── 02-powerquery/
    ├── cheiU_tratamento.xlsx     # todas as consultas Power Query
    ├── consultas/                # um .pq por consulta (fonte da verdade)
    └── scripts/                  # ExcelCom.psm1 (E0.7)
```

### E1.0 — Refinar o plano da Etapa 1
- **Resp.** Luciano · Docs · **Depende de** E0.6, E0.7
- **Objetivo**: ajustar os passos abaixo ao que E0.6/E0.7 revelaram (o que dá para automatizar via COM e o que exige GUI).
- **Aceite**: este arquivo e as issues E1.x refletem o método real de trabalho; mudanças registradas em `memories/progresso.md`.

### E1.1 — Baixar passageiros transportados da SPTrans (2024)
- **Resp.** Luciano · Python, Dados · **Depende de** E0.6
- **Objetivo**: ter todos os dias de 2024 em `dados-brutos/sptrans/2024/`.
- **Saídas**:
  - `scripts/baixar_sptrans.py`;
  - `dados-brutos/sptrans/2024/{diario,mensal}/`;
  - linhas no `dados-brutos/manifesto.csv` (`fonte, url, arquivo, tamanho_bytes, sha256, baixado_em`).
- **Passos**:
  1. Extrair da página de 2024 (padrão em `memories/fontes-de-dados.md`) os links de arquivos `.xls` e `.xlsx`.
  2. Baixar um consolidado mensal e inspecionar. Se ele trouxer dia × linha, usar só os 12 consolidados e registrar a escolha em `memories/fontes-de-dados.md`; senão, baixar os diários.
  3. O script pula arquivos que já existem com o mesmo sha256 (idempotente) e lista os dias faltantes no fim.
- **Aceite**: os 366 dias de 2024 estão cobertos (2024 é bissexto), com o manifesto completo.
- **Validar**: saída do script com "0 dias faltantes"; abrir 3 arquivos sorteados e conferir a data.

### E1.2 — Baixar Metrô e CPTM (2024)
- **Resp.** Luciano · Python, Dados · **Depende de** E0.6
- **Objetivo**: séries de 2024 do Metrô e da CPTM em `dados-brutos/`.
- **Saídas**:
  - `scripts/baixar_metro.py` e `scripts/baixar_cptm.py`;
  - em `dados-brutos/metro/2024/`: entradas diárias por estação (12 meses), passageiros transportados por linha, entradas por linha;
  - em `dados-brutos/cptm/2024/`: embarcados acumulados, xlsx mensais extraídos dos zips.
- **Aceite**: 12 meses de cada série, com o manifesto atualizado.
- **Validar**: contagem de arquivos por série = 12; abrir um arquivo de cada série e conferir mês e linhas.

### E1.3 — Baixar e converter a Pesquisa OD 2023
- **Resp.** Luciano · Python, Dados · **Depende de** E0.6
- **Objetivo**: viagens da OD e tabela de zonas em CSV legível pelo Power Query.
- **Saídas**:
  - `scripts/baixar_od2023.py` e `scripts/converter_od2023.py`;
  - `dados-brutos/od2023/od2023_viagens.csv`;
  - `dados-brutos/od2023/od2023_zonas.csv` (zona → distrito → município, a partir do `.dbf` do shapefile);
  - cópia do dicionário `Layout_BD_OD2023` e das `Tabelas_Site_OD2023` (xlsx) para reconciliar;
  - o zip original (198 MB) fica em `od2023/_zip/`, fora do Git.
- **Passos**:
  1. Ler `Banco2023_divulgacao_190225.dbf` com `dbfread`.
  2. Manter só os campos usados: `ZONA_O`, `ZONA_D`, `MUNI_O`, `MUNI_D`, `H_SAIDA`, `MIN_SAIDA`, `H_CHEG`, `MIN_CHEG`, `DURACAO`, `ANDA_O`, `ANDA_D`, `MODO1`–`MODO4`, `MODOPRIN`, `MOTIVO_O`, `MOTIVO_D`, `FE_VIA`, `DIA_SEM`, mais os identificadores de pessoa/viagem que o dicionário indicar.
  3. Gravar em CSV UTF-8, separador `,`, decimal `.`.
- **Aceite**: o CSV tem menos de 25 MB, e a soma de `FE_VIA` dos registros com viagem bate com o total de viagens do Relatório Síntese (tolerância 1%).
- **Validar**: o script imprime o número de registros e a soma de `FE_VIA`; comparar com a tabela oficial.

### E1.4 — Inventário e dicionário dos dados brutos
- **Resp.** Luciano · Docs, Dados · **Depende de** E1.1, E1.2, E1.3
- **Objetivo**: documentar cada família de arquivo antes de tratar.
- **Saídas**: `MA2026-entrega-parcial/04-documentacao/dicionario-de-dados.md` e pegadinhas novas em `memories/fontes-de-dados.md`.
- **Passos**: para cada fonte, registrar colunas, tipos, unidade (o Metrô publica em milhares), encoding, linha do cabeçalho, variações de layout entre meses e anomalias com o tratamento previsto.
- **Aceite**: toda fonte de E1.1–E1.3 tem entrada, e toda anomalia aponta o passo que a trata.

### E1.5 — Cadastros e parâmetros em Excel avançado
- **Resp.** Nicolly · Excel · **Depende de** E1.4
- **Objetivo**: tabelas de apoio feitas à mão, com fórmulas auditadas (exigência "Excel avançado, PROCX, auditoria" do professor).
- **Saídas**: `01-excel/cheiU_cadastros.xlsx`, com estas Tabelas do Excel (ListObjects):
  - `Cad_Linha_Trilho`: L1, L2, L3, L15, L7, L10, L11, L12, L13 — nome, cor, operador, modalidade;
  - `Cad_Estacao`: código na fonte, nome, linha, modalidade, município, distrito, e região via `PROCX` em `Cad_Distrito_Regiao`;
  - `Cad_Distrito_Regiao`: os 96 distritos de SP → Centro/Norte/Sul/Leste/Oeste, com a fonte citada;
  - `Cad_Area_SPTrans_Regiao`: lote ou área operacional SPTrans → região (pesquisar a correspondência e registrar em `memories/fontes-de-dados.md`);
  - `Cad_Modo_OD`: códigos 01–17 da OD → modalidade padronizada (03 Monotrilho → Metrô; códigos não coletivos → "Outros");
  - `Cad_Feriados_2024`: feriados nacionais, 25/01 e 09/07;
  - `Param_Capacidade`, `Param_Faixas_Lotacao` (Baixa < 50%, Média 50–80%, Alta 80–100%, Muito alta > 100%), `Param_Faixas_Horarias`, `Param_Pesos_Tipo_Dia`;
  - célula nomeada `CaminhoRepo`;
  - aba `Auditoria`, que conta erros de fórmula (`SEERRO`/`ÉERROS`), duplicatas de chave (`CONT.SE`) e células obrigatórias vazias.
- **Aceite**:
  - a aba `Auditoria` mostra zero em todas as checagens;
  - toda estação presente nos arquivos de 2024 do Metrô e da CPTM tem linha em `Cad_Estacao` e região preenchida;
  - os parâmetros citam a fonte ou dizem "premissa".
- **Validar**: print da aba `Auditoria`; uma consulta rápida (Power Query ou script) lista as estações das fontes que faltam no cadastro e o resultado é vazio.

### E1.6 — Power Query: SPTrans diário
- **Resp.** Luciano · Power Query · **Depende de** E1.1, E1.5
- **Objetivo**: `stg_sptrans_diario` limpo, com uma linha por dia × linha de ônibus.
- **Saídas**: em `02-powerquery/cheiU_tratamento.xlsx`, as consultas `fnLerSPTrans` e `stg_sptrans_diario`, com os `.pq` correspondentes em `consultas/`.
- **Passos**:
  1. `Folder.Files` a partir de `CaminhoRepo`, filtrando `.xls` e `.xlsx`.
  2. A função `fnLerSPTrans` pula as linhas até o cabeçalho (linha 4), promove os cabeçalhos e padroniza os nomes de coluna entre meses.
  3. Separar `codigo_linha` (normalizado para o letreiro, ex. `917M-10`) de `nome_linha`.
  4. Remover linhas de total e subtotal, tipar as colunas e agrupar por data × linha, somando as empresas.
  5. Colunas finais: `data`, `grupo`, `lote`, `codigo_linha`, `nome_linha`, `passageiros_total`, `pagantes`, `gratuidades`, `integracao_onibus`.
- **Aceite**: zero duplicatas no grão; a soma mensal de `passageiros_total` bate com os totais mensais do sistema publicados pela SPTrans (tolerância 0,5%).
- **Validar**: tabela de reconciliação mês × (calculado, publicado, diferença %) anexada à issue.

### E1.7 — Power Query: Metrô
- **Resp.** Luciano · Power Query · **Depende de** E1.2, E1.5
- **Objetivo**: entradas diárias por estação e mensais por linha, em formato longo.
- **Saídas**: `stg_metro_entradas_diarias` (data, código da estação, linha, entradas) e `stg_metro_mensal_linha` (mês, linha, total, MDU, MSA, MDO, MAX), mais os `.pq`.
- **Passos**: ler o CSV como Latin-1 (1252), separador `;` e vírgula decimal; despivotar os blocos mês/linha × colunas de estação; multiplicar por 1.000; casar estações com `Cad_Estacao`.
- **Aceite**: 366 dias × todas as estações das L1/L2/L3/L15; a soma diária por linha e mês bate com a "Entrada por Linha" mensal (tolerância 1%).
- **Validar**: tabela de reconciliação linha × mês anexada.

### E1.8 — Power Query: CPTM com estimativa diária
- **Resp.** Luciano · Power Query · **Depende de** E1.2, E1.5, E1.7
- **Objetivo**: embarcados mensais por estação e uma estimativa diária por linha.
- **Saídas**: `stg_cptm_mensal_estacao` e `stg_cptm_diario_estimado` (`origem_dado = estimado`), mais os `.pq`.
- **Passos**:
  1. Combinar os xlsx mensais e padronizar nomes de estação e linha conforme `Cad_Estacao`.
  2. Calcular `Param_Pesos_Tipo_Dia` a partir das razões MSA/MDU e MDO/MDU do Metrô em 2024 (feriado conta como domingo).
  3. Distribuir o total mensal de cada linha pelos dias do mês: total × peso do dia ÷ soma dos pesos do mês.
- **Aceite**: a soma diária estimada de cada mês é igual ao total mensal publicado; todas as estações estão mapeadas.
- **Validar**: diferença máxima entre a soma estimada e o publicado = 0 (arredondamento à parte).

### E1.9 — Power Query: viagens da OD 2023
- **Resp.** Luciano · Power Query · **Depende de** E1.3, E1.5
- **Objetivo**: viagens com modalidade, cadeia modal, hora e região padronizadas.
- **Saídas**: `stg_od_viagens`, mais o `.pq`.
- **Passos**:
  1. Decodificar `MODO1`–`MODO4` com `Cad_Modo_OD`.
  2. Montar `cadeia_modal` com as modalidades coletivas em ordem, sem repetir consecutivas (ex. "Ônibus → Metrô").
  3. `hora_saida` = `H_SAIDA`.
  4. Regiões de origem e destino via `od2023_zonas.csv` → distrito → `Cad_Distrito_Regiao` (fora da capital: "Outros municípios").
  5. Manter `FE_VIA` e `DURACAO`.
- **Aceite**: a soma de `FE_VIA` é igual à de E1.3; nenhuma viagem coletiva fica sem região; as 10 cadeias mais frequentes estão listadas na issue.
- **Validar**: tabela com a contagem por cadeia e por região de origem.

### E1.10 — Power Query: consolidação de `Fato_Transporte` e dimensões
- **Resp.** Luciano · Power Query · **Depende de** E1.6, E1.7, E1.8
- **Objetivo**: a tabela fato principal e as dimensões de rede.
- **Saídas**:
  - `Fato_Transporte`, com colunas `data`, `id_linha`, `modalidade`, `passageiros`, `tipo_metrica`, `origem_dado`;
  - `Dim_Transporte`, com `id_linha`, `codigo`, `nome`, `modalidade`, `operador`, `grupo`, `regiao`;
  - `Dim_Localizacao`, com estações, distrito e região;
  - os `.pq` de cada uma.
- **Passos**: unir SPTrans (Ônibus, transportados, real), Metrô somado por linha (Metrô, entradas, real) e CPTM estimado (Trem, embarcados, estimado); gerar `id_linha` estável (ex. `ONI-917M-10`, `MET-L3`, `TRM-L11`). Mantenha também a demanda por estação em staging: o E2.0 decide se ela vira uma fato própria para analisar região nos trilhos.
- **Aceite**: o grão (data, `id_linha`) não tem duplicatas; todo `id_linha` do fato existe em `Dim_Transporte`; `origem_dado` nunca é nulo.
- **Validar**: contagem de linhas por modalidade × `origem_dado`; teste de chave órfã com resultado vazio.

### E1.11 — QA da Etapa 1
- **Resp.** Maryele · QA · **Depende de** E1.10
- **Objetivo**: checagem independente de tudo que a etapa produziu.
- **Saídas**: `MA2026-entrega-parcial/04-documentacao/qa/etapa-1.md`, uma tabela com checagem, esperado, obtido e status.
- **Passos**: refazer as reconciliações dos passos E1.6–E1.9; conferir nulos em chaves, duplicatas no grão, cobertura de datas (todo dia de 2024 nas fontes diárias), tipos de coluna e a aba `Auditoria` de E1.5.
- **Aceite**: toda checagem está OK ou tem exceção justificada.

### E1.12 — Fechamento da Etapa 1
- **Resp.** Luciano · Power Query, Docs · **Depende de** E1.11
- **Objetivo**: entregar a etapa versionada e reproduzível.
- **Saídas**:
  - `.pq` de todas as consultas em `02-powerquery/consultas/`;
  - `README.md` de `01-excel` e `02-powerquery` atualizados (como configurar `CaminhoRepo` e atualizar);
  - consultas grandes carregadas como "somente conexão".
- **Aceite**:
  - o número de `.pq` é igual a `Workbook.Queries.Count`, e o texto de cada um é idêntico ao da pasta de trabalho (comparação por script, E0.7);
  - outra pessoa clona, define `CaminhoRepo` e atualiza sem erro.
- **Validar**: saída do script de comparação; entrada em `memories/progresso.md`.
