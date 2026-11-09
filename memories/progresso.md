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
