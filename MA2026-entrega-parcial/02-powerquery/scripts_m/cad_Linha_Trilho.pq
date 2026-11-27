// cad_Linha_Trilho
// Linhas de trilho da Etapa 1: código do arquivo da fonte → id_linha, nome, operador e grupo.
let
    Fonte = cad_Etapa1{[Item = "Cad_Linha_Trilho"]}[Data],
    Texto = Table.TransformColumns(Fonte, {{"linha_fonte", each Text.Trim(Text.From(_)), type text}}),
    Tipos = Table.TransformColumnTypes(Texto, {{"id_linha", type text}, {"codigo_linha", type text}, {"nome_linha", type text},
        {"modalidade", type text}, {"operador", type text}, {"grupo", type text}}, "pt-BR"),
    Buffer = Table.Buffer(Tipos)
in
    Buffer
