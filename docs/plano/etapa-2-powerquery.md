# Etapa 2 — Power Query

Etapa do professor: aulas 4–5. Entrega em `MA2026-entrega-parcial/02-powerquery`. Marco no Linear: **Etapa 2 — Power Query**.

O que o professor exige está em `referencia-professor.md`. Em resumo:
- o Power Query lê as pastas inteiras de dados brutos de 2024 e os cadastros da Etapa 1;
- toda linha lida termina numa tabela tratada ou em `Rejeitados`, com motivo;
- `Conf_Reconciliacao` prova que lidas − aceitas − rejeitadas = 0.

Relacionamentos, DAX e macros ficam para as etapas seguintes.

Layout dos arquivos desta etapa:

```text
MA2026-entrega-parcial/02-powerquery/
├── cheiU_02_PowerQuery.xlsx   # todas as consultas Power Query
├── scripts_m/                 # um .pq por consulta (fonte da verdade), 1ª linha "// <Consulta>"
├── dados_limpos/              # tabelas de saída em CSV UTF-8
├── evidencias/                # prints do painel de consultas, etapas aplicadas e conferência
├── scripts/                   # ExcelCom.psm1 (E0.7)
└── README.md
```

Grupos de consultas no Editor:
- `01_Parametros`: `pCaminhoRepo` e os caminhos derivados dele;
- `02_Origem`: `stg_*_Bruto`, somente conexão;
- `03_Cadastros`: `cad_Etapa1`, `cad_*`, `lst_*`, somente conexão;
- `04_Tratamento`: `stg_*`, somente conexão;
- `05_Saida`: `Fato_*`, `Dim_*`, `Rejeitados`, carregadas em planilha;
- `06_Conferencia`: `Conf_*`.

### E2.0 — Refinar o plano da Etapa 2
- **Resp.** Luciano · Docs · **Depende de** E1.7
- **Objetivo**: ajustar os passos ao que a Etapa 1 encontrou (catálogo de defeitos, amostra) e conferir de novo contra `docs/professor/guia-etapa-2-powerquery.pdf`.
- **Aceite**: este arquivo e as issues E2.x refletem o método real; cada defeito do catálogo marcado "Power Query" tem um passo aqui.

### E2.1 — Parâmetros e cadastros da Etapa 1
- **Resp.** Luciano · Power Query · **Depende de** E2.0
- **Objetivo**: caminhos trocáveis num lugar só e cadastros reaproveitados da Etapa 1, sem redigitar.
- **Saídas**: consultas e `.pq` de:
  - `pCaminhoRepo`: lê a célula nomeada `CaminhoRepo` (`Excel.CurrentWorkbook`);
  - `pPastaSPTrans`, `pPastaMetro`, `pPastaCPTM`, `pArquivoOD`, `pArquivoEtapa1`, todos derivados de `pCaminhoRepo`;
  - `cad_Etapa1`, que lê `01-excel/cheiU_01_Excel.xlsx`;
  - `cad_*`, um por cadastro, com chave em maiúsculas sem espaços nas pontas;
  - `lst_*`, as listas de valores válidos.
- **Configuração**: localidade Português (Brasil); privacidade "Ignorar os Níveis de Privacidade" (todas as origens são arquivos da equipe).
- **Aceite**: mudar só `CaminhoRepo` e "Atualizar Tudo" funciona noutro clone; `Formula.Firewall` não aparece.

### E2.2 — SPTrans diário
- **Resp.** Luciano · Power Query · **Depende de** E1.1, E2.1
- **Objetivo**: `stg_sptrans_diario` limpo, com uma linha por dia × linha de ônibus.
- **Saídas**: as consultas `stg_SPTrans_Bruto`, `fnLerSPTrans` e `stg_sptrans_diario`, com os `.pq` em `scripts_m/`.
- **Passos**:
  1. `Folder.Files(pPastaSPTrans)`, filtrando `.xls` e `.xlsx`.
  2. A função `fnLerSPTrans` pula as linhas até o cabeçalho (linha 4), promove os cabeçalhos e padroniza os nomes de coluna entre meses por um de-para de colunas. `Conf_Colunas` lista colunas não mapeadas.
  3. Separar `codigo_linha` (normalizado para o letreiro, ex. `917M-10`) de `nome_linha`.
  4. Remover linhas de total e subtotal (motivo registrado em `Rejeitados`), tipar as colunas com `"pt-BR"` e agrupar por data × linha, somando as empresas.
  5. Colunas finais: `data`, `grupo`, `lote`, `codigo_linha`, `nome_linha`, `passageiros_total`, `pagantes`, `gratuidades`, `integracao_onibus`.
- **Aceite**: zero duplicatas no grão; `Conf_Colunas` vazia; a soma mensal de `passageiros_total` bate com os totais mensais do sistema publicados pela SPTrans (tolerância 0,5%).
- **Validar**: tabela de reconciliação mês × (calculado, publicado, diferença %) anexada à issue.

### E2.3 — Metrô
- **Resp.** Luciano · Power Query · **Depende de** E1.2, E2.1
- **Objetivo**: entradas diárias por estação e mensais por linha, em formato longo.
- **Saídas**: `stg_metro_entradas_diarias` (data, código da estação, linha, entradas) e `stg_metro_mensal_linha` (mês, linha, total, MDU, MSA, MDO, MAX), mais os `.pq`.
- **Passos**: ler o CSV como Latin-1 (1252), separador `;` e vírgula decimal; despivotar os blocos mês/linha × colunas de estação; multiplicar por 1.000; casar estações com `cad_Estacao` pelo de-para (sem correspondência → `Rejeitados`).
- **Aceite**: 366 dias × todas as estações das L1/L2/L3/L15; a soma diária por linha e mês bate com a "Entrada por Linha" mensal (tolerância 1%).
- **Validar**: tabela de reconciliação linha × mês anexada.

### E2.4 — CPTM com estimativa diária
- **Resp.** Luciano · Power Query · **Depende de** E1.2, E2.1, E2.3
- **Objetivo**: embarcados mensais por estação e uma estimativa diária por linha.
- **Saídas**: `stg_cptm_mensal_estacao` e `stg_cptm_diario_estimado` (`origem_dado = estimado`), mais os `.pq`.
- **Passos**:
  1. Combinar os xlsx mensais e padronizar nomes de estação e linha conforme `cad_Estacao`.
  2. Calcular os pesos por tipo de dia a partir das razões MSA/MDU e MDO/MDU do Metrô em 2024 (feriado conta como domingo). O valor final é gravado em `Param_Pesos_Tipo_Dia` na Etapa 1 (correção na origem).
  3. Distribuir o total mensal de cada linha pelos dias do mês: total × peso do dia ÷ soma dos pesos do mês.
- **Aceite**: a soma diária estimada de cada mês é igual ao total mensal publicado; todas as estações estão mapeadas.
- **Validar**: diferença máxima entre a soma estimada e o publicado = 0 (arredondamento à parte).

### E2.5 — Viagens da OD 2023
- **Resp.** Luciano · Power Query · **Depende de** E1.3, E2.1
- **Objetivo**: viagens com modalidade, cadeia modal, hora e região padronizadas.
- **Saídas**: `stg_od_viagens`, mais o `.pq`.
- **Passos**:
  1. Decodificar `MODO1`–`MODO4` com `cad_Modo_OD`.
  2. Montar `cadeia_modal` com as modalidades coletivas em ordem, sem repetir consecutivas (ex. "Ônibus → Metrô").
  3. `hora_saida` = `H_SAIDA`.
  4. Regiões de origem e destino via `od2023_zonas.csv` → distrito → `cad_Distrito_Regiao` (fora da capital: "Outros municípios").
  5. Manter `FE_VIA` e `DURACAO`.
- **Aceite**: a soma de `FE_VIA` é igual à de E1.3; nenhuma viagem coletiva fica sem região; as 10 cadeias mais frequentes estão listadas na issue.
- **Validar**: tabela com a contagem por cadeia e por região de origem.

### E2.6 — `Fato_Perfil_Horario`
- **Resp.** Luciano · Power Query, Dados · **Depende de** E2.5
- **Objetivo**: quanto cada hora representa no total diário de cada modalidade.
- **Passos**:
  1. Para cada modalidade (Ônibus, Metrô, Trem), considerar as viagens da OD que usam a modalidade em qualquer etapa.
  2. Somar `FE_VIA` por `hora_saida`. Todas as etapas recebem a hora de saída da viagem, por aproximação; registre isso.
  3. Participação = soma da hora ÷ soma do dia. Tipo de dia Útil, `origem_dado = estimado`.
  4. Fim de semana conforme a premissa decidida no E2.0, `origem_dado = simulado`.
  5. Comparar a curva com a do Relatório Síntese da OD. Se os picos caírem fora das faixas, corrigir `Param_Faixas_Horarias` na Etapa 1.
- **Aceite**: a soma das participações dá 1,000 (±0,0001) em cada modalidade × tipo de dia; os picos coincidem com o Relatório Síntese.
- **Validar**: gráfico das três curvas anexado à issue (fora da pasta de trabalho).

### E2.7 — `Fato_Viagem_OD` e `Dim_Cadeia_Modal`
- **Resp.** Luciano · Power Query · **Depende de** E2.5
- **Saídas**:
  - `Fato_Viagem_OD`: `hora_saida`, `id_cadeia`, `regiao_origem`, `regiao_destino`, `viagens_expandidas` (soma de `FE_VIA`), `duracao_media_min` (ponderada por `FE_VIA`), `n_amostra`;
  - `Dim_Cadeia_Modal`: `id_cadeia`, `descricao`, `n_etapas`, `usa_onibus`, `usa_metro`, `usa_trem`, `alternativa_alvo` (marca "Ônibus → Metrô" e "Ônibus → Trem").
- **Aceite**:
  - a soma de `viagens_expandidas` é igual ao total de viagens coletivas da OD;
  - células com `n_amostra` < 30 vêm marcadas como baixa confiabilidade.

### E2.8 — `Fato_Oferta`
- **Resp.** Luciano · Power Query, Dados · **Depende de** E0.5, E2.1, E2.9
- **Objetivo**: capacidade ofertada por hora, base da lotação. É o nosso "esperado" (papel de `fMetas` no CaféData).
- **Passos**:
  1. Do GTFS (`frequencies`, `trips`, `routes`, `calendar`), calcular viagens programadas por hora × linha × tipo de dia.
  2. Casar `route_short_name` com `Dim_Transporte`; sem correspondência → `Rejeitados`.
  3. Se o GTFS não trouxer Metrô e CPTM, usar headways oficiais por faixa (`Param_Headway_Trilhos` na Etapa 1, `origem_dado = simulado`, com a fonte citada).
  4. Validar `Param_Capacidade` com fontes (SPTrans por tipo de veículo; Metrô e CPTM por trem) e registrar a premissa de capacidade dos ônibus decidida no E2.0.
  5. Documentar a limitação: GTFS de 2026 aplicado a 2024.
- **Plano B**: se E0.5 ainda não estiver pronto, montar a oferta inteira por headway parametrizado (`simulado`) e trocar pelo GTFS quando chegar.
- **Aceite**: toda linha com demanda tem oferta em toda hora com serviço, ou é marcada `sem_oferta`; todo parâmetro cita a fonte ou diz "premissa".

### E2.9 — Consolidação, `Rejeitados` e conferência
- **Resp.** Luciano · Power Query · **Depende de** E2.2, E2.3, E2.4
- **Objetivo**: a tabela fato principal, as dimensões de rede e a prova de que nenhuma linha sumiu.
- **Saídas**:
  - `Fato_Transporte`, com colunas `data`, `id_linha`, `modalidade`, `passageiros`, `tipo_metrica`, `origem_dado`;
  - `Dim_Transporte`, com `id_linha`, `codigo`, `nome`, `modalidade`, `operador`, `grupo`, `regiao`;
  - `Dim_Localizacao`, com estações, distrito e região;
  - `Rejeitados`: `fonte`, `arquivo`, `linha_origem`, `motivo`, valores originais, para toda linha descartada em E2.2–E2.5 (o E2.8, que depende de `Dim_Transporte`, acrescenta as suas depois);
  - `Conf_Reconciliacao`: por fonte, linhas lidas, aceitas, rejeitadas e diferença;
  - `Conf_Motivos`: rejeitados por fonte × motivo;
  - `Conf_Colunas`: colunas não mapeadas;
  - `Conf_Etapas`: contagem de linhas etapa por etapa;
  - os `.pq` de cada uma.
- **Passos**: unir SPTrans (Ônibus, transportados, real), Metrô somado por linha (Metrô, entradas, real) e CPTM estimado (Trem, embarcados, estimado); gerar `id_linha` estável (ex. `ONI-917M-10`, `MET-L3`, `TRM-L11`). Mantenha também a demanda por estação em staging: o E3.0 decide se ela vira uma fato própria para analisar região nos trilhos.
- **Aceite**:
  - o grão (data, `id_linha`) não tem duplicatas;
  - todo `id_linha` do fato existe em `Dim_Transporte`;
  - `origem_dado` nunca é nulo;
  - `Conf_Reconciliacao` com diferença 0 em todas as fontes;
  - cada motivo de `Conf_Motivos` explicado no README.
- **Validar**: contagem de linhas por modalidade × `origem_dado`; teste de chave órfã com resultado vazio; print da `Conf_Reconciliacao`.

### E2.10 — QA da Etapa 2
- **Resp.** Maryele · QA · **Depende de** E2.6, E2.7, E2.8, E2.9
- **Objetivo**: checagem independente de tudo que a etapa produziu.
- **Saídas**: `MA2026-entrega-parcial/04-documentacao/qa/etapa-2.md`: a tabela de conferência do Guia da Etapa 2 adaptada (item, esperado, como verificar, obtido, status).
- **Passos**:
  1. Refazer as reconciliações dos passos E2.2–E2.9.
  2. Conferir nulos em chaves, duplicatas no grão, cobertura de datas (todo dia de 2024 nas fontes diárias) e tipos de coluna.
  3. Sortear 2 linhas tratadas e achá-las no bruto.
  4. Teste de reenvio: com uma cópia de um arquivo extra na pasta, as contagens mudam e voltam ao retirá-lo.
- **Aceite**: toda checagem está OK ou tem exceção justificada; escopo respeitado (sem relacionamentos, DAX ou macro).

### E2.11 — Publicação da Etapa 2
- **Resp.** Luciano · Power Query, Docs · **Depende de** E2.10
- **Objetivo**: entregar a etapa versionada e reproduzível, na forma que o guia pede.
- **Saídas**:
  - `.pq` de todas as consultas em `scripts_m/`, primeira linha `// <Consulta>`;
  - `dados_limpos/<Tabela>.csv` (UTF-8) para cada tabela de `05_Saida`. Tabela com mais de 25 MB segue a decisão 0008: versiona-se o script que a gera, e o CSV fica fora do Git;
  - `evidencias/` com o painel de consultas com grupos, as etapas aplicadas de `Fato_Transporte` e a `Conf_Reconciliacao`;
  - `README.md` com consultas, parâmetros, regras de rejeição, pendências e como configurar `CaminhoRepo` e atualizar.
- **Aceite**:
  - o número de `.pq` é igual a `Workbook.Queries.Count`, e o texto de cada um é idêntico ao da pasta de trabalho (comparação por script, E0.7);
  - outra pessoa clona, define `CaminhoRepo` e atualiza sem erro.
- **Validar**: saída do script de comparação; entrada em `memories/progresso.md`.
