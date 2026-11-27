// stg_cptm_diario_estimado
// Estimativa diária por linha (origem_dado = estimado): o total mensal é distribuído pelos dias do mês
// na proporção do peso do tipo de dia (cad_Pesos_Tipo_Dia, premissa da decisão 0012). O tipo de dia segue
// a Dim_Calendario da Etapa 3: feriado ou ponto facultativo de cad_Feriados, senão sábado, domingo ou útil.
// Arredondamento acumulado: dia k = arred(total × pesos até k ÷ soma) − arred(total × pesos até k−1 ÷ soma),
// então a soma dos dias é exatamente o total do mês.
let
    Feriados = List.Buffer(cad_Feriados[data]),
    Pesos = Record.FromList(cad_Pesos_Tipo_Dia[peso], cad_Pesos_Tipo_Dia[tipo_dia]),
    TipoDia = (d as date) as text =>
        if List.Contains(Feriados, d) then "Feriado"
        else if Date.DayOfWeek(d, Day.Monday) = 5 then "Sábado"
        else if Date.DayOfWeek(d, Day.Monday) = 6 then "Domingo"
        else "Útil",
    Distribuir = (mes as date, total as number) as table =>
        let
            Dias = List.Dates(mes, Date.DaysInMonth(mes), #duration(1, 0, 0, 0)),
            Tipos = List.Transform(Dias, TipoDia),
            P = List.Transform(Tipos, each Record.Field(Pesos, _)),
            S = List.Sum(P),
            Acum = List.Transform({0 .. List.Count(P)}, (k) => Number.Round(total * List.Sum({0} & List.FirstN(P, k)) / S)),
            Valores = List.Transform({0 .. List.Count(P) - 1}, (k) => Acum{k + 1} - Acum{k})
        in
            Table.FromColumns({Dias, Tipos, P, Valores}, type table [data = date, tipo_dia = text, peso = number, passageiros = number]),
    Fonte = stg_cptm_mensal_linha,
    ComDias = Table.AddColumn(Fonte, "d", each Distribuir([mes_inicio], [entradas])),
    Exp = Table.ExpandTableColumn(Table.SelectColumns(ComDias, {"id_linha", "mes_inicio", "entradas", "d"}), "d", {"data", "tipo_dia", "peso", "passageiros"}),
    Renomeado = Table.RenameColumns(Exp, {{"entradas", "entradas_mes"}}),
    Origem = Table.AddColumn(Renomeado, "origem_dado", each "estimado", type text),
    Tipado = Table.TransformColumnTypes(Origem, {{"data", type date}, {"passageiros", Int64.Type}, {"entradas_mes", Int64.Type}}),
    Final = Table.SelectColumns(Tipado, {"data", "id_linha", "tipo_dia", "peso", "passageiros", "mes_inicio", "entradas_mes", "origem_dado"})
in
    Final
