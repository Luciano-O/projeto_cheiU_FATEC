// Conf_Etapas
// Contagem de linhas etapa por etapa, do arquivo ao fato. Ordem 1–9: SPTrans; 10–19: CPTM.
let
    Arquivos = Table.RowCount(Table.SelectRows(Folder.Files(pPastaSPTrans), each List.Contains({".xls", ".xlsx"}, Text.Lower([Extension])))),
    Linhas = stg_sptrans_linhas,
    Titulo = List.Sum(Table.Group(Linhas, {"arquivo"}, {{"t", each List.Max([linhas_titulo]), Int64.Type}})[t]),
    Contar = (m) => Table.RowCount(Table.SelectRows(Linhas, each [motivo] = m)),
    RejOni = Table.RowCount(Table.SelectRows(Rejeitados, each [fonte] = "SPTrans diário")),
    Cptm = stg_cptm_linhas,
    ArquivosCptm = List.Count(List.Distinct(Cptm[arquivo])),
    TipoCptm = (t) => Table.RowCount(Table.SelectRows(Cptm, each [tipo_registro] = t)),
    Estrutura = TipoCptm("vazia") + TipoCptm("texto") + TipoCptm("cabecalho_linha"),
    Subtotais = TipoCptm("total_servico") + TipoCptm("total_linha") + TipoCptm("total_cptm"),
    Modalidade = (m) => Table.RowCount(Table.SelectRows(Fato_Transporte, each [modalidade] = m)),
    DimModalidade = (m) => Table.RowCount(Table.SelectRows(Dim_Transporte, each [modalidade] = m)),
    Tabela = #table(type table [ordem = Int64.Type, etapa = text, linhas = Int64.Type], {
        {1, "Arquivos diários na pasta", Arquivos},
        {2, "Linhas de título e cabeçalho descartadas (acima dos dados, D1/D2)", Titulo},
        {3, "Linhas lidas abaixo do cabeçalho", Table.RowCount(Linhas)},
        {4, "Rejeitadas: linha vazia (D3)", Contar("Linha vazia")},
        {5, "Rejeitadas: outros motivos", RejOni - Contar("Linha vazia")},
        {6, "Aceitas (dia × linha × empresa)", Table.RowCount(Table.SelectRows(Linhas, each [motivo] = null))},
        {7, "Fato_Transporte: ônibus (dia × linha, D11)", Modalidade("Ônibus")},
        {8, "Dim_Transporte: linhas de ônibus", DimModalidade("Ônibus")},
        {9, "Fato_Referencia_Mensal (mês × grupo)", Table.RowCount(Fato_Referencia_Mensal)},
        {10, "CPTM: arquivos mensais na pasta", ArquivosCptm},
        {11, "CPTM: linhas lidas da aba Embarcados", Table.RowCount(Cptm)},
        {12, "CPTM: descartadas (vazias, títulos, notas e cabeçalhos de linha, D21)", Estrutura},
        {13, "CPTM: descartadas (subtotais e total geral, D21; conferidos em Conf_CPTM)", Subtotais},
        {14, "CPTM: linhas de estação", TipoCptm("estacao")},
        {15, "CPTM: rejeitadas", Table.RowCount(Table.SelectRows(Rejeitados, each [fonte] = "CPTM embarcados"))},
        {16, "CPTM: aceitas (mês × linha × estação)", Table.RowCount(stg_cptm_mensal_estacao)},
        {17, "CPTM: mês × linha", Table.RowCount(stg_cptm_mensal_linha)},
        {18, "Fato_Transporte: trem (dia × linha, estimado)", Modalidade("Trem")},
        {19, "Dim_Transporte: linhas de trem", DimModalidade("Trem")}})
in
    Tabela
