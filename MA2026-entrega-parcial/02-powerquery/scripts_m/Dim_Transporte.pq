// Dim_Transporte
// Uma linha por id_linha. Nome, grupo e lote vêm do dia mais recente em que a linha operou.
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
    Final = Table.SelectColumns(Operador, {"id_linha", "codigo_linha", "nome_linha", "modalidade", "operador", "grupo", "lote", "primeiro_dia", "ultimo_dia", "dias_com_operacao", "grupos_no_ano"})
in
    Final
