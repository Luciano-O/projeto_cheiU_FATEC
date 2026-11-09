// Dim_Calendario
// 2024 contínuo, gerado aqui. Feriados da Etapa 1 (via Ref_Feriados da Etapa 2), provisórios até a BrasilAPI (Etapa 6).
let
    Datas = List.Dates(#date(2024, 1, 1), 366, #duration(1, 0, 0, 0)),
    Base = Table.FromList(Datas, Splitter.SplitByNothing(), type table [data = date]),
    Feriados = Table.TransformColumnTypes(cad_Etapa2{[Item = "Ref_Feriados"]}[Data], {{"data", type date}, {"feriado", type text}, {"abrangencia", type text}}),
    ComFeriado = Table.NestedJoin(Base, {"data"}, Feriados, {"data"}, "f", JoinKind.LeftOuter),
    Exp = Table.ExpandTableColumn(ComFeriado, "f", {"feriado"}, {"feriado_nome"}),
    Ano = Table.AddColumn(Exp, "ano", each Date.Year([data]), Int64.Type),
    Mes = Table.AddColumn(Ano, "mes", each Date.Month([data]), Int64.Type),
    NomeMes = Table.AddColumn(Mes, "nome_mes", each Text.Proper(Date.MonthName([data], "pt-BR")), type text),
    Rotulo = Table.AddColumn(NomeMes, "mes_rotulo", each Text.PadStart(Text.From([mes]), 2, "0") & " - " & [nome_mes], type text),
    MesInicio = Table.AddColumn(Rotulo, "mes_inicio", each Date.StartOfMonth([data]), type date),
    Dia = Table.AddColumn(MesInicio, "dia", each Date.Day([data]), Int64.Type),
    DiaSemana = Table.AddColumn(Dia, "dia_semana", each Date.DayOfWeek([data], Day.Monday) + 1, Int64.Type),
    NomeDia = Table.AddColumn(DiaSemana, "nome_dia", each Text.Proper(Date.DayOfWeekName([data], "pt-BR")), type text),
    Semana = Table.AddColumn(NomeDia, "semana_ano", each Date.WeekOfYear([data], Day.Sunday), Int64.Type),
    TipoDia = Table.AddColumn(Semana, "tipo_dia", each
        if [feriado_nome] <> null then "Feriado"
        else if [dia_semana] = 6 then "Sábado"
        else if [dia_semana] = 7 then "Domingo"
        else "Útil", type text),
    Ordenado = Table.Sort(TipoDia, {{"data", Order.Ascending}})
in
    Ordenado
