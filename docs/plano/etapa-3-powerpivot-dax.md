# Etapa 3 — Power Pivot e DAX

Etapa do professor: aulas 6–7. Entrega em `MA2026-entrega-parcial/03-powerpivot`. Marco no Linear: **Etapa 3 — Power Pivot e DAX**.

O que o professor exige está em `referencia-professor.md`. Em resumo:
- esta etapa não limpa mais nada: lê só o arquivo da Etapa 2, monta o modelo e cria as medidas;
- o modelo não cria nem perde valor: a aba `Conferencia` mostra todas as diferenças 0;
- os gráficos de painel ficam para o Power BI.

Layout dos arquivos desta etapa:

```text
MA2026-entrega-parcial/03-powerpivot/
├── cheiU_03_PowerPivot.xlsx       # consultas que leem a Etapa 2 + Modelo de Dados + abas Validacao e Conferencia
├── dax/medidas_preliminares.dax   # todas as medidas, separador vírgula, UTF-8
├── docs/modelo_relacional.md      # tabelas, grão, chaves, linhas e relacionamentos
├── docs/diagrama_modelo.png       # Exibição de Diagrama do Power Pivot
├── scripts_m/                     # .pq das consultas deste arquivo
├── evidencias/
└── README.md
```

### E3.0 — Refinar o plano da Etapa 3
- **Resp.** Luciano · Docs · **Depende de** E2.11
- **Objetivo**: revisar o modelo-alvo com os dados reais em mãos e conferir de novo contra `docs/professor/guia-etapa-3-powerpivot.pdf`.
- **Decisões a tomar e registrar**:
  - se a demanda por estação dos trilhos vira uma fato própria para analisar região;
  - se a capacidade dos ônibus é definida por grupo SPTrans ou por linha;
  - qual premissa usar para o perfil horário de fim de semana. Se o E2.0 já tiver decidido, é só confirmar.
- **Aceite**: cada decisão está em `memories/decisoes/`, e este arquivo e as issues estão ajustados.

### E3.1 — Arquivo da Etapa 3, `Dim_Calendario` e `Dim_Horario`
- **Resp.** Luciano · Power Query, DAX · **Depende de** E3.0
- **Objetivo**: um arquivo novo que lê a Etapa 2 por parâmetro e gera as dimensões de tempo.
- **Saídas**: consultas e `.pq` de:
  - `pArquivoEtapa2` (derivado de `CaminhoRepo`) e `cad_Etapa2`, que lê as tabelas de `cheiU_02_PowerQuery.xlsx`;
  - `Fato_*`, `Dim_*` e `Rejeitados`, lidos de `cad_Etapa2`, sem nenhuma transformação de limpeza;
  - `Dim_Calendario` (2024): `data`, `ano`, `mes`, `nome_mes`, `mes_inicio`, `dia`, `dia_semana`, `nome_dia`, `semana_ano`, `tipo_dia` (Útil, Sábado, Domingo/Feriado), `feriado_nome`. Os feriados vêm de `Cad_Feriados_2024`, provisórios até o E6.2;
  - `Dim_Horario`: `hora` 0–23, `faixa_horaria` e `flag_pico`, a partir de `Param_Faixas_Horarias`.
- **Aceite**:
  - 366 e 24 linhas;
  - as faixas cobrem 0–23 sem sobreposição;
  - os feriados aparecem como Domingo/Feriado;
  - nenhuma tabela foi digitada ou colada.

### E3.2 — Modelo no Power Pivot
- **Resp.** Luciano · DAX · **Depende de** E3.1
- **Passos**:
  1. Carregar fatos e dimensões só no Modelo de Dados (sem planilha para os fatos grandes). `Rejeitados` entra sem relacionamento, só para as contagens.
  2. Relações 1:* ativas, em direção única:
     - `Fato_Transporte` → `Dim_Calendario`, `Dim_Transporte`;
     - `Fato_Perfil_Horario` → `Dim_Horario`;
     - `Fato_Viagem_OD` → `Dim_Horario`, `Dim_Cadeia_Modal`;
     - `Fato_Oferta` → `Dim_Horario`, `Dim_Transporte`;
     - se for preciso ligar o perfil à modalidade, criar uma `Dim_Modalidade` pequena (Ônibus, Metrô, Trem).
  3. Marcar `Dim_Calendario` como Tabela de Datas.
  4. Hierarquias Ano › Mês › Dia e Faixa › Hora.
  5. Classificar `nome_mes` por `mes`; ocultar chaves técnicas.
  6. Reservar no diagrama o lugar de `Fato_Clima_Horario` (Etapa 6).
- **Aceite**: o diagrama não tem caminhos ambíguos nem relações bidirecionais; `docs/diagrama_modelo.png` está salvo.

### E3.3 — Medidas DAX de demanda
- **Resp.** Luciano · DAX · **Depende de** E3.2
- **Medidas**:
  - Total de Passageiros;
  - Média Diária de Passageiros;
  - Média Dia Útil; Média Fim de Semana; Razão Fim de Semana/Útil;
  - Participação % da Modalidade; Participação % da Linha;
  - Variação % sobre o Mês Anterior;
  - Ranking da Linha.
- **Aceite**:
  - pelo menos cinco medidas funcionando, que é o mínimo da Parcial 1;
  - Total de Passageiros por mês × modalidade é igual aos números reconciliados no E2.10;
  - toda medida está em `dax/medidas_preliminares.dax` com um comentário `//` dizendo a pergunta que responde e o formato.

### E3.4 — Medidas DAX por hora e de lotação
- **Resp.** Luciano · DAX · **Depende de** E3.3
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

### E3.5 — Alternativas de percurso nos corredores
- **Resp.** Luciano · DAX, Excel · **Depende de** E2.7, E3.4
- **Objetivo**: reproduzir a tabela-exemplo da proposta com números do modelo.
- **Saídas**:
  - `Cad_Corredor` (na aba `Cadastros` de `cheiU_01_Excel.xlsx`, lido pela linhagem 1 → 2 → 3): corredor, alternativa, cadeia, região de origem, região de destino, linha tronco. Linhas:
    - Leste → Centro: Ônibus → Metrô (L3); Ônibus → Trem (L11, L12);
    - Norte → Centro: Ônibus → Metrô (L1); Ônibus → Trem (L7).
  - medidas Viagens na Alternativa, Participação da Alternativa no Corredor, Duração Média da Alternativa, Lotação da Linha Tronco e Situação.
- **Aceite**: a tabela Horário × Alternativa × Demanda × Situação sai preenchida para os dois corredores às 07h, 10h e 18h, com a `origem_dado` visível.

### E3.6 — Abas `Validacao` e `Conferencia`
- **Resp.** Nicolly · Excel, DAX · **Depende de** E3.5
- **Objetivo**: provar que o modelo responde e que não cria nem perde valor. Só tabelas dinâmicas: gráficos de painel são da Etapa 7.
- **Saídas**:
  - aba `Validacao` com tabelas dinâmicas:
    - demanda mensal por modalidade;
    - curva horária por modalidade;
    - top 10 linhas;
    - tabela de alternativas do E3.5;
    - segmentações de modalidade, tipo de dia e mês ligadas a todas;
  - medidas `Conf …`:
    - linhas de cada fato;
    - linhas de `Rejeitados`;
    - órfãs por FK (`ISBLANK(RELATED(...))`);
    - PK duplicada nas dimensões;
    - diferença entre Total de Passageiros e a soma de `passageiros` da Etapa 2;
  - aba `Conferencia`: valor da Etapa 2 (de `Conf_Reconciliacao`), valor do modelo e diferença.
- **Aceite**: "Atualizar tudo" roda sem erro; todas as diferenças da `Conferencia` são 0; cada segmentação filtra todas as tabelas dinâmicas.

### E3.7 — QA e publicação da Etapa 3
- **Resp.** Maryele · QA, Docs · **Depende de** E3.6
- **Saídas**:
  - `dax/medidas_preliminares.dax` sincronizado com `Workbook.Model.ModelMeasures` (comparação por script);
  - `docs/modelo_relacional.md` (tabelas, tipo, grão, chave, linhas; relacionamentos R1..Rn) e `docs/diagrama_modelo.png`;
  - `scripts_m/*.pq` das consultas deste arquivo;
  - `evidencias/`: diagrama, gerenciar relações, gerenciar medidas, validação, conferência;
  - `README.md` com como abrir (`CaminhoRepo` e Atualizar Tudo), tabelas, medidas com a pergunta de cada uma, resultados da conferência e pendências herdadas;
  - `04-documentacao/qa/etapa-3.md`: a tabela de conferência do Guia da Etapa 3 adaptada.
- **Aceite**:
  - checagens do E3.3 e do E3.4 refeitas e OK;
  - teste de linhagem (uma mudança na Etapa 2 aparece aqui após "Atualizar Tudo" e volta ao desfazer);
  - outra pessoa abre, atualiza e vê os mesmos números;
  - o commit é feito com o Excel fechado (sem `~$*.xlsx`).
