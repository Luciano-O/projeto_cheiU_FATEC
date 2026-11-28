// api_brasilapi_feriados
// BrasilAPI, feriados nacionais de 2024. Sem autenticação. Não traz os feriados locais (25/01 municipal, 09/07 estadual).
let
    Resposta = Json.Document(Web.Contents("https://brasilapi.com.br/api/feriados/v1/2024")),
    Tabela = Table.FromRecords(Resposta, {"date", "name", "type"}, MissingField.UseNull),
    Nomes = Table.RenameColumns(Tabela, {{"date", "data"}, {"name", "feriado"}, {"type", "abrangencia"}}),
    Tipos = Table.TransformColumns(Nomes, {{"data", each Date.FromText(_, [Format = "yyyy-MM-dd", Culture = "en-US"]), type date},
        {"abrangencia", each if _ = "national" then "nacional" else _, type text}})
in
    Tipos
