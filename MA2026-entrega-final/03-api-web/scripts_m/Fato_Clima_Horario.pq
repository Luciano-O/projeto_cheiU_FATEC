// Fato_Clima_Horario
// Grão: data × hora (8.784 linhas em 2024). chovendo = precipitação ≥ 0,1 mm na hora.
// origem_dado = estimado: o arquivo do Open-Meteo é reanálise (modelo ajustado a observações), não medição de estação.
let
    Fonte = api_open_meteo_clima,
    Momento = Table.AddColumn(Fonte, "dt", each DateTime.FromText([momento], [Format = "yyyy-MM-dd'T'HH:mm", Culture = "en-US"]), type datetime),
    Data = Table.AddColumn(Momento, "data", each Date.From([dt]), type date),
    Hora = Table.AddColumn(Data, "hora", each Time.Hour([dt]), Int64.Type),
    Chovendo = Table.AddColumn(Hora, "chovendo", each [precipitacao_mm] >= 0.1, type logical),
    Origem = Table.AddColumn(Chovendo, "origem_dado", each "estimado", type text),
    Final = Table.SelectColumns(Origem, {"data", "hora", "temperatura_c", "precipitacao_mm", "chovendo", "origem_dado"})
in
    Final
