// Conf_Complemento_Jul
// Julho/2024 por linha: consolidado (2ª versão) × soma dos diários. Uma linha é complementada em 08/07
// quando o consolidado tem mais passageiros e o diário de 08/07 não traz a linha (D24, decisão 0014).
// Toda linha com diferença diferente de 0 aparece aqui; "nao_explicada" = diferença que o complemento não cobre.
let
    Jul = Table.SelectRows(stg_sptrans_diario, each Date.Year([data]) = 2024 and Date.Month([data]) = 7),
    Diarios = Table.Group(Jul, {"codigo_linha"}, {
        {"passageiros", each List.Sum([passageiros]), type number},
        {"pagantes", each List.Sum([pagantes]), type number},
        {"integracao", each List.Sum([integracao]), type number},
        {"gratuidades", each List.Sum([gratuidades]), type number},
        {"tem_0807", each List.Contains([data], #date(2024, 7, 8)), type logical}}),
    Junta = Table.NestedJoin(stg_sptrans_consolidado_jul, {"codigo_linha"}, Diarios, {"codigo_linha"}, "d", JoinKind.FullOuter),
    Exp = Table.ExpandTableColumn(Junta, "d", {"codigo_linha", "passageiros", "pagantes", "integracao", "gratuidades", "tem_0807"},
        {"codigo_d", "passageiros_d", "pagantes_d", "integracao_d", "gratuidades_d", "tem_0807"}),
    Chave = Table.AddColumn(Exp, "linha", each [codigo_linha] ?? [codigo_d], type text),
    Dif = Table.AddColumn(Chave, "diferenca", each (([passageiros] ?? 0) - ([passageiros_d] ?? 0)), type number),
    ComDif = Table.SelectRows(Dif, each [diferenca] <> 0),
    Complementa = Table.AddColumn(ComDif, "complementada", each [diferenca] > 0 and [passageiros_d] <> null and not [tem_0807], type logical),
    NaoExplicada = Table.AddColumn(Complementa, "nao_explicada", each if [complementada] then 0 else [diferenca], type number),
    DifPag = Table.AddColumn(NaoExplicada, "dif_pagantes", each ([pagantes] ?? 0) - ([pagantes_d] ?? 0), type number),
    DifInt = Table.AddColumn(DifPag, "dif_integracao", each ([integracao] ?? 0) - ([integracao_d] ?? 0), type number),
    DifGrat = Table.AddColumn(DifInt, "dif_gratuidades", each ([gratuidades] ?? 0) - ([gratuidades_d] ?? 0), type number),
    Renomeado = Table.RenameColumns(DifGrat, {{"passageiros", "consolidado"}, {"passageiros_d", "soma_diarios"}}),
    Final = Table.SelectColumns(Renomeado, {"linha", "consolidado", "soma_diarios", "diferenca", "tem_0807", "complementada", "nao_explicada",
        "dif_pagantes", "dif_integracao", "dif_gratuidades"}),
    Tipos = Table.TransformColumnTypes(Final, {{"consolidado", Int64.Type}, {"soma_diarios", Int64.Type}, {"diferenca", Int64.Type}, {"nao_explicada", Int64.Type},
        {"dif_pagantes", Int64.Type}, {"dif_integracao", Int64.Type}, {"dif_gratuidades", Int64.Type}}),
    Ordenado = Table.Sort(Tipos, {{"linha", Order.Ascending}})
in
    Ordenado
