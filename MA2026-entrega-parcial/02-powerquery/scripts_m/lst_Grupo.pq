// lst_Grupo
let
    Fonte = cad_Etapa1{[Item = "Tab_Grupo"]}[Data],
    Lista = List.Buffer(List.Transform(Fonte[grupo], Text.From))
in
    Lista
