// fnLerSPTrans
// Lê um arquivo diário da SPTrans (.xls ou .xlsx: o formato vem do conteúdo, D5).
// Procura a linha do cabeçalho (posição variável, D1), descarta o título acima dele (D2)
// e renomeia as 16 colunas pelo de-para da Etapa 1 (D4). Coluna sem de-para vira "?<nome>"
// e aparece em Conf_Colunas.
(Conteudo as binary, Arquivo as text) as table =>
let
    Pasta = Excel.Workbook(Conteudo, null, true),
    // .xls antigos (BIFF) só trazem Name e Data; .xlsx trazem também Kind. Alguns .xls trazem itens que não são
    // planilhas: vale o primeiro item cuja primeira coluna tem a célula "Data".
    TemCabecalho = (t as table) => List.Contains(List.Transform(List.FirstN(Table.Column(t, Table.ColumnNames(t){0}), 60), each Text.Upper(Text.Trim(Text.From(_) ?? ""))), "DATA"),
    Candidatos = Table.SelectRows(Pasta, each (try [Data] is table and Table.ColumnCount([Data]) >= 16 and TemCabecalho([Data]) otherwise false)),
    Aba = Candidatos{0}[Data],
    Originais = List.FirstN(Table.ColumnNames(Aba), 16),
    Dezesseis = Table.SelectColumns(Aba, Originais),
    Primeira = List.Transform(Table.Column(Dezesseis, Originais{0}), each Text.Upper(Text.Trim(Text.From(_) ?? ""))),
    PosCab = List.PositionOf(Primeira, "DATA"),
    ComLinha = Table.AddIndexColumn(Dezesseis, "linha_origem", 1, 1, Int64.Type),
    Cabecalho = List.Transform(Record.FieldValues(Dezesseis{PosCab}), each Text.Trim(Text.From(_) ?? "")),
    Padrao = List.Transform(Cabecalho, (c) =>
        let achado = Table.SelectRows(cad_DePara_Coluna, each [grafia_fonte] = Text.Upper(c))
        in if Table.IsEmpty(achado) then "?" & c else achado{0}[coluna_padrao]),
    Dados = Table.Skip(ComLinha, PosCab + 1),
    Renomeado = Table.RenameColumns(Dados, List.Zip({Originais, Padrao})),
    ComArquivo = Table.AddColumn(Renomeado, "arquivo", each Arquivo, type text),
    ComTitulo = Table.AddColumn(ComArquivo, "linhas_titulo", each PosCab + 1, Int64.Type),
    // D18: a data de referência desfaz a ambiguidade das datas em texto (dd/mm ou m/d). Vem do título
    // ("Data : '01-DEZ-2024'"); os arquivos de dezembro não têm data no título, e aí vem do nome ("01dez2024-1.xls").
    TextoTitulo = Text.Combine(List.Transform(List.FirstN(Table.Column(Dezesseis, Originais{0}), PosCab), each Text.From(_) ?? ""), " "),
    Trecho = Text.Upper(Text.BetweenDelimiters(TextoTitulo, "'", "'")),
    Meses = [JAN = 1, FEV = 2, MAR = 3, ABR = 4, MAI = 5, JUN = 6, JUL = 7, AGO = 8, SET = 9, OUT = 10, NOV = 11, DEZ = 12],
    DataTitulo = try #date(Number.From(Text.End(Trecho, 4)), Record.Field(Meses, Text.Middle(Trecho, 3, 3)), Number.From(Text.Start(Trecho, 2))) otherwise null,
    Nome = Text.Upper(Arquivo),
    DataNome = try #date(Number.From(Text.Middle(Nome, 5, 4)), Record.Field(Meses, Text.Middle(Nome, 2, 3)), Number.From(Text.Start(Nome, 2))) otherwise null,
    ComReferencia = Table.AddColumn(ComTitulo, "data_referencia", each DataTitulo ?? DataNome, type nullable date)
in
    ComReferencia
