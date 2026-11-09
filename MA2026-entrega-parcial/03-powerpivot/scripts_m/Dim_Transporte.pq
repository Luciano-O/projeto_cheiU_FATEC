// Dim_Transporte
let
    Fonte = cad_Etapa2{[Item = "Dim_Transporte"]}[Data],
    Tipos = Table.TransformColumnTypes(Fonte, {{"id_linha", type text}, {"codigo_linha", type text}, {"nome_linha", type text},
        {"modalidade", type text}, {"operador", type text}, {"grupo", type text}, {"lote", type text},
        {"primeiro_dia", type date}, {"ultimo_dia", type date}, {"dias_com_operacao", Int64.Type}, {"grupos_no_ano", Int64.Type}}),
    Rotulo = Table.AddColumn(Tipos, "linha_rotulo", each [codigo_linha] & " - " & [nome_linha], type text)
in
    Rotulo
