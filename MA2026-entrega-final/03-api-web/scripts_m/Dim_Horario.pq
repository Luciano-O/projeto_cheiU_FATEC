// Dim_Horario
// Hora 0–23 com rótulo e período do dia. As faixas de pico entram com o perfil horário da OD (E2.6, E3.4).
let
    Horas = Table.FromList({0 .. 23}, Splitter.SplitByNothing(), type table [hora = Int64.Type]),
    Rotulo = Table.AddColumn(Horas, "hora_rotulo", each Text.PadStart(Text.From([hora]), 2, "0") & "h", type text),
    Periodo = Table.AddColumn(Rotulo, "periodo", each
        if [hora] < 6 then "Madrugada" else if [hora] < 12 then "Manhã" else if [hora] < 18 then "Tarde" else "Noite", type text),
    Ordem = Table.AddColumn(Periodo, "ordem_periodo", each
        if [hora] < 6 then 1 else if [hora] < 12 then 2 else if [hora] < 18 then 3 else 4, Int64.Type)
in
    Ordem
