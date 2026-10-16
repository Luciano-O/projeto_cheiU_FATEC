# Etapa 6 — Dashboard Power BI

Entregável do professor (aula 18): painel interativo (`.pbix`) e relatório em `04-powerbi-dashboard`. Marco no Linear: **Etapa 6 — Power BI**.

Arquivos em `MA2026-entrega-final/04-powerbi-dashboard/`:

- `cheiU_dashboard.pbix`, a entrega;
- `cheiU_dashboard.pbip` e as pastas do projeto: o gêmeo em texto (modelo em TMDL, relatório em PBIR);
- `tema-cheiU.json`;
- `relatorio-final.md` e o PDF.

### E6.0 — Refinar o plano e instalar o Power BI Desktop
- **Resp.** Luciano · Power BI, Setup · **Depende de** E5.5
- **Passos**:
  1. Com o ok do Luciano, instalar o Power BI Desktop (`winget install --id Microsoft.PowerBI -e` ou pela Microsoft Store).
  2. Confirmar se a versão instalada salva em `.pbip` (Power BI Project).
  3. Definir o fluxo: desenvolver em `.pbip` (versionável) e salvar uma cópia `.pbix` para a entrega.
- **Observação**: montar visuais é trabalho majoritariamente de interface. Agentes preparam medidas, tema, especificação de cada página e, via PBIP, o modelo semântico; as pessoas do grupo montam os visuais.
- **Aceite**: fluxo PBIP/PBIX definido e registrado neste arquivo.

### E6.1 — Conexão ao SQL e modelo semântico
- **Resp.** Luciano · Power BI, DAX · **Depende de** E6.0
- **Passos**:
  1. Importar as views `dw.vw_*` do SQL Server.
  2. Recriar as relações da Etapa 2.
  3. Migrar as medidas de `medidas.dax`, ajustando os nomes de tabela.
  4. Organizar as medidas em pastas por tema.
- **Aceite**: os 5 KPIs de `qa/etapa-4.md` dão os mesmos valores no Power BI.

### E6.2 — Página "Visão geral"
- **Resp.** Grupo · Power BI · **Depende de** E6.1
- **Conteúdo**:
  - cartões: total de passageiros, média dia útil, % no pico, lotação média no pico;
  - linha mensal por modalidade;
  - barras por região;
  - segmentações de mês, modalidade e tipo de dia.
- **Aceite**: os números batem com o SQL, e as segmentações filtram todos os visuais.

### E6.3 — Página "Padrões horários"
- **Resp.** Grupo · Power BI · **Depende de** E6.1
- **Conteúdo**:
  - curva da demanda estimada por hora, por modalidade (útil × fim de semana);
  - mapa de calor hora × dia da semana;
  - pico × fora do pico;
  - efeito da chuva (E5.1).
- **Aceite**: a curva reproduz `Fato_Perfil_Horario`; a origem do dado é indicada nos visuais estimados.

### E6.4 — Página "Linhas e regiões"
- **Resp.** Grupo · Power BI · **Depende de** E6.1
- **Conteúdo**:
  - top linhas;
  - mapa de estações e paradas (latitude e longitude de `Dim_Localizacao`);
  - matriz região × modalidade;
  - página de detalhe (drill-through) por linha.
- **Aceite**: o detalhe abre a partir de qualquer linha, e o mapa não tem pontos sem coordenada.

### E6.5 — Página "Alternativas de percurso"
- **Resp.** Grupo · Power BI · **Depende de** E6.1
- **Conteúdo**:
  - seletor de corredor e de horário;
  - a tabela-exemplo da proposta (Horário, Opção, Demanda, Situação) com formatação condicional pela faixa;
  - duração média (OD) e lotação da linha tronco;
  - nota sobre a origem do dado.
- **Aceite**: os dois corredores às 07h, 10h e 18h mostram os mesmos números de E2.8 e de E4.4.

### E6.6 — Navegação, tema, "Sobre os dados" e QA
- **Resp.** Maryele · Power BI, QA · **Depende de** E6.2–E6.5
- **Saídas**:
  - botões de navegação, dicas de ferramenta e `tema-cheiU.json`;
  - página "Sobre os dados": fontes, cobertura, premissas, `origem_dado` e limitações;
  - `MA2026-entrega-parcial/04-documentacao/qa/etapa-6.md`.
- **Aceite**: no Performance Analyzer, nenhum visual passa de 2 s; todas as páginas navegam pelos botões; o QA está OK.

### E6.7 — Relatório final
- **Resp.** Grupo · Docs · **Depende de** E6.6
- **Saídas**: `relatorio-final.md` e PDF, mais o PDF exportado do painel.
- **Conteúdo**: resposta à pergunta central com evidências, prints, limitações e trabalhos futuros.
- **Aceite**: a pergunta central é respondida explicitamente, com números do painel; todo integrante revisou.
