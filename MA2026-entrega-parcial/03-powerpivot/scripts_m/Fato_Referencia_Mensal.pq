// Fato_Referencia_Mensal
let
    Fonte = cad_Etapa2{[Item = "Fato_Referencia_Mensal"]}[Data],
    Tipos = Table.TransformColumnTypes(Fonte, {{"mes_inicio", type date}, {"grupo", type text}, {"passageiros_publicado", Int64.Type}, {"origem_dado", type text}, {"fonte", type text}})
in
    Tipos
