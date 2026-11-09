// Dim_Grupo
let
    Fonte = cad_DePara_Grupo,
    Distintos = Table.Distinct(Table.SelectColumns(Fonte, {"grupo", "modalidade"}), {"grupo"}),
    Ordem = Table.AddColumn(Distintos, "ordem", each List.PositionOf(lst_Grupo, [grupo]) + 1, Int64.Type),
    Oficial = Table.AddColumn(Ordem, "grupo_oficial", each [grupo] <> "Outros", type logical),
    Ordenado = Table.Sort(Oficial, {{"ordem", Order.Ascending}})
in
    Ordenado
