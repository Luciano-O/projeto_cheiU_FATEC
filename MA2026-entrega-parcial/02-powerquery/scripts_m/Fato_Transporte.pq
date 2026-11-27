// Fato_Transporte
// Grão: data × id_linha. Ônibus (SPTrans, transportados, real) e Trem (CPTM, embarcados, estimado por dia
// a partir do mensal, decisão 0012). O Metrô entra com a E2.3.
let
    Onibus = stg_sptrans_diario,
    IdOni = Table.AddColumn(Onibus, "id_linha", each "ONI-" & [codigo_linha], type text),
    ModOni = Table.AddColumn(IdOni, "modalidade", each "Ônibus", type text),
    MetOni = Table.AddColumn(ModOni, "tipo_metrica", each "transportados", type text),
    OrigOni = Table.AddColumn(MetOni, "origem_dado", each "real", type text),
    Colunas = {"data", "id_linha", "modalidade", "passageiros", "pagantes", "integracao", "gratuidades", "tipo_metrica", "origem_dado"},
    FinalOni = Table.SelectColumns(OrigOni, Colunas),
    Trem = stg_cptm_diario_estimado,
    ModTrem = Table.AddColumn(Trem, "modalidade", each "Trem", type text),
    // O mensal da CPTM traz tarifas, mas a distribuição diária é só do total: as aberturas ficam vazias.
    Vazias = List.Accumulate({"pagantes", "integracao", "gratuidades"}, ModTrem, (t, c) => Table.AddColumn(t, c, each null, Int64.Type)),
    MetTrem = Table.AddColumn(Vazias, "tipo_metrica", each "embarcados", type text),
    FinalTrem = Table.SelectColumns(MetTrem, Colunas),
    Uniao = Table.Combine({FinalOni, FinalTrem}),
    Tipos = Table.TransformColumnTypes(Uniao, {{"data", type date}, {"passageiros", Int64.Type}, {"pagantes", Int64.Type}, {"integracao", Int64.Type},
        {"gratuidades", Int64.Type}, {"id_linha", type text}, {"modalidade", type text}, {"tipo_metrica", type text}, {"origem_dado", type text}})
in
    Tipos
