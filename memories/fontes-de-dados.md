# Fontes de dados e APIs

Levantamento inicial verificado em 2026-10-16. Atualize a data de verificação ao confirmar ou corrigir uma fonte.

Resumo: **nenhuma fonte pública traz demanda por hora** de ônibus, Metrô ou CPTM. O único dado com hora e cadeia modal é a Pesquisa Origem-Destino 2023. Por isso a estratégia é híbrida (ver `decisoes/0001`).

## SPTrans — Passageiros transportados (ônibus)

- Índice: https://prefeitura.sp.gov.br/web/mobilidade/w/institucional/sptrans/acesso_a_informacao/152416 → uma página por ano, 2015–2026 (ex. https://prefeitura.sp.gov.br/web/mobilidade/w/passageiros-transportados-2025).
- Download direto, sem login. Um arquivo por **dia**, mais um "consolidado" mensal. Formatos `.xls` ou `.xlsx`.
- Nomes de arquivo sem padrão (ex. `.../documents/d/mobilidade/31jul2025-xlsx`, `.../consolidado-dezembro-2025-xlsx`): extraia os links da página de cada ano.
- Estrutura (conferida em 31/07/2025):
  - cabeçalho na linha 4, ~1.326 linhas por arquivo;
  - colunas Data, Grupo (Estrutural / Local Articulação / Distribuição), Lote, Empresa, Linha (ex. `917M10 - MORRO GRANDE/METRO ANA ROSA`);
  - passageiros por tipo de pagamento (dinheiro, BU Comum/VT, Estudante, mensais, Pagantes, integração ônibus→ônibus, gratuidades) e `Tot Passageiros Transportados`.
- Granularidade: **dia × linha × empresa/lote**. Não há dado por hora.
- Ainda não verificado: se o consolidado mensal traz dia × linha (o que permitiria baixar só 12 arquivos por ano) — passo E1.1.
- Totais mensais do sistema por grupo, 2013 a set/2026, em tabela HTML: https://prefeitura.sp.gov.br/web/mobilidade/w/institucional/sptrans/acesso_a_informacao/245234. Servem para reconciliar.

## API Olho Vivo (SPTrans)

- Documentação: https://www.sptrans.com.br/desenvolvedores/api-do-olho-vivo-guia-de-referencia/documentacao-api/
- Base: `https://api.olhovivo.sptrans.com.br/v2.1` (só HTTPS desde 2024).
- Autenticação:
  1. cadastro no DevPlace (https://www.sptrans.com.br/desenvolvedores/), com confirmação por e-mail;
  2. em "Meus Aplicativos", criar um app para obter o token;
  3. `POST /Login/Autenticar?token=…` → `true`/`false`; a resposta define um **cookie de sessão** que deve acompanhar as chamadas seguintes (sem ele: 401 "Authorization has been denied").
- Endpoints:
  - linhas: `/Linha/Buscar?termosBusca=`, `/Linha/BuscarLinhaSentido`
  - paradas: `/Parada/Buscar`, `/Parada/BuscarParadasPorLinha?codigoLinha=`, `/Parada/BuscarParadasPorCorredor`
  - listas: `/Corredor`, `/Empresa`
  - posição: `/Posicao`, `/Posicao/Linha`, `/Posicao/Garagem`
  - previsão: `/Previsao`, `/Previsao/Linha`, `/Previsao/Parada`
  - `/KMZ...` retorna mapas de velocidade em KMZ, não JSON.
- Sem limite de requisições documentado. **Não traz passageiros nem ocupação**: só posição, acessibilidade, horários e previsões.
- Power Query (`Web.Contents`) não mantém a sessão por cookie. Use VBA com um único objeto `WinHttp.WinHttpRequest.5.1` (ele guarda o cookie entre chamadas) — ver `decisoes/0006`.

## SPTrans — GTFS

- Download no DevPlace com o mesmo login da Olho Vivo; sem link público direto. Espelhos (TUMI, transitfeeds) estão desatualizados.
- Conteúdo: agency, routes, trips, stops, stop_times, calendar, **shapes**, **frequencies** (headways por faixa horária).
- A verificar após o download: se `routes.txt` inclui Metrô e CPTM (`route_type` 1/2).
- O feed é o atual (2026), não o de 2024: limitação a documentar na oferta.

## Metrô SP — Demanda

- https://transparencia.metrosp.com.br/dataset/demanda — CSV e PDF com link direto, sem login, 2016–2026 (2016–2019 só em zip).
- "Entrada de Passageiros por Estação – Diária" (conferido):
  - valores em **milhares**;
  - layout largo: um bloco por mês e linha, códigos de estação nas colunas (exige unpivot);
  - exemplo: `https://transparencia.metrosp.com.br/sites/default/files/Entrada%20de%20Passageiros%20por%20Esta%C3%A7%C3%A3o%20-%20Di%C3%A1ria%20-%202026_5.csv`.
- Mensal por linha: "Passageiros Transportados por Linha" e "Entrada por Linha", com Total, MDU (média dia útil), MSA (sábado), MDO (domingo), MAX. Também há média de dia útil por estação (entradas + transferências).
- Formato: separador `;`, encoding Latin-1, vírgula decimal.
- Cobre só as linhas **1, 2, 3 e 15**. As linhas 4 e 5 são privadas e ficam de fora.

## CPTM — Operação

- https://www.cptm.sp.gov.br/cptm/transparencia/operacao
- "Embarcados Acumulados", 2019–2026 (conferido):
  - **mês × estação × linha** (7 em 2024, 10, 11, 12, 13);
  - por tipo de tarifa (Pagantes, Gratuidade SBE, Não tarifados, transferências com Metrô/ViaQuatro/ViaMobilidade) e total de entradas;
  - zip anual com zips mensais dentro;
  - **até 2024 em xlsx; a partir de 2025 só PDF**.
- Também publicados: "Transportados – MDU" (PDF, 2024–2026) e "Pagantes por Tipo de Bilhete" (zip, 2019–2026).
- Atenção à continuidade das séries: linhas 8 e 9 são da ViaMobilidade; a linha 7 foi concedida; as linhas 11–13 passaram para a Trivia Trens em jul/2026 e voltaram à CPTM dias depois.

## Pesquisa Origem-Destino 2023 (Metrô)

- https://transparencia.metrosp.com.br/dataset/pesquisa-origem-e-destino-2023-anexos
- Zip: `https://transparencia.metrosp.com.br/sites/default/files/Site_190225_PesquisaOD2023.zip` (198 MB, direto, sem login).
- Conteúdo (conferido):
  - microdados `Banco2023_divulgacao_190225.dbf` / `.sav` (143.038 registros, 147 campos);
  - dicionário `Layout_BD_OD2023`;
  - tabelas prontas `Tabelas_Site_OD2023` (xlsx);
  - shapefiles das 527 zonas, distritos e municípios.
- Campos-chave:
  - `H_SAIDA`/`MIN_SAIDA`, `H_CHEG`/`MIN_CHEG`, `DURACAO`, `ANDA_O`/`ANDA_D`;
  - `MODO1`–`MODO4` (cadeia), `MODOPRIN`;
  - `ZONA_O`/`ZONA_D`, `MUNI_O`/`MUNI_D`, coordenadas, `MOTIVO`;
  - `FE_VIA` (peso de expansão da viagem);
  - `DIA_SEM` de 2 a 6 → **só dias úteis**.
- Códigos de modo: 01 Metrô, 02 Trem, 03 Monotrilho, 04 Ônibus município SP, 05 Ônibus outros municípios, 06 Ônibus metropolitano … 17 A pé. Ex.: ônibus→metrô = `MODO1=04` e `MODO2=01`.
- Relatório síntese, com a distribuição das viagens por hora: https://transparencia.metrosp.com.br/dataset/pesquisa-origem-e-destino-2023-relat%C3%B3rio-s%C3%ADntese
- OD 2017 (mesma estrutura, 42 MB): `https://transparencia.metrosp.com.br/sites/default/files/OD-2017.zip`.

## Enriquecimento (sem autenticação, funcionam no Power Query)

- Open-Meteo, clima horário histórico:
  - `https://archive-api.open-meteo.com/v1/archive?latitude=-23.55&longitude=-46.63&start_date=2024-01-01&end_date=2024-12-31&hourly=temperature_2m,precipitation,rain&timezone=America%2FSao_Paulo`
  - uso não comercial gratuito.
- BrasilAPI, feriados:
  - `https://brasilapi.com.br/api/feriados/v1/2024`
  - só feriados **nacionais**; acrescentar 25/01 (município de SP) e 09/07 (estado de SP).
