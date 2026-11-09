// stg_sptrans_referencia
// Totais mensais publicados pela SPTrans (tabela larga mês × grupo, D14), só 2024, despivotados.
let
    Html = Text.FromBinary(File.Contents(pArquivoTotaisSPTrans), TextEncoding.Windows),
    Pagina = Web.Page(Html),
    Tabelas = Table.SelectRows(Pagina, each [Source] = "Table"),
    Com2024 = Table.SelectRows(Tabelas, each List.Contains(List.Transform(Table.Column([Data], Table.ColumnNames([Data]){0}), each Text.Trim(Text.From(_ ?? ""))), "Jan/24")),
    Bruta = Com2024{0}[Data],
    Linhas = Table.SelectRows(Bruta, each Text.EndsWith(Text.Trim(Text.From(Record.FieldValues(_){0} ?? "")), "/24")),
    Nomes = List.FirstN(Table.ColumnNames(Linhas), 5),
    Cinco = Table.SelectColumns(Linhas, Nomes),
    Renomeia = Table.RenameColumns(Cinco, List.Zip({Nomes, {"mes", "Estrutural", "Local de Articulação Regional", "Local de Distribuição", "Total"}})),
    SemTotal = Table.RemoveColumns(Renomeia, {"Total"}),
    Longo = Table.UnpivotOtherColumns(SemTotal, {"mes"}, "grupo", "valor_texto"),
    Meses = [Jan = 1, Fev = 2, Mar = 3, Abr = 4, Mai = 5, Jun = 6, Jul = 7, Ago = 8, Set = 9, Out = 10, Nov = 11, Dez = 12],
    MesInicio = Table.AddColumn(Longo, "mes_inicio", each #date(2000 + Number.From(Text.AfterDelimiter(Text.Trim([mes]), "/")), Record.Field(Meses, Text.Proper(Text.Start(Text.Trim([mes]), 3))), 1), type date),
    Valor = Table.AddColumn(MesInicio, "passageiros_publicado", each Number.From(Text.Remove(Text.From([valor_texto]), {".", " "})), type number),
    Final = Table.SelectColumns(Valor, {"mes_inicio", "grupo", "passageiros_publicado"})
in
    Final
