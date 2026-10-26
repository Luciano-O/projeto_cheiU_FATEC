# Etapa 4 — Automação VBA

Etapa do professor: aulas 10–11. Entrega: código VBA (`.bas`) em `01-vba`. Marco no Linear: **Etapa 4 — VBA**. O guia desta etapa ainda não saiu; o que a especificação já diz está em `referencia-professor.md`.

Arquivos: `MA2026-entrega-final/01-vba/cheiU_04_VBA.xlsm` (o `cheiU_03_PowerPivot.xlsx` salvo como `.xlsm`), `modulos/*.bas`, `relatorios/` e `README.md`.

### E4.0 — Refinar o plano da Etapa 4
- **Resp.** Maryele · Docs · **Depende de** P1.3
- **Objetivo**: ajustar os passos ao feedback da Parcial 1 e ao que E0.7 revelou sobre importar e exportar `.bas`.
- **Pré-requisito humano**: para importar e exportar módulos por script, o Luciano liga em Arquivo › Opções › Central de Confiabilidade › Configurações de Macro a opção "Confiar no acesso ao modelo de objeto do projeto do VBA". Sem ela, os módulos são exportados à mão pelo VBE (clique direito › Exportar arquivo).
- **Aceite**: o método de sincronizar os `.bas` está definido e registrado neste arquivo; o plano foi comparado com o guia da Etapa 4 do professor (se já publicado) e `referencia-professor.md` foi atualizado.

### E4.1 — Base do `.xlsm` e módulos utilitários
- **Resp.** Maryele · VBA · **Depende de** E4.0
- **Saídas**:
  - `modConfig`: lê `CaminhoRepo` e as chaves do `.env`;
  - `modLog`: escreve na aba `Log` (data_hora, rotina, status, mensagem, duração_s);
  - `modUtil`: padrão de erro `On Error GoTo Falha` com registro no log.
- **Aceite**: `Config("CaminhoRepo")` retorna o caminho; uma rotina de teste gera uma linha OK e uma linha de FALHA no `Log`.

### E4.2 — Macro de atualização completa
- **Resp.** Maryele · VBA · **Depende de** E4.1
- **Saídas**: `modAtualizacao.AtualizarTudo`.
- **Passos**:
  1. Desligar a atualização em segundo plano de cada conexão.
  2. `RefreshAll` e depois `Application.CalculateUntilAsyncQueriesDone`.
  3. Atualizar o modelo.
  4. Registrar a duração de cada consulta no log.
- **Aceite**: execução de ponta a ponta sem intervenção; o `Log` tem uma linha OK por consulta.

### E4.3 — Macro de QA automatizado
- **Resp.** Maryele · VBA, QA · **Depende de** E4.2
- **Saídas**: `modQA.ValidarDados`, que preenche a aba `QA` (checagem, esperado, obtido, OK/FALHA, com formatação condicional).
- **Checagens**: as mesmas de `04-documentacao/qa/etapa-2.md` e `etapa-3.md`, feitas por consulta DAX (`EVALUATE`) na conexão ADO do modelo ou por fórmulas `CUBEVALUE`.
- **Aceite**: com os dados corretos, tudo OK. Com um defeito proposital (ex. apagar um dia de um arquivo bruto numa cópia), a checagem correspondente vira FALHA. O teste negativo fica documentado no README.

### E4.4 — Macro de resumo diário
- **Resp.** Maryele · VBA · **Depende de** E4.2
- **Objetivo**: o análogo do `GerarResumoDiario` do projeto modelo, ou seja, um relatório recorrente que hoje seria feito à mão.
- **Saídas**: `modRelatorio.GerarResumoDiario`, que:
  1. pede uma data (InputBox) e valida se ela existe em `Dim_Calendario` e tem demanda;
  2. cria ou recria a aba `Resumo_dd-mm-aaaa`;
  3. escreve o total de passageiros por modalidade e o tipo de dia;
  4. lista o top 3 de linhas do dia e o % da demanda no pico;
  5. pinta de vermelho as linhas cuja faixa de lotação no pico é "Muito alta";
  6. exporta a aba em PDF em `relatorios/resumo_<aaaa-mm-dd>.pdf`.
- **Aceite**: gera o resumo de qualquer dia de 2024 sem passo manual; uma data inválida ou sem dados mostra mensagem e não cria aba; os números são iguais aos das tabelas dinâmicas da aba `Validacao`.

### E4.5 — Macro de exportação para a carga no SQL
- **Resp.** Maryele · VBA, SQL · **Depende de** E4.2
- **Saídas**: `modExportacao.ExportarParaCarga`, que grava cada tabela `Fato_*`, `Dim_*` e `Param_*` como CSV em `MA2026-entrega-final/02-bancodedados-sql/carga/`.
- **Formato do CSV**: UTF-8, separador `,`, decimal `.`, datas ISO e cabeçalho na primeira linha.
- **Passos**: ler cada tabela do modelo por consulta DAX `EVALUATE` na conexão ADO do modelo (`ThisWorkbook.Model.DataModelConnection.ModelConnection.ADOConnection`) e gravar com `ADODB.Stream` em UTF-8.
- **Aceite**: o número de linhas de cada CSV é igual ao da tabela no modelo.

### E4.6 — Painel de controle e fechamento da Etapa 4
- **Resp.** Maryele · VBA, Docs · **Depende de** E4.3, E4.4, E4.5
- **Saídas**:
  - aba `Controle` com botões: Atualizar, Validar, Resumo diário, Exportar para SQL;
  - todos os módulos exportados em `modulos/*.bas` (CRLF);
  - `README.md` explicando como habilitar macros e o que cada botão faz;
  - `MA2026-entrega-parcial/04-documentacao/qa/etapa-4.md`.
- **Aceite**: os quatro botões rodam em sequência numa máquina limpa; os `.bas` são idênticos ao código no `.xlsm`.
