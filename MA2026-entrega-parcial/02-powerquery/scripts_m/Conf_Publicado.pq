// Conf_Publicado
// Soma mensal do fato × total publicado pela SPTrans, por mês (só os três grupos oficiais).
let
    Fato = Table.NestedJoin(Fato_Transporte, {"id_linha"}, Dim_Transporte, {"id_linha"}, "d", JoinKind.LeftOuter),
    ComGrupo = Table.ExpandTableColumn(Fato, "d", {"grupo"}),
    Mes = Table.AddColumn(ComGrupo, "mes_inicio", each Date.StartOfMonth([data]), type date),
    Oficiais = Table.SelectRows(Mes, each [grupo] <> "Outros"),
    Calc = Table.Group(Oficiais, {"mes_inicio"}, {{"passageiros_calculado", each List.Sum([passageiros]), type number}}),
    Pub = Table.Group(Fato_Referencia_Mensal, {"mes_inicio"}, {{"passageiros_publicado", each List.Sum([passageiros_publicado]), type number}}),
    Junta = Table.NestedJoin(Calc, {"mes_inicio"}, Pub, {"mes_inicio"}, "p", JoinKind.FullOuter),
    Exp = Table.ExpandTableColumn(Junta, "p", {"mes_inicio", "passageiros_publicado"}, {"mes_pub", "passageiros_publicado"}),
    MesFinal = Table.AddColumn(Exp, "mes", each [mes_inicio] ?? [mes_pub], type date),
    Dif = Table.AddColumn(MesFinal, "diferenca_pct", each if [passageiros_publicado] = null or [passageiros_calculado] = null then null else ([passageiros_calculado] - [passageiros_publicado]) / [passageiros_publicado], type nullable number),
    Final = Table.Sort(Table.SelectColumns(Dif, {"mes", "passageiros_calculado", "passageiros_publicado", "diferenca_pct"}), {{"mes", Order.Ascending}})
in
    Final
