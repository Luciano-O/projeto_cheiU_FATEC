// Dim_Grupo
// Grupos da SPTrans (cad_DePara_Grupo) e o grupo dos trilhos (cad_Linha_Trilho). grupo_oficial marca os três
// grupos oficiais da SPTrans, os únicos comparados com o total publicado.
let
    Onibus = Table.Distinct(Table.SelectColumns(cad_DePara_Grupo, {"grupo", "modalidade"}), {"grupo"}),
    OficialOni = Table.AddColumn(Onibus, "grupo_oficial", each [grupo] <> "Outros", type logical),
    Trilho = Table.Distinct(Table.SelectColumns(cad_Linha_Trilho, {"grupo", "modalidade"}), {"grupo"}),
    OficialTri = Table.AddColumn(Trilho, "grupo_oficial", each false, type logical),
    Uniao = Table.Distinct(Table.Combine({OficialOni, OficialTri}), {"grupo"}),
    Ordem = Table.AddColumn(Uniao, "ordem", each List.PositionOf(lst_Grupo, [grupo]) + 1, Int64.Type),
    Colunas = Table.SelectColumns(Ordem, {"grupo", "modalidade", "ordem", "grupo_oficial"}),
    Ordenado = Table.Sort(Colunas, {{"ordem", Order.Ascending}})
in
    Ordenado
