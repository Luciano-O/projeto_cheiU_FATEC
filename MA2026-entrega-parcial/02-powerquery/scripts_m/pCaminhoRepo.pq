// pCaminhoRepo
// Raiz do repositório, lida da célula nomeada CaminhoRepo (aba Parametros). A célula deriva o caminho
// do próprio arquivo, então a pasta de trabalho funciona em qualquer clone sem editar nada.
let
    Fonte = Excel.CurrentWorkbook(){[Name = "CaminhoRepo"]}[Content]{0}[Column1],
    ComBarra = if Text.EndsWith(Fonte, "\") then Fonte else Fonte & "\"
in
    ComBarra
