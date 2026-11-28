# Automação do Excel via COM

Receita verificada em 06/11/2026 (Excel 16, Microsoft 365 pt-BR, Windows PowerShell 5.1). Funções em `MA2026-entrega-parcial/02-powerquery/scripts/ExcelCom.psm1`; prova de conceito em `testar_excelcom.ps1` (cria, atualiza, mede e exporta do zero).

## O que funciona via COM

| Operação | Como | Situação |
|---|---|---|
| Criar pasta, abas, nomes definidos | `Workbooks.Add`, `Names.Add` | funciona via COM |
| Tabela (ListObject) a partir de valores | `Range.Value2 = object[,]`, `ListObjects.Add(1, …)` | funciona via COM |
| Fórmulas | `Range.Formula2` com nomes em inglês (`XLOOKUP`, `LET`, `TEXTJOIN`) e vírgula | funciona via COM |
| Ignorar níveis de privacidade | `Workbook.Queries.FastCombine = $true` | funciona via COM |
| Criar ou trocar consulta | `Queries.Add(nome, m)` / `.Formula = m` | funciona via COM |
| Carga em planilha | `ListObjects.Add(0, "OLEDB;Provider=Microsoft.Mashup.OleDb.1;…Location=<q>…")`, `CommandType = 2`, `SELECT * FROM [<q>]`, `QueryTable.Refresh($false)` | funciona via COM |
| Carga só no Modelo de Dados | `Connections.Add2(nome, desc, conn, "\"<q>\"", 6, $true, $false)` | funciona via COM, **com `lCmdtype = 6` e o nome da consulta entre aspas** (como o gravador de macros) |
| Relação | `Model.ModelRelationships.Add(colunaFK, colunaPK)` | funciona via COM |
| Medida | `Model.ModelMeasures.Add(nome, tabela, dax, formato, descrição)`; DAX com **vírgula** | funciona via COM |
| Ler medida | `CUBEVALUE("ThisWorkbookDataModel","[Measures].[X]")` numa célula | funciona via COM |
| Exportar `.pq` | `Queries(i).Formula` | funciona via COM |

## Pegadinhas

- **`Connections.Add2` com `lCmdtype = 2` e `SELECT * FROM [q]` trava o Excel** sem diálogo nenhum, oculto ou visível. Use `6` e `"q"`.
- Scripts `.ps1`/`.psm1` com acento precisam de **UTF-8 com BOM**: o Windows PowerShell 5.1 lê arquivo sem BOM como ANSI e quebra o parser.
- Um Excel travado por COM fica sem janela e não fecha sozinho. Encerre só o processo que o script abriu (anote o pid no início).
- **`Range.Value2` só para matrizes.** Depois de um `Value2 = 'texto'`, o binder COM do PowerShell guarda o tipo texto, e o próximo `Value2 = object[,]` falha com "Unable to cast Object[,] to String". Escalares vão por `.Formula`. Elementos que passaram por parâmetro de função chegam como `PSObject`: desembrulhe com `.psobject.BaseObject` (`Write-Tabela` e `Set-Valores` já fazem isso).
- Aba copiada de outra pasta herda a visibilidade: o consolidado SPTrans de jan/2024 tem a aba de dados **oculta**.
- `Application.Calculation` só pode ser trocado com uma pasta aberta.
- Em coluna de tabela, `[@Coluna_Com_Sublinhado]` é recusado via `Formula2`; use `[@[Coluna]]` e `Tabela[[Coluna]]`. Grave a fórmula na primeira célula e deixe a tabela propagar.
- Depois de criar dinâmicas sobre o modelo, o Excel recusa chamadas por alguns segundos (`RPC_E_CALL_REJECTED`): espere `Application.Ready` (`Esperar-Excel` em `montar_etapa3.ps1`).
- `Excel.Workbook` devolve só `Name` e `Data` para `.xls` (sem `Kind`), e alguns `.xls` voltam vazios.
- Nos `.xls`, uma célula de data pode chegar ao Power Query como texto `m/d/aaaa`.
- Dinâmicas e segmentações sobre o Modelo de Dados funcionam via COM (`PivotCaches().Create(2, conexão ThisWorkbookDataModel, 6)`, `SlicerCaches.Add2`).
- Localidade da consulta: não há API. Todo `Table.TransformColumnTypes` e conversão de texto leva `"pt-BR"` explícito.

## O que exige a interface (GUI)

- Grupos de consultas no Editor do Power Query (`01_Parametros`…): não há propriedade de grupo no `WorkbookQuery`. Feito em 27/11/2026 pelo controle do computador: Dados › Obter Dados › Iniciar Editor; Shift/Ctrl+clique seleciona; botão direito › Mover Para o Grupo › Novo Grupo. Clicar numa consulta dispara a prévia (a de `Fato_Transporte` leva ~2 min): termine a seleção numa consulta leve. Fechar o Editor pelo X e escolher Manter não atualiza as consultas. Os grupos ficam no `DataMashup` (entrada `QueryGroups` e `QueryGroupID` de cada consulta). **`Ctrl+S` pode não gravar**: salve pelo disquete da barra de título e confira a data do arquivo.
- Marcar tabela de datas, classificar por coluna, hierarquias, ocultar colunas e o print da Exibição de Diagrama do Power Pivot. Feito em 27/11/2026 pelo controle do computador (`03-powerpivot/README.md` lista os passos). O Power Pivot abre por Dados › Modelo de Dados › Gerenciar (não há guia Power Pivot ligada); no diagrama, ctrl+clique seleciona vários campos e o menu de contexto tem Criar Hierarquia e Ocultar das Ferramentas de Cliente. **`Ctrl+S` na janela do Power Pivot não salva**: use o disquete da barra de acesso rápido dela e confira a data do arquivo. Esses ajustes se perdem quando o script remonta a pasta.
- Prints de evidência (Gerenciador de Nomes, Rastrear Precedentes, Gerenciar Relações).
- Importar e exportar `.bas` (exige "Confiar no acesso ao modelo de objeto do projeto do VBA"): não testado, fica para a Etapa 4.

## VBA e automação (Etapa 4, 28/11/2026)

- **Acesso ao projeto VBA recusado por automação.** Com AccessVBOM = 1 no registro (nas duas visões, a isolada dos comandos do agente e a real) e a opção marcada na Central de Confiabilidade, o Excel aberto por COM ainda responde "O acesso de programação ao projeto do Visual Basic não é confiável". A importação dos `.bas` é feita à mão no VBE (Alt+F11 › Arquivo › Importar arquivo; para trocar um módulo, Remover › Não antes). A opção foi desligada de novo no fim.
- **`Application.Run` funciona** sem acesso ao projeto: as macros e as funções públicas (`ValorMedida`, `ValorDax`) rodam por COM. Use `DefinirModoSilencioso True` para nenhuma `MsgBox` travar a automação.
- **Excel visível para as macros.** Oculto, ele cai em `GerarResumoDiario` depois de `AtualizarTudo` (RPC 0x800706BE) e recusa chamadas logo depois de abrir uma pasta com Modelo de Dados (0x800AC472). `executar_etapa4.ps1` e `reconciliar_sql_dax.ps1` usam `Start-ExcelCom -Visible`; `montar_etapa4.ps1` espera e tenta de novo.
- **Caches OLAP.** `PivotCache.Refresh` nas dinâmicas sobre o Modelo de Dados dá erro 1004: o `Model.Refresh` já as atualiza.
- **ADO no modelo.** `ThisWorkbook.Model.DataModelConnection.ModelConnection.ADOConnection` aceita `EVALUATE` em DAX; `EVALUATE 'Tabela'` exporta 463.876 linhas em ~6 s com `GetRows` em blocos.
- **`.bas` em Windows-1252.** Caracteres fora dela (→, ≤, −) não podem estar no código: use `ChrW` (`Seta()` em `modQA`).
- **Abrir `.xlsm` pela interface.** `Start-Process` no arquivo pode abrir o "Abrir com" do Windows; passe o caminho ao `EXCEL.EXE`.
