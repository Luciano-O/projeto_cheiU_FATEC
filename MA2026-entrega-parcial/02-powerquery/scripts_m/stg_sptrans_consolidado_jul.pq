// stg_sptrans_consolidado_jul
// Consolidado de julho/2024 (2ª versão publicada, mês × linha × empresa), somado por linha.
// Serve só para recuperar o dia 08/07, que veio incompleto no arquivo diário (D24, decisão 0014).
let
    Pasta = Excel.Workbook(File.Contents(pArquivoConsolidadoJul), null, true),
    Aba = Table.SelectRows(Pasta, each [Kind] = "Sheet"){0}[Data],
    Primeira = List.Transform(Table.Column(Aba, Table.ColumnNames(Aba){0}), each Text.Upper(Text.Trim(Text.From(_) ?? ""))),
    PosCab = List.PositionOf(Primeira, "GRUPO"),
    Cabecalho = List.Transform(Record.FieldValues(Aba{PosCab}), each Text.Trim(Text.From(_) ?? "")),
    Padrao = List.Transform(Cabecalho, (c) =>
        let achado = Table.SelectRows(cad_DePara_Coluna, each [grafia_fonte] = Text.Upper(c))
        in if Table.IsEmpty(achado) then "?" & c else achado{0}[coluna_padrao]),
    Dados = Table.Skip(Aba, PosCab + 1),
    Renomeado = Table.RenameColumns(Dados, List.Zip({Table.ColumnNames(Aba), Padrao})),
    ComTotal = Table.SelectRows(Renomeado, each [passageiros_total] is number),
    // D7: mesmo formato de código do letreiro que stg_sptrans_linhas (917M10 -> 917M-10)
    Codigo = Table.AddColumn(ComTotal, "codigo_linha", each
        let t = Text.Trim(Text.From([linha] ?? "")),
            c = Text.Trim(Text.BeforeDelimiter(t, " - ")),
            fim = Text.End(c, 2)
        in if c = "" then null
           else if Text.Length(c) > 2 and List.AllTrue(List.Transform(Text.ToList(fim), each Text.Contains("0123456789", _)))
           then Text.Start(c, Text.Length(c) - 2) & "-" & fim else c, type nullable text),
    PorLinha = Table.Group(Codigo, {"codigo_linha"}, {
        {"passageiros", each List.Sum([passageiros_total]), type number},
        {"pagantes", each List.Sum([pagantes]), type number},
        {"integracao", each List.Sum([integracao_onibus]), type number},
        {"gratuidades", each List.Sum([gratuidade]) + List.Sum([gratuidade_estudante]), type number},
        {"registros_origem", each Table.RowCount(_), Int64.Type}})
in
    PorLinha
