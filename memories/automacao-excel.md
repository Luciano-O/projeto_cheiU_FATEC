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
- Localidade da consulta: não há API. Todo `Table.TransformColumnTypes` e conversão de texto leva `"pt-BR"` explícito.

## O que exige a interface (GUI)

- Grupos de consultas no Editor do Power Query (`01_Parametros`…): não há propriedade de grupo no `WorkbookQuery`.
- Marcar tabela de datas, classificar por coluna, hierarquias e o print da Exibição de Diagrama do Power Pivot.
- Prints de evidência (Gerenciador de Nomes, Rastrear Precedentes, Gerenciar Relações).
- Importar e exportar `.bas` (exige "Confiar no acesso ao modelo de objeto do projeto do VBA"): não testado, fica para a Etapa 4.
