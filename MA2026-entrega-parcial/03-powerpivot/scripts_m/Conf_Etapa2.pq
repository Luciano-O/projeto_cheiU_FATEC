// Conf_Etapa2
// Conf_Reconciliacao da Etapa 2: os números contra os quais a aba Conferencia compara o modelo.
let
    Fonte = cad_Etapa2{[Item = "Conf_Reconciliacao"]}[Data],
    Tipos = Table.TransformColumnTypes(Fonte, {{"fonte", type text}, {"linhas_lidas", Int64.Type}, {"linhas_aceitas", Int64.Type},
        {"linhas_rejeitadas", Int64.Type}, {"diferenca_linhas", Int64.Type}, {"linhas_no_fato", Int64.Type},
        {"passageiros_aceitos", type number}, {"passageiros_no_fato", type number}, {"diferenca_passageiros", type number}})
in
    Tipos
