// stg_cptm_linhas
// Todas as linhas da aba Embarcados de cada xlsx mensal da CPTM, classificadas por tipo_registro (D21).
// O mês vem do nome do arquivo, não do título (D19). Só as linhas de estação seguem adiante; as que não
// têm mês, linha ou estação cadastrada recebem um motivo e vão para Rejeitados. Se dois arquivos trazem o
// mesmo mês, vale o de menor nome (como na SPTrans, D13): as estações do outro vão para Rejeitados.
let
    Fonte = Folder.Files(pPastaCPTM),
    Planilhas = Table.SelectRows(Fonte, each Text.Lower([Extension]) = ".xlsx" and not Text.StartsWith([Name], "~$")),
    ComMes = Table.AddColumn(Planilhas, "mes_inicio", each
        try #date(2024, Number.From(Text.Trim(Text.BetweenDelimiters([Name], "2024 - ", "-"))), 1) otherwise null, type nullable date),
    Meses = Table.Buffer(Table.SelectColumns(ComMes, {"Name", "mes_inicio"})),
    DoMes = Table.AddColumn(ComMes, "arquivo_do_mes", (r) => List.Min(Table.SelectRows(Meses, each [mes_inicio] = r[mes_inicio])[Name]), type text),
    Lidos = Table.AddColumn(DoMes, "Tabela", each
        let
            Pasta = Excel.Workbook([Content], null, true),
            Aba = Table.SelectRows(Pasta, each [Kind] = "Sheet"){0}[Data],
            Oito = Table.SelectColumns(Aba, List.FirstN(Table.ColumnNames(Aba), 8)),
            Nomes = Table.RenameColumns(Oito, List.Zip({List.FirstN(Table.ColumnNames(Aba), 8),
                {"c_a", "c_b", "grat_sbe", "pagantes", "transferencias", "nao_tarifados", "entradas", "total_coluna_h"}})),
            ComLinha = Table.AddIndexColumn(Nomes, "linha_origem", 1, 1, Int64.Type)
        in
            ComLinha),
    Exp = Table.ExpandTableColumn(Table.SelectColumns(Lidos, {"Name", "mes_inicio", "arquivo_do_mes", "Tabela"}), "Tabela",
        {"c_a", "c_b", "grat_sbe", "pagantes", "transferencias", "nao_tarifados", "entradas", "total_coluna_h", "linha_origem"}),
    Arquivo = Table.RenameColumns(Exp, {{"Name", "arquivo"}}),
    // D20: o rótulo da linha vem com espaço não separável ("\xa0LINHA 10").
    TextoA = Table.AddColumn(Arquivo, "texto_a", each Text.Trim(Text.Replace(Text.From([c_a]) ?? "", "#(00A0)", " ")), type text),
    TextoB = Table.AddColumn(TextoA, "texto_b", each Text.Trim(Text.Replace(Text.From([c_b]) ?? "", "#(00A0)", " ")), type text),
    Tipo = Table.AddColumn(TextoB, "tipo_registro", each
        if Text.StartsWith(Text.Upper([texto_a]), "LINHA ") then "cabecalho_linha"
        else if [texto_a] = "Totais da Linha" then "total_linha"
        else if [texto_a] = "Totais CPTM" then "total_cptm"
        else if [texto_b] = "Totais do Serviço" then "total_servico"
        else if [texto_b] <> "" and [entradas] is number then "estacao"
        else if [texto_a] = "" and [texto_b] = "" and List.NonNullCount({[grat_sbe], [pagantes], [transferencias], [nao_tarifados], [entradas], [total_coluna_h]}) = 0 then "vazia"
        else "texto", type text),
    // A linha da estação vem do último cabeçalho "LINHA n" acima dela, no mesmo arquivo.
    Rotulo = Table.AddColumn(Tipo, "linha_fonte", each if [tipo_registro] = "cabecalho_linha" then Text.Trim(Text.AfterDelimiter([texto_a], " ")) else null, type text),
    Ordenado = Table.Sort(Rotulo, {{"arquivo", Order.Ascending}, {"linha_origem", Order.Ascending}}),
    PorArquivo = Table.Group(Ordenado, {"arquivo"}, {{"t", each Table.FillDown(_, {"linha_fonte"}), type table}}),
    Preenchido = Table.Combine(PorArquivo[t]),
    Chave = Table.AddColumn(Preenchido, "chave", each (if [linha_fonte] = null then "" else [linha_fonte]) & "|" & Text.Upper([texto_b]), type text),
    ComEstacao = Table.NestedJoin(Chave, {"chave"}, cad_Estacao, {"chave"}, "e", JoinKind.LeftOuter),
    ExpEst = Table.ExpandTableColumn(ComEstacao, "e", {"estacao"}),
    ComLinhaCad = Table.NestedJoin(ExpEst, {"linha_fonte"}, cad_Linha_Trilho, {"linha_fonte"}, "l", JoinKind.LeftOuter),
    ExpLinha = Table.ExpandTableColumn(ComLinhaCad, "l", {"id_linha"}),
    Motivo = Table.AddColumn(ExpLinha, "motivo", each
        if [tipo_registro] <> "estacao" then null
        else if [mes_inicio] = null then "Mês não identificado no nome do arquivo"
        else if [arquivo] <> [arquivo_do_mes] then "Arquivo duplicado (mês já lido em outro arquivo)"
        else if [id_linha] = null then "Linha sem cadastro em Cad_Linha_Trilho"
        else if [estacao] = null then "Estação sem de-para em Cad_Estacao"
        else null, type nullable text),
    // Nas linhas de cabeçalho e de texto essas colunas trazem rótulos: só números seguem.
    SoNumero = (v) => if v is number then v else null,
    Numeros = Table.TransformColumns(Motivo, {{"grat_sbe", SoNumero, type nullable number}, {"pagantes", SoNumero, type nullable number},
        {"transferencias", SoNumero, type nullable number}, {"nao_tarifados", SoNumero, type nullable number},
        {"entradas", SoNumero, type nullable number}, {"total_coluna_h", SoNumero, type nullable number}}),
    Final = Table.SelectColumns(Numeros, {"arquivo", "arquivo_do_mes", "linha_origem", "mes_inicio", "tipo_registro", "linha_fonte", "id_linha", "texto_a", "texto_b",
        "estacao", "grat_sbe", "pagantes", "transferencias", "nao_tarifados", "entradas", "total_coluna_h", "motivo"})
in
    Final
