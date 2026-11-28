// Conf_Feriados
// BrasilAPI × lista manual da Etapa 1, data a data. situacao explica cada diferença (E6.2).
let
    Api = api_brasilapi_feriados,
    Manual = Table.TransformColumnTypes(cad_Etapa2{[Item = "Ref_Feriados"]}[Data], {{"data", type date}, {"feriado", type text}, {"abrangencia", type text}}),
    Junta = Table.NestedJoin(Api, {"data"}, Manual, {"data"}, "m", JoinKind.FullOuter),
    Exp = Table.ExpandTableColumn(Junta, "m", {"data", "feriado", "abrangencia"}, {"data_manual", "feriado_manual", "abrangencia_manual"}),
    Data = Table.AddColumn(Exp, "data_feriado", each [data] ?? [data_manual], type date),
    Situacao = Table.AddColumn(Data, "situacao", each
        if [data] <> null and [data_manual] <> null then "nas duas fontes"
        else if [data] <> null then "só na BrasilAPI: entra no calendário"
        else "só na lista manual (feriado local): entra no calendário", type text),
    Final = Table.SelectColumns(Table.RenameColumns(Situacao, {{"feriado", "feriado_api"}}), {"data_feriado", "feriado_api", "feriado_manual", "abrangencia_manual", "situacao"}),
    Ordenado = Table.Sort(Final, {{"data_feriado", Order.Ascending}})
in
    Ordenado
