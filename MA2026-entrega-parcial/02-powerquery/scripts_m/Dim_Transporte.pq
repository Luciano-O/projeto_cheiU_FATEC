// Dim_Transporte
// Uma linha por id_linha. Ônibus: nome, grupo e lote vêm do dia mais recente em que a linha operou.
// Trem: cadastro da Etapa 1 (cad_Linha_Trilho); os dias vêm da estimativa diária.
let
    Fonte = stg_sptrans_diario,
    Ordenado = Table.Sort(Fonte, {{"codigo_linha", Order.Ascending}, {"data", Order.Descending}}),
    Recente = Table.Group(Ordenado, {"codigo_linha"}, {
        {"nome_linha", each [nome_linha]{0}, type text},
        {"grupo", each [grupo]{0}, type text},
        {"lote", each [lote]{0}, type text},
        {"primeiro_dia", each List.Min([data]), type date},
        {"ultimo_dia", each List.Max([data]), type date},
        {"dias_com_operacao", each List.Count(List.Distinct([data])), Int64.Type},
        {"grupos_no_ano", each List.Count(List.Distinct([grupo])), Int64.Type}}),
    Id = Table.AddColumn(Recente, "id_linha", each "ONI-" & [codigo_linha], type text),
    Modalidade = Table.AddColumn(Id, "modalidade", each "Ônibus", type text),
    Operador = Table.AddColumn(Modalidade, "operador", each "SPTrans", type text),
    Colunas = {"id_linha", "codigo_linha", "nome_linha", "modalidade", "operador", "grupo", "lote", "primeiro_dia", "ultimo_dia", "dias_com_operacao", "grupos_no_ano"},
    FinalOni = Table.SelectColumns(Operador, Colunas),
    DiasTrem = Table.Group(Table.SelectRows(stg_cptm_diario_estimado, each [passageiros] > 0), {"id_linha"}, {
        {"primeiro_dia", each List.Min([data]), type date},
        {"ultimo_dia", each List.Max([data]), type date},
        {"dias_com_operacao", each List.Count(List.Distinct([data])), Int64.Type}}),
    Trem = Table.NestedJoin(cad_Linha_Trilho, {"id_linha"}, DiasTrem, {"id_linha"}, "d", JoinKind.LeftOuter),
    ExpTrem = Table.ExpandTableColumn(Trem, "d", {"primeiro_dia", "ultimo_dia", "dias_com_operacao"}),
    Lote = Table.AddColumn(ExpTrem, "lote", each null, type text),
    Grupos = Table.AddColumn(Lote, "grupos_no_ano", each 1, Int64.Type),
    FinalTrem = Table.SelectColumns(Grupos, Colunas),
    Uniao = Table.Combine({FinalOni, FinalTrem})
in
    Uniao
