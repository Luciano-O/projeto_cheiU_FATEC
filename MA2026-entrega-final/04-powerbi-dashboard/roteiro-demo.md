# Roteiro da demonstração ao vivo — entrega final

Slides: `apresentacao-final.pptx`. A demonstração entra no slide 9 e dura cerca de 7 minutos. Responsável: Victor Lima Conceição; a divisão das partes é uma proposta para o grupo ajustar.

**Ensaio cronometrado: não realizado.** Os tempos abaixo são estimativas. O aceite do F.1 pede que o roteiro rode do zero numa máquina que não seja a do Luciano, ou que o plano B cubra a diferença.

## Antes da aula (30 min antes)

1. Docker Desktop aberto; na pasta `MA2026-entrega-final/02-bancodedados-sql`:

   ```powershell
   docker compose --env-file ../../.env up -d
   ```

2. Abrir `MA2026-entrega-final/01-vba/cheiU_04_VBA.xlsm` (habilitar macros) na aba `Controle`.
3. Abrir `MA2026-entrega-final/04-powerbi-dashboard/cheiU_dashboard.pbix` na página "Visão geral".
4. Deixar aberto um terminal na pasta `02-bancodedados-sql` e o navegador com `https://brasilapi.com.br/api/feriados/v1/2024`.
5. Conferir a internet (BrasilAPI) e ter o plano B no pendrive.

## Sequência

| # | Parte | Quem | Tempo | O que mostrar |
|---|---|---|---|---|
| 1 | SQL Server no Docker | Victor | 0:45 | `docker ps` com `cheiu-sql` *healthy* |
| 2 | Atualizar o Excel pela macro | Maryele | 1:15 | botão **Atualizar**; aba `Log` com uma linha OK por consulta (cerca de 45 s) |
| 3 | Macro de QA | Maryele | 0:45 | botão **Validar**; aba `QA` com 24/24 OK |
| 4 | Resumo diário em PDF | Maryele | 0:45 | botão **Resumo diário**, data `15/03/2024`; abrir o PDF em `01-vba/relatorios/` |
| 5 | Consulta SQL | Luciano | 1:00 | rodar os KPIs e mostrar que batem com o painel (comando abaixo) |
| 6 | API ao vivo | Victor | 0:45 | no navegador, a resposta da BrasilAPI; no Excel, a consulta `api_brasilapi_feriados` já carregada |
| 7 | Power BI | Luciano | 1:30 | navegar pelas 5 páginas pelos botões; filtrar "Trem" na segmentação de modalidade e mostrar que as outras páginas seguem o filtro; passar o mouse num gráfico para ver a dica com os KPIs |

Comando da parte 5 (o terminal precisa ter a senha do `.env` na variável `MSSQL_SA_PASSWORD`):

```powershell
docker exec cheiu-sql bash -c '/opt/mssql-tools18/bin/sqlcmd -C -f 65001 -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -d cheiU -i /scripts/05_kpis.sql'
```

Números que devem aparecer, iguais no Excel, no SQL e no Power BI:

- total de passageiros 2.564.533.459;
- média de dia útil 8.328.609;
- dia útil com chuva 8.069.711 contra 8.496.127 no seco (−5,0%).

## Plano B

| Falha | O que fazer |
|---|---|
| Docker não sobe | mostrar `02-bancodedados-sql/evidencias/resultado_03_consultas.txt` e `04-powerbi-dashboard/evidencias/conferencia_kpis.txt` |
| Excel ou macro falha | mostrar `01-vba/evidencias/execucao_etapa4.txt` e o PDF já gerado em `01-vba/relatorios/` |
| Sem internet | mostrar `03-api-web/exemplos/` (respostas salvas das APIs) |
| Power BI não abre | mostrar `04-powerbi-dashboard/cheiU_dashboard.pdf` |

Antes da aula, o grupo deve gravar um vídeo curto da sequência inteira, como último recurso.

## Perguntas prováveis

- **Por que não há lotação nem alternativas de percurso?** Dependem do Metrô e da Pesquisa OD 2023; o portal do Metrô ficou em manutenção durante todo o projeto. O modelo já tem o lugar desses dados.
- **O trem é real?** Os totais mensais por estação são reais (CPTM). A divisão pelos dias é estimada, com pesos por tipo de dia (decisão `0012`), e por isso o painel mostra 17,15% da demanda como estimada.
- **Por que −1,77% contra o publicado?** A SPTrans reprocessou o primeiro semestre: os arquivos diários ficam 2% a 5% abaixo do total publicado de janeiro a junho e menos de 0,8% abaixo no segundo semestre (decisão `0014`).
- **A chuva causa a queda?** O painel mostra uma associação: dia útil com chuva tem 5,0% menos passageiros. Não controlamos mês nem feriado próximo.
