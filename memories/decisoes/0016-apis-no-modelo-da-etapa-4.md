# APIs no modelo da Etapa 4, clima por arquivo

Em 2026-11-28 a Etapa 6 foi integrada. Três escolhas:

- **Onde**: as consultas de API entram no `cheiU_04_VBA.xlsm`, o modelo vigente, e não na pasta da Etapa 3. Remontar a Etapa 3 pelo script perde os ajustes de interface do Power Pivot, e é a Etapa 4 que exporta para o SQL. As consultas ficam versionadas em `03-api-web/scripts_m/`, e `integrar_apis.ps1` as aplica. A `Dim_Calendario` dessa pasta passa a usar `Ref_Feriados` (BrasilAPI + locais) no lugar da lista manual.
- **Clima por arquivo**: o `Web.Contents` do Excel falha com `archive-api.open-meteo.com` nesta máquina, sem mensagem aproveitável, embora `curl`, Python e a BrasilAPI no próprio Power Query funcionem. A aquisição vai para `01-excel/scripts/baixar_clima.py` (decisão `0004`), e o Power Query lê o JSON salvo. A BrasilAPI continua ao vivo, o que cumpre o "API integrada ao modelo" da Parcial 2.
- **Rótulos**: o clima tem `origem_dado = estimado`, porque o arquivo do Open-Meteo é reanálise (ERA5), não medição de estação. Dia com chuva = 5 mm ou mais no dia; dia seco = menos de 1 mm (premissa do efeito da chuva).

Alternativas descartadas:

- **Integrar na Etapa 3 e remontar tudo**: perderia a Tabela de Datas, a hierarquia e as chaves ocultas.
- **Deixar o clima de fora**: o efeito da chuva é uma das perguntas do plano (E3.3 e E5.4).

Risco assumido: quem rodar a Etapa 6 em outra máquina precisa baixar o clima antes (`baixar_clima.py`). A chamada direta ao Open-Meteo está no comentário do `.pq`, para quem quiser trocar.
