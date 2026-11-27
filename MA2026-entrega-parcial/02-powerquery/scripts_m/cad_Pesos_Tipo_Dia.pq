// cad_Pesos_Tipo_Dia
// Pesos por tipo de dia da Etapa 1 (premissa, decisão 0012), usados para distribuir a CPTM mensal pelos dias.
let
    Fonte = cad_Etapa1{[Item = "Param_Pesos_Tipo_Dia"]}[Data],
    Tipos = Table.TransformColumnTypes(Fonte, {{"tipo_dia", type text}, {"peso", type number}, {"fonte", type text}}, "pt-BR"),
    Buffer = Table.Buffer(Tipos)
in
    Buffer
