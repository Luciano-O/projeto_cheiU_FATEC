// Conf_CPTM
// Por mês × linha: soma das estações aceitas × "Totais da Linha" do arquivo × soma da estimativa diária.
// A linha "TOTAL" de cada mês compara a soma de todas as estações com "Totais CPTM".
// Aceite da E2.4: diferenca_estimado = 0 em todas as linhas. diferenca_arquivo mostra o arredondamento
// do rateio que a própria CPTM anota no rodapé.
let
    // Só o arquivo que vale para o mês (um mês repetido em outro arquivo não conta duas vezes).
    Linhas = Table.SelectRows(stg_cptm_linhas, each [motivo] = null and [arquivo] = [arquivo_do_mes]),
    Publicado = Table.SelectRows(Linhas, each [tipo_registro] = "total_linha"),
    PubLinha = Table.NestedJoin(Publicado, {"linha_fonte"}, cad_Linha_Trilho, {"linha_fonte"}, "l", JoinKind.LeftOuter),
    PubExp = Table.SelectColumns(Table.ExpandTableColumn(PubLinha, "l", {"id_linha"}, {"id_cad"}), {"mes_inicio", "id_cad", "entradas"}),
    PubRen = Table.RenameColumns(PubExp, {{"id_cad", "id_linha"}, {"entradas", "entradas_arquivo"}}),
    PubGeral = Table.AddColumn(Table.SelectColumns(Table.SelectRows(Linhas, each [tipo_registro] = "total_cptm"), {"mes_inicio", "entradas"}), "id_linha", each "TOTAL", type text),
    PubTodos = Table.Combine({PubRen, Table.RenameColumns(PubGeral, {{"entradas", "entradas_arquivo"}})}),
    Mensal = stg_cptm_mensal_linha,
    Geral = Table.Group(Mensal, {"mes_inicio"}, {{"entradas", each List.Sum([entradas]), Int64.Type}, {"estacoes", each List.Sum([estacoes]), Int64.Type}}),
    MensalTodos = Table.Combine({Mensal, Table.AddColumn(Geral, "id_linha", each "TOTAL", type text)}),
    Estimado = Table.Group(Table.AddColumn(Table.SelectRows(Fato_Transporte, each [modalidade] = "Trem"), "mes_inicio", each Date.StartOfMonth([data]), type date),
        {"mes_inicio", "id_linha"}, {{"soma_diaria_estimada", each List.Sum([passageiros]), Int64.Type}, {"dias", each Table.RowCount(_), Int64.Type}}),
    EstGeral = Table.Group(Estimado, {"mes_inicio"}, {{"soma_diaria_estimada", each List.Sum([soma_diaria_estimada]), Int64.Type}, {"dias", each List.Max([dias]), Int64.Type}}),
    EstTodos = Table.Combine({Estimado, Table.AddColumn(EstGeral, "id_linha", each "TOTAL", type text)}),
    J1 = Table.NestedJoin(MensalTodos, {"mes_inicio", "id_linha"}, PubTodos, {"mes_inicio", "id_linha"}, "p", JoinKind.FullOuter),
    E1 = Table.ExpandTableColumn(J1, "p", {"mes_inicio", "id_linha", "entradas_arquivo"}, {"mes_p", "id_p", "entradas_arquivo"}),
    Chaves = Table.AddColumn(Table.AddColumn(E1, "mes", each [mes_inicio] ?? [mes_p], type date), "linha", each [id_linha] ?? [id_p], type text),
    Base = Table.SelectColumns(Chaves, {"mes", "linha", "estacoes", "entradas", "entradas_arquivo"}),
    J2 = Table.NestedJoin(Base, {"mes", "linha"}, EstTodos, {"mes_inicio", "id_linha"}, "e", JoinKind.LeftOuter),
    E2 = Table.ExpandTableColumn(J2, "e", {"dias", "soma_diaria_estimada"}),
    DifArq = Table.AddColumn(E2, "diferenca_arquivo", each [entradas] - [entradas_arquivo], Int64.Type),
    DifEst = Table.AddColumn(DifArq, "diferenca_estimado", each [soma_diaria_estimada] - [entradas], Int64.Type),
    Renomeado = Table.RenameColumns(DifEst, {{"mes", "mes_inicio"}, {"linha", "id_linha"}, {"entradas", "entradas_estacoes"}}),
    Tipos = Table.TransformColumnTypes(Renomeado, {{"estacoes", Int64.Type}, {"entradas_estacoes", Int64.Type}, {"entradas_arquivo", Int64.Type}, {"dias", Int64.Type}, {"soma_diaria_estimada", Int64.Type}}),
    Ordenado = Table.Sort(Tipos, {{"mes_inicio", Order.Ascending}, {"id_linha", Order.Ascending}})
in
    Ordenado
