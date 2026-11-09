// pCaminhoRepo
// Raiz do repositório, lida da célula nomeada CaminhoRepo (aba Parametros), que deriva o caminho do próprio arquivo.
let
    Fonte = Excel.CurrentWorkbook(){[Name = "CaminhoRepo"]}[Content]{0}[Column1],
    ComBarra = if Text.EndsWith(Fonte, "\") then Fonte else Fonte & "\"
in
    ComBarra
