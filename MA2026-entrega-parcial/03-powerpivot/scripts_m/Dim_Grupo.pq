// Dim_Grupo
let
    Fonte = cad_Etapa2{[Item = "Dim_Grupo"]}[Data],
    Tipos = Table.TransformColumnTypes(Fonte, {{"grupo", type text}, {"modalidade", type text}, {"ordem", Int64.Type}, {"grupo_oficial", type logical}})
in
    Tipos
