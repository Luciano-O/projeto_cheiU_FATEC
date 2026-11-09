// cad_DePara_Grupo
let
    Fonte = cad_Etapa1{[Item = "Cad_DePara_Grupo"]}[Data],
    Colunas = Table.SelectColumns(Fonte, {"grafia_fonte", "grupo", "modalidade"}),
    Tipos = Table.TransformColumnTypes(Colunas, {{"grafia_fonte", type text}, {"grupo", type text}, {"modalidade", type text}}, "pt-BR"),
    Chave = Table.TransformColumns(Tipos, {{"grafia_fonte", each Text.Upper(Text.Trim(_)), type text}}),
    Buffer = Table.Buffer(Chave)
in
    Buffer
