// Conf_Motivos
let
    Fonte = Table.Group(Rejeitados, {"fonte", "motivo"}, {{"linhas", each Table.RowCount(_), Int64.Type}, {"arquivos", each List.Count(List.Distinct([arquivo])), Int64.Type}}),
    Ordenado = Table.Sort(Fonte, {{"linhas", Order.Descending}})
in
    Ordenado
