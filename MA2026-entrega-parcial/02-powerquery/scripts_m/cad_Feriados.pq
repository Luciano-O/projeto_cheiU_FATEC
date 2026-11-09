// cad_Feriados
let
    Fonte = cad_Etapa1{[Item = "Cad_Feriados_2024"]}[Data],
    Tipos = Table.TransformColumnTypes(Fonte, {{"data", type date}, {"feriado", type text}, {"abrangencia", type text}}, "pt-BR")
in
    Tipos
