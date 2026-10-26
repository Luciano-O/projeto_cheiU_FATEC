# Referência do professor — o que cada etapa exige

Resumo operacional do material do Prof. Veríssimo em `docs/professor/`. O conteúdo é do CaféData, a rede de cafeterias fictícia que ele usa nas demonstrações:

- `projeto-modelo-cafedata-v2.pdf`: especificação do projeto modelo, v2.0, out/2026;
- `guia-etapa-1-excel.pdf`, `guia-etapa-2-powerquery.pdf`, `guia-etapa-3-powerpivot.pdf`: roteiros clique a clique.

Os guias das Etapas 4–7 ainda não saíram. Quando saírem, o passo `Ex.0` da etapa compara o plano com o guia e atualiza este arquivo.

> **O que reaproveitar**: o método (diagnosticar defeitos, tratar, modelar em estrela, medir, automatizar, persistir, enriquecer, visualizar), a forma das entregas e as regras de conferência.
> **O que não copiar**: nomes de produtos, filiais, faixas e medidas do CaféData. Os nomes de arquivo trocam `CafeData_` pelo nosso prefixo (`cheiU_0N_<Ferramenta>.xlsx`).

## Cronograma do curso

| Aula | Etapa do professor | Nosso plano | Artefato |
|---|---|---|---|
| 1 | Apresentação, ficha do projeto | Etapa 0 | — |
| 2–3 | Etapa 1 — Excel avançado | `etapa-1-excel.md` | `cheiU_01_Excel.xlsx` |
| 4–5 | Etapa 2 — Power Query | `etapa-2-powerquery.md` | `cheiU_02_PowerQuery.xlsx` |
| 6–7 | Etapa 3 — Power Pivot e DAX | `etapa-3-powerpivot-dax.md` | `cheiU_03_PowerPivot.xlsx` |
| 8 | **Parcial 1** | `entregas-academicas.md` | checkpoint |
| 10–11 | Etapa 4 — VBA | `etapa-4-vba.md` | `.xlsm` + `.bas` |
| 12–13 | Etapa 5 — Banco de dados e SQL | `etapa-5-sql.md` | scripts `.sql` |
| 14–15 | Etapa 6 — APIs e dados da web | `etapa-6-api-web.md` | clima/feriados no modelo |
| 16 | **Parcial 2** | `entregas-academicas.md` | checkpoint |
| 18 | Etapa 7 — Power BI | `etapa-7-powerbi.md` | `.pbix` + PDF |
| 20 | Apresentações finais | `entregas-academicas.md` | — |

Aulas 9, 17 e 19 seguem o calendário letivo (avaliações, reposição ou apoio às equipes).

## Regras que valem para todas as etapas

- **Linhagem**: a saída de uma etapa é a entrada obrigatória da próxima. Cada arquivo lê o anterior por parâmetro do Power Query (`pArquivoEtapa1`, `pArquivoEtapa2`). Um número errado se corrige na etapa de origem e se propaga com "Atualizar Tudo"; nunca se corrige à mão na etapa seguinte.
- **Escopo por etapa**: cada guia tem uma tabela do que *não* fazer ainda. Exemplos: Power Query na Etapa 1, relacionamentos e DAX na Etapa 2, gráficos de painel na Etapa 3. A tabela de conferência cobra isso no item "Escopo respeitado".
- **Tabela de conferência** no fim de cada etapa: item, resultado esperado, como verificar, status.
  - Status possíveis: Não iniciado, Em andamento, Concluído, Pendente de esclarecimento.
  - A etapa só está concluída sem itens Não iniciado ou Em andamento.
  - Pendências são aceitas se estiverem registradas com a ação necessária.
- **Commits**: "cada integrante deve ter commits próprios: o histórico é avaliado" (Guias 2 e 3).
- **Amostra antes da base inteira**: o professor desenvolve cada etapa sobre um arquivo pequeno (15 linhas simuladas) e depois troca pela base oficial. O que vale na base inteira são as conferências (diferenças 0), não os números da amostra.
- **Catálogo de defeitos**: a tabela D1..D10 do modelo (defeito, exemplo, etapa que resolve) é o fio condutor. Cada etapa diz, por defeito, se trata, sinaliza, só registra ou deixa para depois.

## Etapa 1 — Excel avançado

- **Regra de ouro**: nenhum valor original é apagado ou sobrescrito. O tratamento vai em colunas novas (`_Trat`, `Status_*`), e o que fórmula não resolve vai para a auditoria com a linha de origem.
- **Arquivo** com exatamente quatro abas:
  - `Bruto`: cópia fiel da planilha original, feita por Mover ou Copiar;
  - `Tratado`: tabela estruturada com `Linha_Origem` fixa (nunca `=LIN()`), colunas originais e colunas calculadas;
  - `Cadastros`: tabelas de cadastro, de-para de grafias e listas de valores válidos, com nomes `Lista_*`;
  - `Auditoria`: tabela `Tab_Auditoria` (Linha_Origem, chave, Campo, Valor_Encontrado, Tipo_Problema, Acao_Necessaria, Situacao, Observacao) e painel Tipo × Detectado × Registrado × Diferença.
- **Técnicas cobradas**:
  - PROCX com retorno "Não cadastrado"/"Sem correspondência";
  - ARRUMAR e PRI.MAIUSCULA, ou busca na lista oficial quando PRI.MAIUSCULA estragaria a grafia;
  - datas em texto convertidas com LET e "Data inválida" para datas inexistentes;
  - colunas de mês, dia da semana e turno;
  - validação de dados em lista;
  - formatação condicional para vazio/zero e desvio acima do limite;
  - coluna-resumo `Problemas` com UNIRTEXTO;
  - auditoria de fórmulas: rastrear precedentes e dependentes, avaliar fórmula, verificação de erros, `SOMARPRODUTO(--ÉERROS(tabela))` = 0.
- **Conferência**: Bruto igual ao original; buscas sem `#N/D`; painel com Diferença 0 e erros de fórmula 0; nenhum original alterado; duas linhas sorteadas do registro localizadas no Bruto; escopo respeitado.
- **De-para**: só entram grafias confirmadas. Uma grafia nova vai para a auditoria como "Pendente de esclarecimento" até alguém confirmar, com a decisão anotada.

## Etapa 2 — Power Query

- **Regra de ouro**: nenhuma linha some sem explicação. Toda linha lida termina em `fVendas` ou em `Rejeitados`, com motivo, e `Conf_Reconciliacao` prova que lidas − aceitas − rejeitadas = 0. O Power Query só lê os brutos.
- **Configuração**: localidade pt-BR, privacidade "ignorar níveis", parâmetros de caminho no grupo `01_Parametros`, consultas agrupadas (`03_Cadastros`, `05_Saida`…).
- **Fluxo**:
  1. `Folder.Files` da pasta inteira; a pasta não pode ter intrusos;
  2. `stg_*_Bruto`;
  3. de-para de colunas e função de padronização para nomes diferentes entre arquivos (D10), com `Conf_Colunas` vazia;
  4. nulos e duplicatas;
  5. tipos com `"pt-BR"`;
  6. `Text.Trim`/`Text.Proper`;
  7. mesclagem com o de-para e o cadastro lidos do arquivo da Etapa 1 (`cad_Etapa1`);
  8. colunas personalizadas;
  9. `Rejeitados` por anti-junção, com `Conf_Motivos`;
  10. fonte em formato largo despivotada (metas → `fMetas` com `Mes_Inicio`);
  11. contagem de linhas etapa por etapa.
- **Entrega** em `MA2026-entrega-parcial/02-powerquery/`:
  - o `.xlsx`;
  - `scripts_m/<Consulta>.pq` (UTF-8, primeira linha `// <Consulta>`);
  - `dados_limpos/*.csv` (CSV UTF-8, "exigido pelo Guia de Orientação");
  - `evidencias/` com prints do painel de consultas, das etapas aplicadas e da conferência;
  - `README.md` com consultas, parâmetros, regras de rejeição e pendências.
- **Conferência**: reconciliação com diferença 0; teste de reenvio (um arquivo novo na pasta e "Atualizar Tudo" muda as contagens, e elas voltam ao retirar o arquivo); sem relacionamentos, DAX, macro nem colunas que dependem de modelo.

## Etapa 3 — Power Pivot e DAX

- **Regra de ouro**: o modelo não cria nem perde valor. O total da medida principal é igual à soma da Etapa 2, e as linhas da fato no modelo são iguais às da Etapa 2. A aba `Conferencia` mostra todas as diferenças 0.
- **Entrada**: só o arquivo da Etapa 2 (`pArquivoEtapa2`, `cad_Etapa2`); nenhuma tabela digitada ou colada.
- **Modelo**:
  - estrela com relações 1:N ativas, em direção única;
  - `dCalendario` contínua no recorte do projeto, gerada no Power Query e marcada como tabela de datas, com feriados provisórios até a etapa de APIs;
  - segunda fato de "esperado" ligada pelo primeiro dia do mês (`Mes_Inicio`);
  - `Rejeitados` fora da estrela, só para contagens;
  - lugar reservado para a dimensão da API (clima).
- **Medidas**:
  - as da especificação, com formato e descrição;
  - medidas `Conf …`: linhas, órfãs por FK, PK duplicada, diferença de valor;
  - **mínimo de cinco medidas** para a Parcial 1.
- **Validação**: aba `Validacao` só com tabelas dinâmicas (ex. filial × mês), sem gráficos de painel.
- **Entrega** em `MA2026-entrega-parcial/03-powerpivot/`:
  - o `.xlsx`;
  - `dax/medidas_preliminares.dax`: separador vírgula, UTF-8, comentário `//` com a pergunta e o formato acima de cada medida;
  - `docs/modelo_relacional.md`: tabelas, grão, PK, linhas, relacionamentos R1..Rn;
  - `docs/diagrama_modelo.png`;
  - `scripts_m/`;
  - `evidencias/` (diagrama, gerenciar relações, gerenciar medidas, validação, conferência);
  - `README.md`.
  - Feche o Excel antes do commit (o `~$*.xlsx` não sobe).
- **Excel pt-BR**: o Power Pivot pede `;` entre argumentos; no `.dax` do repositório fica a versão com vírgula.

## Etapas 4–7 (pela especificação; guias pendentes)

- **VBA**: macro que pede uma data (InputBox), valida se há dados, cria ou recria a aba `Resumo_dd-mm-aaaa`, escreve os KPIs do dia, lista o top 3, pinta de vermelho o que está abaixo do alvo e, opcionalmente, exporta PDF em `relatorios/`. Fica associada a um botão numa aba de painel.
- **SQL**: DDL, carga e consultas de análise em scripts separados. O modelo usa SQL padrão (MySQL/SQLite) e cinco consultas: ranking, realizado × esperado com JOIN, ticket por canal, cruzamento com o clima com CASE, e HAVING.
- **APIs**: função Power Query (`fnClima(lat, lon, cidade)`) invocada por linha da dimensão, combinada numa dimensão de clima com faixa e chave composta (`Cidade|Data`) ligada à fato. Feriados da BrasilAPI marcam `dCalendario`.
- **Power BI**:
  - três páginas temáticas;
  - títulos em forma de pergunta;
  - no máximo seis visuais por página;
  - tema único;
  - filtros sincronizados;
  - tooltip com KPIs;
  - exportação em PDF.

## Checkpoints

- **Parcial 1 (aula 8)**: base bruta documentada, base tratada (Excel + Power Query), modelo estrela com pelo menos cinco medidas DAX e ficha do projeto preenchida.
- **Parcial 2 (aula 16)**: macro VBA funcionando, banco com DDL e pelo menos quatro consultas de análise, e uma fonte externa (API) integrada ao modelo.

## Ficha do projeto

Mesmos campos da ficha dos cinco temas: Contexto, Pergunta central, Fontes de dados, Dados utilizados, Indicadores/KPIs, Dados externos/API, Automação (VBA), Banco de dados/SQL e Resultado no Power BI.

Para Mobilidade Urbana, a correspondência sugerida pelo professor é:
- fato: viagem / passagem por ponto;
- dimensões: linha, estação, região, horário;
- KPI análogo: atraso médio em dias com e sem chuva;
- API: clima ou geolocalização.
