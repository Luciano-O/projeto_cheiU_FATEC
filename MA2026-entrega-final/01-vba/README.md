# 01-vba — Etapa 4 (VBA)

`cheiU_04_VBA.xlsm` é a pasta da Etapa 3 salva como `.xlsm`, com os ajustes de interface do Power Pivot preservados, a integração das APIs da Etapa 6 e oito módulos VBA. A aba `Controle` tem quatro botões que fazem, sem passo manual, o que antes era feito à mão: atualizar, validar, gerar o resumo diário e exportar para o SQL.

Plano: `docs/plano/etapa-4-vba.md`. QA: `MA2026-entrega-parcial/04-documentacao/qa/etapa-4.md`.

## Como usar

1. Abra `cheiU_04_VBA.xlsm` e clique em **Habilitar Conteúdo** (macros e conexões).
2. Na aba `Controle`, use os botões nesta ordem:

| Botão | Macro | O que faz | Onde ver o resultado |
|---|---|---|---|
| Atualizar | `modAtualizacao.AtualizarTudo` | atualiza cada consulta em primeiro plano, cronometrada, depois o Modelo de Dados e as dinâmicas | aba `Log`: uma linha OK por consulta |
| Validar | `modQA.ValidarDados` | refaz por DAX as checagens dos QAs das Etapas 2, 3 e 6 | aba `QA`: esperado, obtido, OK/FALHA |
| Resumo diário | `modRelatorio.GerarResumoDiario` | pede uma data (dd/mm/aaaa), cria a aba `Resumo_dd-mm-aaaa` e o PDF | aba nova e `relatorios/resumo_aaaa-mm-dd.pdf` |
| Exportar para SQL | `modExportacao.ExportarParaCarga` | grava as 8 tabelas do modelo em CSV para a carga da Etapa 5 | `02-bancodedados-sql/carga/` (fora do Git) e aba `Log` |

`CaminhoRepo` (aba `Parametros`) se deriva do caminho do arquivo: funciona em qualquer clone.

## Módulos (`modulos/*.bas`)

Os `.bas` são a fonte da verdade, em Windows-1252 com CRLF (formato do importador do VBE). `scripts/converter_bas.py` converte módulos editados em UTF-8 para esse formato.

| Módulo | Conteúdo |
|---|---|
| `modConfig` | `Config("CaminhoRepo")` e chaves do `.env`; `PastaEtapa4`, `PastaCarga` |
| `modLog` | `RegistrarLog`, `RegistrarFalha`, `Decorrido`, `LimparLog` (aba `Log`) |
| `modUtil` | consultas DAX ao modelo por ADO (`ConsultaDax`, `ValorDax`, `ValorMedida`), modo silencioso, `TestarLog` e o padrão de erro `On Error GoTo Falha` |
| `modAtualizacao` | `AtualizarTudo` |
| `modQA` | `ValidarDados` (24 checagens) |
| `modRelatorio` | `GerarResumoDiario` |
| `modExportacao` | `ExportarParaCarga` (UTF-8, `,`, `.`, datas ISO, lógicos 1/0, LF) |
| `modControle` | ações dos quatro botões |

## Como remontar e verificar

O Excel aberto por automação nesta máquina recusa o acesso ao projeto VBA, mesmo com "Confiar no acesso ao modelo de objeto do projeto do VBA" ligado. Por isso a importação dos módulos é manual:

1. `scripts/montar_etapa4.ps1`: copia a pasta da Etapa 3, salva como `.xlsm`, cria as abas `Controle`, `Log` e `QA` e os botões.
2. No Excel: Alt+F11 › Arquivo › Importar arquivo, os 8 `.bas` de `modulos/`; Ctrl+S.
3. `03-api-web/scripts/integrar_apis.ps1`: integra clima, horário e feriados (Etapa 6).
4. `scripts/executar_etapa4.ps1`: roda a sequência completa em modo silencioso e salva. A saída da última execução está em `evidencias/execucao_etapa4.txt`.

O script usa o Excel visível: oculto, ele cai em `GerarResumoDiario` depois de `AtualizarTudo`.

## Resultado (28/11/2026)

| Verificação | Resultado |
|---|---|
| `TestarLog` | uma linha OK e uma linha FALHA no `Log` |
| `AtualizarTudo` | 10 consultas, modelo e dinâmicas em 44 s, sem falha |
| `ValidarDados` | 24 checagens, 0 falhas |
| `GerarResumoDiario` 15/03/2024 | aba e PDF; total 8.499.597 = `[Total de Passageiros]` do dia |
| `GerarResumoDiario` 31/02/2024 e 01/01/2025 | aviso "Data inválida" e "não está em Dim_Calendario", sem aba |
| `ExportarParaCarga` | 8 CSVs com o mesmo número de linhas do modelo (`Fato_Transporte` 463.876) em 8 s |

O % da demanda no pico e a faixa de lotação do resumo dependem do perfil horário da OD (E3.4) e entram quando ele existir.
