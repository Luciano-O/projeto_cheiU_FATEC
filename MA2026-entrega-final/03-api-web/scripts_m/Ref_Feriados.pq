// Ref_Feriados
// Feriados do calendário: BrasilAPI (nacionais) mais os da lista manual da Etapa 1 que a API não traz
// (25/01 municipal, 09/07 estadual). A lista manual passa a ser só reserva (E6.2).
let
    Api = Table.AddColumn(api_brasilapi_feriados, "fonte_feriado", each "BrasilAPI", type text),
    Manual = Table.TransformColumnTypes(cad_Etapa2{[Item = "Ref_Feriados"]}[Data], {{"data", type date}, {"feriado", type text}, {"abrangencia", type text}}),
    SoManual = Table.SelectRows(Manual, each not List.Contains(Api[data], [data])),
    Locais = Table.AddColumn(SoManual, "fonte_feriado", each "Lista manual (Etapa 1)", type text),
    Uniao = Table.Sort(Table.Combine({Api, Locais}), {{"data", Order.Ascending}})
in
    Uniao
