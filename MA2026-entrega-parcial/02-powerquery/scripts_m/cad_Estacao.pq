// cad_Estacao
// De-para das estações da Etapa 1: (linha, grafia do arquivo) → nome padronizado (D20, D23).
let
    Fonte = cad_Etapa1{[Item = "Cad_Estacao"]}[Data],
    Texto = Table.TransformColumns(Fonte, {{"linha_fonte", each Text.Trim(Text.From(_)), type text}}),
    Tipos = Table.TransformColumnTypes(Texto, {{"grafia_fonte", type text}, {"estacao", type text}}, "pt-BR"),
    Chave = Table.AddColumn(Tipos, "chave", each [linha_fonte] & "|" & Text.Upper(Text.Trim([grafia_fonte])), type text),
    Buffer = Table.Buffer(Table.SelectColumns(Chave, {"chave", "linha_fonte", "grafia_fonte", "estacao"}))
in
    Buffer
