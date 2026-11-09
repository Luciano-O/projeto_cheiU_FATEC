// Fato_Transporte
// Grão: data × id_linha. Hoje só Ônibus (SPTrans, real); Metrô e CPTM entram quando houver arquivo (E2.3, E2.4).
let
    Fonte = stg_sptrans_diario,
    Id = Table.AddColumn(Fonte, "id_linha", each "ONI-" & [codigo_linha], type text),
    Modalidade = Table.AddColumn(Id, "modalidade", each "Ônibus", type text),
    Metrica = Table.AddColumn(Modalidade, "tipo_metrica", each "transportados", type text),
    Origem = Table.AddColumn(Metrica, "origem_dado", each "real", type text),
    Final = Table.SelectColumns(Origem, {"data", "id_linha", "modalidade", "passageiros", "pagantes", "integracao", "gratuidades", "tipo_metrica", "origem_dado"}),
    Tipos = Table.TransformColumnTypes(Final, {{"data", type date}, {"passageiros", Int64.Type}, {"pagantes", Int64.Type}, {"integracao", Int64.Type}, {"gratuidades", Int64.Type}})
in
    Tipos
