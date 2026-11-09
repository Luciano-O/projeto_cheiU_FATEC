// Rejeitados
// Fora da estrela: entra no modelo só para as contagens de conferência.
let
    Fonte = cad_Etapa2{[Item = "Rejeitados"]}[Data],
    Tipos = Table.TransformColumnTypes(Fonte, {{"fonte", type text}, {"arquivo", type text}, {"linha_origem", Int64.Type}, {"motivo", type text}, {"data", type date}, {"valor_original", type text}})
in
    Tipos
