# Progresso

Diário das sessões, mais recente no fim. Formato: data · issue · feito · pendente · próximo.

## 2026-10-16 · TRA (setup) · sessão de planejamento

- **Feito**:
  - leitura da proposta do Grupo 10 e do modelo do professor;
  - levantamento das fontes de dados (`fontes-de-dados.md`);
  - sabatina de decisões com o Luciano (`decisoes/0001`–`0007`);
  - estrutura do repositório, `AGENTS.md`, `memories/` e plano em `docs/plano/`;
  - repositório público https://github.com/Luciano-O/projeto_cheiU_FATEC (`origin`), publicado com o ok do Luciano;
  - projeto "cheiU — Mobilidade Urbana (ILP590)" no Linear (time TRA): 10 marcos, labels de ferramenta e de responsável, issues TRA-5 a TRA-69 (uma por passo). TRA-1 a TRA-4 são issues de boas-vindas do Linear, fora do projeto.
- **Pendente**:
  - datas das aulas (os marcos do Linear estão sem data-alvo);
  - integração GitHub ↔ Linear (E0.3);
  - acesso ao repositório do grupo (E0.4);
  - cadastro no DevPlace SPTrans (E0.5).
- **Próximo**: E0.6 (Python) e E0.7 (automação do Excel via COM), depois E1.0.

## 2026-10-26 · TRA-70 (E0.8) · alinhamento aos guias do professor

- **Feito**:
  - leitura do Projeto Modelo CaféData v2.0, dos Guias Práticos das Etapas 1–3 e das planilhas simuladas;
  - PDFs em `docs/professor/` e resumo operacional em `docs/plano/referencia-professor.md`;
  - plano renumerado para as 7 etapas do professor (decisão `0008`, com a tabela de IDs antigos → novos);
  - passos novos:
    - E0.9, commits por integrante;
    - E1.6, amostra auditável;
    - E1.7, QA da Etapa 1;
    - E2.0, refinar a Etapa 2;
    - E2.1, parâmetros e `cad_Etapa1`;
  - passos ampliados:
    - E1.4 ganhou o catálogo de defeitos e a ficha do projeto;
    - E2.9 ganhou `Rejeitados` e `Conf_*`;
    - E3.6 ganhou as abas `Validacao` e `Conferencia`;
    - a aula 16 virou Parcial 2;
  - `AGENTS.md`: linhagem, conferência, convenções de nomes e pastas, commits dos integrantes;
  - Linear: marcos e issues renomeados e movidos.
- **Pendente**:
  - datas das aulas (os marcos continuam sem data-alvo);
  - guias das Etapas 4–7 (o `Ex.0` de cada etapa compara com eles);
  - E0.9: o acesso de Victor, Nicolly e Maryele ao `origin`.
- **Próximo**: E0.3, E0.6 e E0.7; depois E1.0.

## 2026-11-06 a 2026-11-08 · TRA-10 a TRA-36 · Etapas 1–3 da N1

- **Feito**:
  - decisão `0009`: MVP de demanda só com SPTrans, saída da Nicolly, uma branch e um PR por etapa;
  - download dos 366 diários e 12 consolidados da SPTrans 2024, com catálogo de defeitos D1–D18;
  - `cheiU_01_Excel.xlsx` (amostra de jan/2024): painel 579 × 579, 0 erros de fórmula, 0 células originais alteradas;
  - `cheiU_02_PowerQuery.xlsx`: 486.864 lidas = 480.192 aceitas + 6.672 rejeitadas; 461.839 linhas na fato; teste de reenvio ok;
  - `cheiU_03_PowerPivot.xlsx`: 5 relações, 27 medidas, `Conferencia` com todas as diferenças em 0, teste de linhagem ok;
  - PRs empilhados #3 (Etapa 1), #4 (Etapa 2), #5 (Etapa 3) e relatório parcial em PDF;
  - merge dos PRs, tag `parcial-1` e push para o repositório do grupo (`6c1b63e`);
  - QAs das 3 etapas, relatório em Markdown, apresentação e roteiro, commitados pelo Luciano (decisão `0010`);
  - tudo montado por script via COM (`memories/automacao-excel.md`).
- **Pendente**:
  - Victor e Maryele como colaboradores e com commits próprios (E0.9), para a N2 (decisão `0010`);
  - revisão do Victor no relatório e na apresentação, e o ensaio cronometrado (a Maryele revisou os painéis de conferência dos QAs em 08/11/2026);
  - interface do Excel: grupos de consultas, Tabela de Datas, hierarquia, diagrama e prints de `evidencias/`;
  - Metrô (portal em 503 até 08/11) e CPTM (download pelo navegador);
  - diferença contra o total publicado de janeiro a julho (até −5,15%): causa não confirmada.
- **Próximo**: OD 2023, oferta e lotação; depois as Etapas 4–7.

## 2026-11-09 a 2026-11-21 · TRA-38 · reverificação da N1 e status

- **Feito**:
  - reverificação em 09/11, sem alterar arquivos versionados:
    - `verificar_etapa2.ps1`: 26 × 26 `.pq`, 0 diferenças; reconciliação e teste de reenvio iguais aos de 08/11;
    - `verificar_etapa3.ps1`: 10 `.pq` e 27 medidas sem diferença; linhagem +1.000 com ida e volta;
    - conferência própria dos CSVs de `dados_limpos/` (461.839 linhas, 2.124.704.175 passageiros, 0 duplicatas no grão) e dos painéis das Etapas 1 e 3, todos com diferença 0;
  - Linear: TRA-18 (E2.2), TRA-24 (E2.11) e TRA-30 (E3.2) passaram de Backlog para In Progress. O trabalho já está na `main`, mas falta parte do aceite. O que falta ficou comentado em cada issue, e também em TRA-72 e TRA-11, que continuam In Progress;
  - `README.md`: status das Etapas 1–3 e da Parcial 1.
- **Pendente**:
  - prints de `evidencias/` e itens de interface (grupos de consultas, Tabela de Datas, hierarquia, diagrama), que fecham TRA-72, TRA-24 e TRA-30;
  - diferença do 1º semestre contra o publicado: confirmar com a SPTrans ou registrar uma decisão (TRA-18);
  - teste de `.bas` via COM (TRA-11);
  - `relatorio-parcial.pdf` (22:34 de 08/11) é anterior ao `relatorio-parcial.md` (23:07): conferir se o conteúdo diverge.
- **Próximo**: OD 2023, oferta e lotação; depois as Etapas 4–7.

## 2026-11-21 a 2026-11-23 · TRA-7 (relacionada) · espelho das issues no repositório do grupo

- **Feito**:
  - 71 issues criadas em `Ve3e3/projeto_cheiU_FATEC`, de TRA-5 a TRA-75, com TRA-n = #(n−4); 11 milestones e 18 labels (decisão `0011`);
  - as 22 em Done no Linear foram fechadas como concluídas, e as 5 em In Progress levam a label `Em andamento`;
  - script `docs/scripts/espelhar_linear.py` versionado; uma segunda execução com `--executar` não alterou nada;
  - `AGENTS.md`: regra para manter o espelho em dia (passo 5 do Fluxo) e o espelho incluído na autonomia do agente.
- **Pendente**:
  - o espelho só se atualiza quando alguém roda o script ou fecha a cópia à mão. A integração nativa (E0.3) continua em Todo e precisa de uma pessoa para autorizar;
  - quem não tem conta no workspace do Linear não abre os links do Linear que estão nas issues.
- **Próximo**: OD 2023, oferta e lotação; depois as Etapas 4–7.

## 2026-11-27 · TRA-14 (E1.2) · CPTM 2024 baixada; Metrô segue fora do ar

- **Feito**:
  - `baixar_cptm.py`: lê a página de operação da CPTM, baixa o zip anual dos Embarcados Acumulados de 2024 e o PDF de Transportados (MDU), e extrai os 12 xlsx mensais para `dados-brutos/cptm/2024/embarcados/`; manifesto com 14 linhas `cptm_*`; uma segunda execução não baixa nada;
  - conferência dos 12 meses: linhas 7, 10, 11, 12 e 13 em todos, 64 estações-linha por mês, soma das quatro tarifas = `Total Entradas` nos 768 registros; total de 2024 = 438.924.668 entradas;
  - defeitos D19 (setembro com título de outubro), D20 (rótulos variáveis), D21 (layout de relatório) e D22 (`Total` × `Total Entradas` em Palmeiras-Barra Funda) no catálogo; D15 atualizado;
  - `fontes-de-dados.md`, dicionário de dados, README da Etapa 1 e plano da E1.2 atualizados.
- **Pendente**:
  - Metrô: `transparencia.metrosp.com.br` continua em 503 (também no navegador), então `baixar_metro.py` e a E1.3 (OD 2023, mesmo portal) seguem bloqueados; TRA-14 fica In Progress;
  - reconciliar os embarcados com o PDF de Transportados (MDU) na E2.4.
- **Próximo**: E2.4 (CPTM no Power Query, com `Param_Pesos_Tipo_Dia`) ou voltar ao Metrô quando o portal responder.

## 2026-11-27 · TRA-20 (E2.4) · CPTM no Power Query com estimativa diária

- **Feito**:
  - Etapa 1: `Cad_Linha_Trilho` (5 linhas da CPTM, grupo "CPTM") e `Cad_Estacao` (66 grafias → estação padronizada, D23); "CPTM" em `Lista_Grupo`; o painel de auditoria continua com 579 × 579;
  - Etapa 2: 9 consultas novas (`pPastaCPTM`, `cad_Linha_Trilho`, `cad_Estacao`, `cad_Pesos_Tipo_Dia`, `stg_cptm_linhas`, `stg_cptm_mensal_estacao`, `stg_cptm_mensal_linha`, `stg_cptm_diario_estimado`, `Conf_CPTM`); `Fato_Transporte`, `Dim_Transporte`, `Dim_Grupo`, `Rejeitados`, `Conf_Reconciliacao`, `Conf_Etapas` e `Conf_Publicado` com a CPTM;
  - conferência: CPTM 768 − 768 − 0 = 0 e 438.924.668 = 438.924.668; `Conf_CPTM` com diferença 0 nas 72 linhas mês × linha; SPTrans sem mudança; reenvio das duas fontes ok (mês repetido da CPTM → "Arquivo duplicado"); `.pq` 35 × 35;
  - Etapa 3: medida `Passageiros de Ônibus` (28 medidas) na dinâmica realizado × publicado; `Conferencia` com diferença 0 (463.669 linhas, 2.563.628.843 passageiros); linhagem ok;
  - decisão `0012` (pesos provisórios, `Total Entradas`, arredondamento acumulado); comparação com o MDU publicado no README da Etapa 2 (razão 0,913, métricas diferentes);
  - decisão `0013`: o agente mergeia e empurra a `main` para o `grupo` depois do Aceite; PR #11 publicado (`998fa96`).
- **Pendente**:
  - trocar os pesos de `Param_Pesos_Tipo_Dia` pelas razões do Metrô quando a E2.3 sair;
  - os QAs das Etapas 2 e 3 (Maryele) foram feitos antes da CPTM: vale uma revisão dos painéis novos.
- **Próximo**: Metrô (E1.2/E2.3) e OD 2023 quando o portal voltar.

## 2026-11-27 · TRA-18 (E2.2) · diferença contra o publicado investigada

- **Feito**:
  - os 12 consolidados mensais da SPTrans fecham com a soma dos diários; o total da página publicada é refeito por reprocessamento da bilhetagem (aviso da própria página);
  - D24: o diário de 08/07/2024 veio sem 207 linhas (904.616 passageiros), que a 2ª versão do consolidado de julho traz; `stg_sptrans_consolidado_jul`, `Conf_Complemento_Jul` e `stg_sptrans_complemento` criam esse dia com `origem_dado = estimado`; julho passou de −0,77% para −0,25%;
  - D25: 66 linhas mudam de grupo no ano (o modelo usa o grupo mais recente);
  - decisão `0014`: complemento de julho, aceitação de jan–jun (2–5%) como limitação da fonte, sem fator de ajuste;
  - Etapa 2: 39 × 39 `.pq`, reconciliação com 3 fontes e diferença 0, reenvio ok; Etapa 3: `Conferencia` 0 (463.876 linhas, 2.564.533.459 passageiros), linhagem ok.
- **Pendente**: confirmar com a SPTrans, se alguém do grupo quiser, o reprocessamento do 1º semestre.
- **Próximo**: prints e itens de interface (TRA-72, TRA-24, TRA-30).

## 2026-11-27 · TRA-72 (E1.6) · prints da Etapa 1

- **Feito**: prints do painel de conferência, do Rastrear Precedentes em `Grupo_Trat` e do Gerenciador de Nomes em `01-excel/evidencias/`, feitos pela interface do Excel (controle do computador); a pasta foi fechada sem salvar, e o `.xlsx` versionado não mudou.
- **Pendente**: nada na TRA-72.
- **Próximo**: grupos de consultas e prints da Etapa 2 (TRA-24); Tabela de Datas, hierarquia e diagrama da Etapa 3 (TRA-30).

## 2026-11-27 · TRA-30 (E3.2) · ajustes do modelo pela interface do Power Pivot

- **Feito**: `Dim_Calendario` marcada como Tabela de Datas; `nome_mes` por `mes` e `nome_dia` por `dia_semana`; hierarquia `Ano › Mês › Dia`; 5 chaves técnicas ocultas; `docs/diagrama_modelo.png`. `verificar_etapa3.ps1` depois de salvar: `.pq` 10 × 10, `.dax` 28 × 28, 5 relações ativas, linhagem ok.
- **Pendente**: relações e hierarquia Faixa › Hora das fatos horárias (dependem de E2.6–E2.8); os ajustes da interface se perdem se `montar_etapa3.ps1` remontar a pasta (passos no README da Etapa 3).
- **Próximo**: grupos de consultas e prints da Etapa 2 (TRA-24).
