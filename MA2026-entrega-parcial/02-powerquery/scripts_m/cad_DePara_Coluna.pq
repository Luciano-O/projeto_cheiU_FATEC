// cad_DePara_Coluna
let
    Fonte = cad_Etapa1{[Item = "Cad_DePara_Coluna"]}[Data],
    Tipos = Table.TransformColumnTypes(Fonte, {{"grafia_fonte", type text}, {"coluna_padrao", type text}}, "pt-BR"),
    Chave = Table.TransformColumns(Tipos, {{"grafia_fonte", each Text.Upper(Text.Trim(_)), type text}}),
    Buffer = Table.Buffer(Chave)
in
    Buffer
