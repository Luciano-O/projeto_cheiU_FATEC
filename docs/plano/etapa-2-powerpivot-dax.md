# Etapa 2 — Power Pivot e DAX

Entregável do professor (aula 7): modelo dimensional e DAX em `03-powerpivot`. Marco no Linear: **Etapa 2 — Power Pivot e DAX**.

Arquivos: `MA2026-entrega-parcial/03-powerpivot/cheiU_modelo.xlsx` (começa como cópia de `cheiU_tratamento.xlsx`, com as consultas carregadas no Modelo de Dados), `medidas.dax`, `modelo-diagrama.png` e `README.md`.

### E2.0 — Refinar o plano da Etapa 2
- **Resp.** Luciano · Docs · **Depende de** E1.12
- **Objetivo**: revisar o modelo-alvo com os dados reais em mãos.
- **Decisões a tomar e registrar**:
  - se a demanda por estação dos trilhos vira uma fato própria para analisar região;
  - se a capacidade dos ônibus é definida por grupo SPTrans ou por linha;
  - qual premissa usar para o perfil horário de fim de semana.
- **Aceite**: cada decisão está em `memories/decisoes/`, e este arquivo e as issues estão ajustados.

### E2.1 — `Dim_Calendario` e `Dim_Horario`
- **Resp.** Luciano · Power Query · **Depende de** E2.0
- **Saídas**: consultas e `.pq` de:
  - `Dim_Calendario` (2024): `data`, `ano`, `mes`, `nome_mes`, `dia`, `dia_semana`, `nome_dia`, `semana_ano`, `tipo_dia` (Útil, Sábado, Domingo/Feriado), `feriado_nome`;
  - `Dim_Horario`: `hora` 0–23, `faixa_horaria` e `flag_pico`, a partir de `Param_Faixas_Horarias`. Proposta inicial, a validar em E2.2: Madrugada 0–4, Pico manhã 5–8, Entrepico 9–15, Pico tarde 16–19, Noite 20–23.
- **Aceite**: 366 e 24 linhas; as faixas cobrem 0–23 sem sobreposição; os feriados de `Cad_Feriados_2024` aparecem como Domingo/Feriado.

### E2.2 — `Fato_Perfil_Horario`
- **Resp.** Luciano · Power Query, Dados · **Depende de** E1.9, E2.1
- **Objetivo**: quanto cada hora representa no total diário de cada modalidade.
- **Passos**:
  1. Para cada modalidade (Ônibus, Metrô, Trem), considerar as viagens da OD que usam a modalidade em qualquer etapa.
  2. Somar `FE_VIA` por `hora_saida`. Todas as etapas recebem a hora de saída da viagem, por aproximação; registre isso.
  3. Participação = soma da hora ÷ soma do dia. Tipo de dia Útil, `origem_dado = estimado`.
  4. Fim de semana conforme a premissa de E2.0, `origem_dado = simulado`.
  5. Comparar a curva com a do Relatório Síntese da OD e ajustar `Param_Faixas_Horarias` se os picos caírem fora das faixas.
- **Aceite**: a soma das participações dá 1,000 (±0,0001) em cada modalidade × tipo de dia; os picos coincidem com o Relatório Síntese.
- **Validar**: gráfico das três curvas anexado à issue.

### E2.3 — `Fato_Viagem_OD` e `Dim_Cadeia_Modal`
- **Resp.** Luciano · Power Query · **Depende de** E1.9
- **Saídas**:
  - `Fato_Viagem_OD`: `hora_saida`, `id_cadeia`, `regiao_origem`, `regiao_destino`, `viagens_expandidas` (soma de `FE_VIA`), `duracao_media_min` (ponderada por `FE_VIA`), `n_amostra`;
  - `Dim_Cadeia_Modal`: `id_cadeia`, `descricao`, `n_etapas`, `usa_onibus`, `usa_metro`, `usa_trem`, `alternativa_alvo` (marca "Ônibus → Metrô" e "Ônibus → Trem").
- **Aceite**:
  - a soma de `viagens_expandidas` é igual ao total de viagens coletivas da OD;
  - células com `n_amostra` < 30 vêm marcadas como baixa confiabilidade.

### E2.4 — `Fato_Oferta` e `Param_Capacidade`
- **Resp.** Luciano · Power Query, Dados · **Depende de** E0.5, E1.10, E2.1
- **Objetivo**: capacidade ofertada por hora, base da lotação.
- **Passos**:
  1. Do GTFS (`frequencies`, `trips`, `routes`, `calendar`), calcular viagens programadas por hora × linha × tipo de dia.
  2. Casar `route_short_name` com `Dim_Transporte`.
  3. Se o GTFS não trouxer Metrô e CPTM, usar headways oficiais por faixa (`Param_Headway_Trilhos`, `origem_dado = simulado`, com a fonte citada).
  4. Validar `Param_Capacidade` com fontes (SPTrans por tipo de veículo; Metrô e CPTM por trem) e registrar a premissa de capacidade dos ônibus decidida em E2.0.
  5. Documentar a limitação: GTFS de 2026 aplicado a 2024.
- **Plano B**: se E0.5 ainda não estiver pronto, montar a oferta inteira por headway parametrizado (`simulado`) e trocar pelo GTFS quando chegar.
- **Aceite**: toda linha com demanda tem oferta em toda hora com serviço, ou é marcada `sem_oferta`; todo parâmetro cita a fonte ou diz "premissa".

### E2.5 — Modelo estrela no Power Pivot
- **Resp.** Luciano · DAX · **Depende de** E2.1–E2.4
- **Passos**:
  1. Carregar fatos e dimensões só no Modelo de Dados (sem planilha para os fatos grandes).
  2. Relações 1:* em direção única:
     - `Fato_Transporte` → `Dim_Calendario`, `Dim_Transporte`;
     - `Fato_Perfil_Horario` → `Dim_Horario`;
     - `Fato_Viagem_OD` → `Dim_Horario`, `Dim_Cadeia_Modal`;
     - `Fato_Oferta` → `Dim_Horario`, `Dim_Transporte`;
     - se for preciso ligar o perfil à modalidade, criar uma `Dim_Modalidade` pequena (Ônibus, Metrô, Trem).
  3. Hierarquias Ano › Mês › Dia e Faixa › Hora.
  4. Classificar `nome_mes` por `mes`; ocultar chaves técnicas.
- **Aceite**: o diagrama não tem caminhos ambíguos nem relações bidirecionais; `modelo-diagrama.png` está salvo.

### E2.6 — Medidas DAX de demanda
- **Resp.** Luciano · DAX · **Depende de** E2.5
- **Medidas**:
  - Total de Passageiros;
  - Média Diária de Passageiros;
  - Média Dia Útil; Média Fim de Semana; Razão Fim de Semana/Útil;
  - Participação % da Modalidade; Participação % da Linha;
  - Variação % sobre o Mês Anterior;
  - Ranking da Linha.
- **Aceite**: Total de Passageiros por mês × modalidade é igual aos números reconciliados em E1.11; toda medida está em `medidas.dax` com um comentário dizendo o que responde.

### E2.7 — Medidas DAX por hora e de lotação
- **Resp.** Luciano · DAX · **Depende de** E2.6
- **Medidas**:
  - Demanda Estimada por Hora: média diária no contexto × participação da hora, para a modalidade e o tipo de dia do contexto;
  - Demanda no Pico; % da Demanda no Pico;
  - Viagens Programadas por Hora; Headway Médio (min); Capacidade Ofertada por Hora;
  - Lotação Simulada %; Faixa de Lotação (busca em `Param_Faixas_Lotacao`);
  - Viagens OD; Tempo Médio de Viagem (min).
- **Aceite**:
  - para cada linha e tipo de dia, a soma das 24 horas de Demanda Estimada por Hora é igual à média diária;
  - a lotação no pico é maior que no entrepico em todas as modalidades;
  - valores fora do esperado ficam listados com hipótese.

### E2.8 — Alternativas de percurso nos corredores
- **Resp.** Luciano · DAX, Excel · **Depende de** E2.3, E2.7
- **Objetivo**: reproduzir a tabela-exemplo da proposta com números do modelo.
- **Saídas**:
  - `Cad_Corredor` (no `cheiU_cadastros.xlsx`): corredor, alternativa, cadeia, região de origem, região de destino, linha tronco. Linhas:
    - Leste → Centro: Ônibus → Metrô (L3); Ônibus → Trem (L11, L12);
    - Norte → Centro: Ônibus → Metrô (L1); Ônibus → Trem (L7).
  - medidas Viagens na Alternativa, Participação da Alternativa no Corredor, Duração Média da Alternativa, Lotação da Linha Tronco e Situação;
  - uma tabela dinâmica Horário × Alternativa × Demanda × Situação.
- **Aceite**: a tabela sai preenchida para os dois corredores às 07h, 10h e 18h, com a `origem_dado` visível.

### E2.9 — Painel de validação no Excel
- **Resp.** Nicolly · Excel · **Depende de** E2.8
- **Objetivo**: visão rápida para a Parcial 1, antes do Power BI.
- **Saídas**: aba `Painel` em `cheiU_modelo.xlsx` com tabelas e gráficos dinâmicos: demanda mensal por modalidade, curva horária por modalidade, top 10 linhas e tabela de alternativas. Segmentações de modalidade, tipo de dia e mês ligadas a todas.
- **Aceite**: "Atualizar tudo" roda sem erro, e cada segmentação filtra todos os elementos.

### E2.10 — QA e fechamento da Etapa 2
- **Resp.** Maryele · QA, Docs · **Depende de** E2.9
- **Saídas**:
  - `medidas.dax` sincronizado com `Workbook.Model.ModelMeasures` (comparação por script);
  - `03-powerpivot/README.md` com tabelas, grãos, relações e medidas;
  - `04-documentacao/qa/etapa-2.md`.
- **Aceite**: checagens de E2.6 e E2.7 refeitas e OK; outra pessoa abre, atualiza e vê os mesmos números.
