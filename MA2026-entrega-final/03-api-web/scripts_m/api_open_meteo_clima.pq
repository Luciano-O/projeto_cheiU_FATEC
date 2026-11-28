// api_open_meteo_clima
// Open-Meteo, arquivo histórico (reanálise ERA5), centro de São Paulo, 2024, hora a hora no fuso America/Sao_Paulo.
// Sem autenticação; uso não comercial gratuito. Resposta: hourly.time, temperature_2m, precipitation, rain.
// Lê a resposta salva por 01-excel/scripts/baixar_clima.py: nesta máquina o Web.Contents do Excel falha com o
// Open-Meteo (a BrasilAPI, em api_brasilapi_feriados, é chamada ao vivo). Chamada direta, para repetir:
//   Web.Contents("https://archive-api.open-meteo.com/v1/archive", [Query = [latitude = "-23.55", longitude = "-46.63",
//   start_date = "2024-01-01", end_date = "2024-12-31", hourly = "temperature_2m,precipitation,rain", timezone = "America/Sao_Paulo"]])
let
    Resposta = Json.Document(File.Contents(pArquivoClima)),
    H = Resposta[hourly],
    Tabela = Table.FromColumns({H[time], H[temperature_2m], H[precipitation], H[rain]},
        type table [momento = text, temperatura_c = number, precipitacao_mm = number, chuva_mm = number])
in
    Tabela
