# Etapa 1 — Excel avançado

Etapa do professor: aulas 2–3. Entrega em `MA2026-entrega-parcial/01-excel`. Marco no Linear: **Etapa 1 — Excel**.

O que o professor exige está em `referencia-professor.md`. Em resumo:
- uma planilha bruta vira base auditável com fórmulas, sem sobrescrever nenhum valor original;
- os problemas que fórmula não resolve vão para a aba `Auditoria`.

Nesta etapa também baixamos as fontes de 2024, que o Power Query da Etapa 2 vai ler por inteiro. A Etapa 1 trabalha numa **amostra de um mês** (`memories/decisoes/0008`). Power Query, DAX e macros ficam para as etapas seguintes.

Layout dos arquivos desta etapa:

```text
MA2026-entrega-parcial/01-excel/
├── cheiU_01_Excel.xlsx       # abas Bruto, Tratado, Cadastros, Auditoria
├── dados-brutos/             # sptrans/ metro/ cptm/ od2023/ gtfs/ + manifesto.csv
├── scripts/                  # Python de aquisição + requirements.txt
└── README.md
MA2026-entrega-parcial/04-documentacao/
├── ficha-do-projeto.md
├── dicionario-de-dados.md
└── catalogo-de-defeitos.md
```

### E1.0 — Refinar o plano da Etapa 1
- **Resp.** Luciano · Docs · **Depende de** E0.6, E0.7
- **Objetivo**: ajustar os passos abaixo ao que E0.6/E0.7 revelaram (o que dá para automatizar via COM e o que exige GUI) e conferir de novo contra `docs/professor/guia-etapa-1-excel.pdf`.
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

### E1.4 — Inventário, dicionário, catálogo de defeitos e ficha do projeto
- **Resp.** Luciano · Docs, Dados · **Depende de** E1.1, E1.2, E1.3
- **Objetivo**: documentar e diagnosticar cada família de arquivo antes de tratar, e preencher a ficha do projeto que a Parcial 1 cobra.
- **Saídas** em `MA2026-entrega-parcial/04-documentacao/`:
  - `dicionario-de-dados.md`: para cada fonte, colunas, tipos, unidade (o Metrô publica em milhares), encoding, linha do cabeçalho e variações de layout entre meses; mais o formato-alvo de cada tabela tratada;
  - `catalogo-de-defeitos.md`: tabela D1..Dn no formato do professor (defeito, exemplo real com arquivo e linha, fonte, como cada etapa trata: Excel, Power Query, não tratar). Exemplos esperados:
    - cabeçalho fora da linha 1;
    - código e nome da linha na mesma célula;
    - linhas de total e subtotal;
    - valores em milhares;
    - colunas que mudam entre meses;
    - nomes de estação com grafias diferentes;
    - CPTM só mensal;
  - `ficha-do-projeto.md`: os 9 campos da ficha do professor (Contexto, Pergunta central, Fontes, Dados utilizados, KPIs com a pergunta que cada um responde, Dados externos/API, Automação VBA, Banco/SQL, Resultado no Power BI), mais a tabela de correspondência CaféData → cheiU (fato, dimensões, KPI análogo, API análoga);
  - pegadinhas novas em `memories/fontes-de-dados.md`.
- **Aceite**: toda fonte de E1.1–E1.3 tem entrada no dicionário; todo defeito do catálogo aponta a etapa e o passo que o trata; a ficha não tem campo vazio.

### E1.5 — Aba `Cadastros`: cadastros, de-para e parâmetros
- **Resp.** Nicolly · Excel · **Depende de** E1.4
- **Objetivo**: tabelas de apoio feitas à mão, com fórmulas auditadas, na aba `Cadastros` de `cheiU_01_Excel.xlsx`. O Power Query da Etapa 2 vai lê-las por `cad_Etapa1`.
- **Saídas**: em `01-excel/cheiU_01_Excel.xlsx`, aba `Cadastros`, estas Tabelas do Excel (ListObjects), com uma coluna vazia entre elas:
  - `Cad_Linha_Trilho`: L1, L2, L3, L15, L7, L10, L11, L12, L13 — nome, cor, operador, modalidade;
  - `Cad_Estacao`: código na fonte, nome, linha, modalidade, município, distrito, e região via `PROCX` em `Cad_Distrito_Regiao`;
  - `Cad_Distrito_Regiao`: os 96 distritos de SP → Centro/Norte/Sul/Leste/Oeste, com a fonte citada;
  - `Cad_Area_SPTrans_Regiao`: lote ou área operacional SPTrans → região (pesquisar a correspondência e registrar em `memories/fontes-de-dados.md`);
  - `Cad_DePara_Estacao`: grafias de estação encontradas nas fontes → código oficial. Só entram grafias confirmadas;
  - `Cad_Modo_OD`: códigos 01–17 da OD → modalidade padronizada (03 Monotrilho → Metrô; códigos não coletivos → "Outros");
  - `Cad_Feriados_2024`: feriados nacionais, 25/01 e 09/07;
  - `Param_Capacidade`, `Param_Faixas_Lotacao` (Baixa < 50%, Média 50–80%, Alta 80–100%, Muito alta > 100%), `Param_Faixas_Horarias`, `Param_Pesos_Tipo_Dia`;
  - listas de valores válidos (`Tab_Modalidade`, `Tab_Grupo_SPTrans`, `Tab_Regiao`, `Tab_Situacao`) com nomes `Lista_*` no Gerenciador de Nomes;
  - célula nomeada `CaminhoRepo`.
- **Aceite**:
  - toda estação presente nos arquivos de 2024 do Metrô e da CPTM tem linha em `Cad_Estacao` e região preenchida;
  - nenhuma chave duplicada nos cadastros (`CONT.SE` > 1 = 0);
  - os parâmetros citam a fonte ou dizem "premissa".
- **Validar**: contagens `LINS()` de cada tabela anotadas no README; uma consulta rápida (Power Query ou script) lista as estações das fontes que faltam no cadastro e o resultado é vazio.

### E1.6 — Base auditável da amostra (Bruto, Tratado, Auditoria)
- **Resp.** Nicolly · Excel · **Depende de** E1.4, E1.5
- **Objetivo**: reproduzir no nosso tema o roteiro do Guia da Etapa 1. Um arquivo bruto real de um mês vira base confiável e auditável só com fórmulas.
- **Amostra**: o consolidado SPTrans de janeiro/2024, se E1.1 confirmar que ele traz dia × linha. Senão, o CSV de entradas diárias por estação do Metrô de janeiro/2024. A escolha fica registrada no README.
- **Saídas** em `cheiU_01_Excel.xlsx`:
  - `Bruto`: cópia fiel do arquivo original, feita por Mover ou Copiar, sem nenhuma edição;
  - `Tratado`: tabela `Tab_Transporte`, com:
    - `Linha_Origem` digitada como valor fixo;
    - colunas originais;
    - colunas tratadas com sufixo `_Trat`: texto com ARRUMAR/PRI.MAIUSCULA, data convertida com LET e "Data inválida", código e nome da linha separados;
    - buscas `PROCX` no cadastro (região, grupo, modalidade) com retorno "Não cadastrado";
    - colunas auxiliares (mês, dia da semana, tipo de dia);
    - colunas `Status_*` (vazio/zero, linha de total, valor fora do esperado);
    - coluna `Problemas` com UNIRTEXTO;
  - validação de dados em lista nas colunas categóricas;
  - formatação condicional: valor vazio ou zero, desvio acima do limite e linha com problema;
  - `Auditoria`:
    - `Tab_Auditoria`: Linha_Origem, chave, Campo, Valor_Encontrado, Tipo_Problema, Acao_Necessaria, Situacao, Observacao;
    - painel Tipo × Detectado × Registrado × Diferença;
    - `SOMARPRODUTO(--ÉERROS(Tab_Transporte))`.
- **Regra de ouro**: nenhum valor original é apagado ou sobrescrito. O que fórmula não resolve vai para a auditoria com a ação necessária. Defeitos que o catálogo atribui ao Power Query (tipos, duplicatas, consolidar arquivos) são só registrados.
- **Aceite**:
  - painel com Diferença 0 em todos os tipos;
  - erros de fórmula 0;
  - colunas originais de `Tab_Transporte` idênticas às da aba `Bruto`;
  - duas linhas sorteadas do registro localizadas na aba `Bruto`.
- **Validar**: prints do painel, de Rastrear Precedentes numa coluna de busca e do Gerenciador de Nomes, salvos em `01-excel/evidencias/`.

### E1.7 — QA e fechamento da Etapa 1
- **Resp.** Maryele · QA, Docs · **Depende de** E1.5, E1.6
- **Objetivo**: conferência independente e entrega da etapa.
- **Saídas**:
  - `MA2026-entrega-parcial/04-documentacao/qa/etapa-1.md`: a tabela de conferência do Guia da Etapa 1 adaptada (item, resultado esperado, como verificar, valor obtido, status);
  - `01-excel/README.md`: abas, tabelas, amostra usada, pendências da auditoria e como configurar `CaminhoRepo`.
- **Aceite**:
  - nenhum item Não iniciado ou Em andamento;
  - itens Pendente de esclarecimento estão na `Tab_Auditoria` com a ação descrita;
  - o arquivo reabre sem aviso de vínculo externo;
  - o escopo foi respeitado (sem Power Query, DAX ou macro).
