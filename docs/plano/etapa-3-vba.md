# Etapa 3 — Automação VBA

Entregável do professor (aula 11): código VBA (`.bas`) em `01-vba`. Marco no Linear: **Etapa 3 — VBA**.

Arquivos: `MA2026-entrega-final/01-vba/cheiU_automacao.xlsm` (o `cheiU_modelo.xlsx` salvo como `.xlsm`), `modulos/*.bas`, `relatorios/` e `README.md`.

### E3.0 — Refinar o plano da Etapa 3
- **Resp.** Maryele · Docs · **Depende de** P1.3
- **Objetivo**: ajustar os passos ao feedback da Parcial 1 e ao que E0.7 revelou sobre importar e exportar `.bas`.
- **Pré-requisito humano**: para importar e exportar módulos por script, o Luciano liga em Arquivo › Opções › Central de Confiabilidade › Configurações de Macro a opção "Confiar no acesso ao modelo de objeto do projeto do VBA". Sem ela, os módulos são exportados à mão pelo VBE (clique direito › Exportar arquivo).
- **Aceite**: o método de sincronizar os `.bas` está definido e registrado neste arquivo.

### E3.1 — Base do `.xlsm` e módulos utilitários
- **Resp.** Maryele · VBA · **Depende de** E3.0
- **Saídas**:
  - `modConfig`: lê `CaminhoRepo` e as chaves do `.env`;
  - `modLog`: escreve na aba `Log` (data_hora, rotina, status, mensagem, duração_s);
  - `modUtil`: padrão de erro `On Error GoTo Falha` com registro no log.
- **Aceite**: `Config("CaminhoRepo")` retorna o caminho; uma rotina de teste gera uma linha OK e uma linha de FALHA no `Log`.

### E3.2 — Macro de atualização completa
- **Resp.** Maryele · VBA · **Depende de** E3.1
- **Saídas**: `modAtualizacao.AtualizarTudo`.
- **Passos**:
  1. Desligar a atualização em segundo plano de cada conexão.
  2. `RefreshAll` e depois `Application.CalculateUntilAsyncQueriesDone`.
  3. Atualizar o modelo.
  4. Registrar a duração de cada consulta no log.
- **Aceite**: execução de ponta a ponta sem intervenção; o `Log` tem uma linha OK por consulta.

### E3.3 — Macro de QA automatizado
- **Resp.** Maryele · VBA, QA · **Depende de** E3.2
- **Saídas**: `modQA.ValidarDados`, que preenche a aba `QA` (checagem, esperado, obtido, OK/FALHA, com formatação condicional).
- **Checagens**: as mesmas de `04-documentacao/qa/etapa-1.md` e `etapa-2.md`, feitas por consulta DAX (`EVALUATE`) na conexão ADO do modelo ou por fórmulas `CUBEVALUE`.
- **Aceite**: com os dados corretos, tudo OK. Com um defeito proposital (ex. apagar um dia de um arquivo bruto numa cópia), a checagem correspondente vira FALHA. O teste negativo fica documentado no README.

### E3.4 — Macro de relatório operacional
- **Resp.** Maryele · VBA · **Depende de** E3.2
- **Saídas**:
  - `modRelatorio.GerarRelatorio(periodo)`, que preenche a aba-modelo `Relatorio` com os KPIs do mês ou semana escolhidos e exporta `relatorios/relatorio_<periodo>.pdf`;
  - KPIs: total por modalidade, média dia útil, % no pico, top 10 linhas, faixa de lotação no pico.
- **Aceite**: gera o relatório de qualquer mês de 2024 sem passo manual; o PDF abre com os números iguais aos do `Painel`.

### E3.5 — Macro de exportação para a carga no SQL
- **Resp.** Maryele · VBA, SQL · **Depende de** E3.2
- **Saídas**: `modExportacao.ExportarParaCarga`, que grava cada tabela `Fato_*`, `Dim_*` e `Param_*` como CSV em `MA2026-entrega-final/02-bancodedados-sql/carga/`.
- **Formato do CSV**: UTF-8, separador `,`, decimal `.`, datas ISO e cabeçalho na primeira linha.
- **Passos**: ler cada tabela do modelo por consulta DAX `EVALUATE` na conexão ADO do modelo (`ThisWorkbook.Model.DataModelConnection.ModelConnection.ADOConnection`) e gravar com `ADODB.Stream` em UTF-8.
- **Aceite**: o número de linhas de cada CSV é igual ao da tabela no modelo.

### E3.6 — Painel de controle e fechamento da Etapa 3
- **Resp.** Maryele · VBA, Docs · **Depende de** E3.3, E3.4, E3.5
- **Saídas**:
  - aba `Controle` com botões: Atualizar, Validar, Gerar relatório, Exportar para SQL;
  - todos os módulos exportados em `modulos/*.bas` (CRLF);
  - `README.md` explicando como habilitar macros e o que cada botão faz;
  - `MA2026-entrega-parcial/04-documentacao/qa/etapa-3.md`.
- **Aceite**: os quatro botões rodam em sequência numa máquina limpa; os `.bas` são idênticos ao código no `.xlsm`.
