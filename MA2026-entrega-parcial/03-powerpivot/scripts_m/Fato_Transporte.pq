// Fato_Transporte
let
    Fonte = cad_Etapa2{[Item = "Fato_Transporte"]}[Data],
    Tipos = Table.TransformColumnTypes(Fonte, {{"data", type date}, {"id_linha", type text}, {"modalidade", type text},
        {"passageiros", Int64.Type}, {"pagantes", Int64.Type}, {"integracao", Int64.Type}, {"gratuidades", Int64.Type},
        {"tipo_metrica", type text}, {"origem_dado", type text}})
in
    Tipos
