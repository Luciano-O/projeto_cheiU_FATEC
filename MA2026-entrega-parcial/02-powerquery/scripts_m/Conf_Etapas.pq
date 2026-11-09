// Conf_Etapas
// Contagem de linhas etapa por etapa, do arquivo ao fato.
let
    Arquivos = Table.RowCount(Table.SelectRows(Folder.Files(pPastaSPTrans), each List.Contains({".xls", ".xlsx"}, Text.Lower([Extension])))),
    Linhas = stg_sptrans_linhas,
    Titulo = List.Sum(Table.Group(Linhas, {"arquivo"}, {{"t", each List.Max([linhas_titulo]), Int64.Type}})[t]),
    Contar = (m) => Table.RowCount(Table.SelectRows(Linhas, each [motivo] = m)),
    Tabela = #table(type table [ordem = Int64.Type, etapa = text, linhas = Int64.Type], {
        {1, "Arquivos diários na pasta", Arquivos},
        {2, "Linhas de título e cabeçalho descartadas (acima dos dados, D1/D2)", Titulo},
        {3, "Linhas lidas abaixo do cabeçalho", Table.RowCount(Linhas)},
        {4, "Rejeitadas: linha vazia (D3)", Contar("Linha vazia")},
        {5, "Rejeitadas: outros motivos", Table.RowCount(Rejeitados) - Contar("Linha vazia")},
        {6, "Aceitas (dia × linha × empresa)", Table.RowCount(Table.SelectRows(Linhas, each [motivo] = null))},
        {7, "Fato_Transporte (dia × linha, D11)", Table.RowCount(Fato_Transporte)},
        {8, "Dim_Transporte (linhas de ônibus)", Table.RowCount(Dim_Transporte)},
        {9, "Fato_Referencia_Mensal (mês × grupo)", Table.RowCount(Fato_Referencia_Mensal)}})
in
    Tabela
