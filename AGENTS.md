# AGENTS.md — cheiU (ILP590 · FATEC SP)

Projeto evolutivo de Microinformática Aplicada (Prof. Veríssimo, 2º/2026), Grupo 10, tema **Mobilidade Urbana**.
Pergunta central: como os dados do transporte público de São Paulo revelam padrões de demanda, lotação e utilização e apoiam a comparação de alternativas de deslocamento?

Pipeline do curso, em 7 etapas numeradas como as do professor: 1 Excel → 2 Power Query → 3 Power Pivot/DAX → 4 VBA → 5 SQL → 6 API/Web → 7 Power BI.

Idioma: pt-BR em documentos, issues, commits e PRs. Identificadores técnicos sem acento.

## Onde está cada coisa

| Quando você precisa de… | Leia |
|---|---|
| o que fazer num passo e como validar | `docs/plano/README.md` + o arquivo da etapa |
| o que o professor exige em cada etapa (escopo, artefatos, conferências, checkpoints) | `docs/plano/referencia-professor.md` (PDFs em `docs/professor/`) |
| o significado de um termo do domínio | `memories/glossario.md` |
| o porquê de uma escolha de arquitetura ou de dados | `memories/decisoes/` |
| URL, formato, granularidade ou pegadinha de uma fonte ou API | `memories/fontes-de-dados.md` |
| automatizar o Excel (consultas, modelo, VBA) por script | `memories/automacao-excel.md` (criado no passo E0.7) |
| o que aconteceu nas sessões anteriores | final de `memories/progresso.md` |
| status das tarefas | Linear, time **TRA**, projeto **cheiU — Mobilidade Urbana (ILP590)** |

## Fluxo de uma sessão

1. **Situar**: leia as últimas entradas de `memories/progresso.md`. Abra a issue no Linear (o título começa com o ID do passo, ex. `[E2.2]`), a seção do passo em `docs/plano/` e a parte da etapa em `docs/plano/referencia-professor.md`.
2. **Ramificar**: a partir da `main` atualizada, crie a branch com o nome que a issue sugere no Linear (campo *git branch name*, formato `oliveiraluck78/tra-<n>-<slug>`). Mova a issue para *In Progress*.
3. **Executar** até o **Aceite** do passo estar verificado: rode o que a linha **Validar** descreve e guarde a evidência (números, prints, saída de comando).
4. **Registrar** antes de commitar:
   - escolha com trade-off real e difícil de reverter → nova decisão em `memories/decisoes/`;
   - termo novo ou redefinido → `memories/glossario.md`;
   - descoberta sobre fonte ou API → `memories/fontes-de-dados.md`;
   - plano que mudou → edite o arquivo da etapa em `docs/plano/` e espelhe na issue;
   - sempre: entrada datada no fim de `memories/progresso.md` (feito, pendente, próximo passo).
5. **Entregar**: commits `TRA-<n>: <resumo>`, push, PR para `main` com `Closes TRA-<n>` na descrição e a evidência do Aceite. Comente o link do PR na issue, que continua em *In Progress* (o time não tem status de revisão). O merge é do Luciano e leva a issue a *Done*: termine a sessão com o PR aberto e o pedido de revisão.
   - **Issue de outro integrante** (label `Resp: Nicolly`, `Resp: Maryele` ou `Resp: Victor`): o professor avalia o histórico de commits por pessoa. O agente prepara o trabalho na branch, sem commitar, e deixa na issue o passo a passo para o responsável revisar, fazer o commit com a própria conta e abrir o PR (`memories/decisoes/0008`).

## Regras

- **Gêmeo em texto**: todo binário (`.xlsx`, `.xlsm`, `.pbix`) tem sua lógica versionada em texto ao lado — Power Query em `.pq`, medidas em `.dax`, macros em `.bas`, banco em `.sql`. O texto é a fonte da verdade; binário e texto mudam no mesmo commit.
- **`origem_dado`** preenchido em todo registro de fato: `real`, `estimado` ou `simulado`. Toda estimativa ou simulação aponta sua premissa (tabela `Param_*` ou decisão em `memories/decisoes/`).
- **Caminhos**: consultas Power Query montam caminhos a partir da célula nomeada `CaminhoRepo` (parâmetros no grupo `01_Parametros`); assim a pasta de trabalho funciona em qualquer máquina do grupo.
- **Linhagem**: um arquivo por etapa, e cada um lê o anterior por parâmetro (`cad_Etapa1`, `cad_Etapa2`). Corrija na etapa de origem e propague com "Atualizar Tudo"; nunca corrija dado à mão numa etapa posterior.
- **Conferência**: nenhuma linha some sem explicação (`Rejeitados` com motivo, `Conf_*` com diferença 0), e cada etapa fecha com a tabela de conferência do guia do professor.
- **Segredos** (senha do SQL Server, token Olho Vivo) ficam só em `.env` na raiz; o modelo é `.env.example`.
- **Dados brutos** com mais de 25 MB por arquivo ficam fora do Git; versione o script de download e a linha do `manifesto.csv`.
- **Estrutura**: as pastas `MA2026-entrega-*` seguem exatamente o modelo do professor. Na raiz ficam só `README.md`, `AGENTS.md`, `CLAUDE.md`, `memories/`, `docs/` e arquivos de configuração.
- **Autonomia**: branch, commit, push, PR, Linear e `memories/` você faz sozinho, exceto o commit das issues de outro integrante (ver Fluxo, passo 5). Merge, instalação de software, tarefas agendadas e downloads de código de terceiros esperam o "ok" do Luciano.
- **Issues com label `Humano`** exigem uma pessoa (criar conta, autorizar integração, apresentar). Prepare tudo que der e deixe o passo a passo na issue.

## Convenções

- Tabelas `Fato_*`, `Dim_*`, `Param_*`, `Cad_*` (cadastros manuais), `stg_*` (staging); colunas `snake_case`; medidas DAX em português legível ("Total de Passageiros").
- Arquivos de trabalho `cheiU_0N_<Ferramenta>` como no modelo do professor (`cheiU_01_Excel.xlsx`, `cheiU_02_PowerQuery.xlsx`, `cheiU_03_PowerPivot.xlsx`, `cheiU_04_VBA.xlsm`).
- Gêmeos em texto nas subpastas do guia: `scripts_m/<Consulta>.pq` (primeira linha `// <Consulta>`), `dax/medidas_preliminares.dax`, `modulos/*.bas`; dados tratados em `dados_limpos/`, prints em `evidencias/`.
- Branch com o nome sugerido pelo Linear (`oliveiraluck78/tra-<n>-<slug>`); commit `TRA-<n>: <resumo>`; tags `parcial-1` e `final`.
- `.bas` sai com CRLF (exigência do importador do VBE); o `.gitattributes` cuida disso.

## Ambiente

- Windows 11, Excel Microsoft 365 pt-BR (Power Query e Power Pivot), Docker Desktop, Git e `gh` (conta `Luciano-O`).
- Python e Power BI Desktop entram quando a etapa pedir (E0.6 e E7.0). O alias `python` do Windows aponta para a Microsoft Store: use o Python do `.venv`.
- Via COM, `Range.Formula2` espera nomes de função em inglês (`XLOOKUP`); `Range.FormulaLocal` aceita pt-BR (`PROCX`, `;`).

## Repositórios

- `origin`: https://github.com/Luciano-O/projeto_cheiU_FATEC — onde o trabalho acontece.
- `grupo`: https://github.com/Ve3e3/projeto_cheiU_FATEC — repositório oficial citado na proposta; recebe a `main` e as tags nas entregas (passo E0.4).

## Equipe

Só o Luciano usa o Linear e conduz os agentes; os demais aparecem como label de responsável e fazem os commits do próprio trabalho com a conta do GitHub deles (E0.9).

| Integrante | Função | Label |
|---|---|---|
| Victor Lima Conceição | Gerente do projeto, API | `Resp: Victor` |
| Nicolly Santos do Nascimento | Banco de dados SQL, Excel | `Resp: Nicolly` |
| Maryele Naara Freitas Meira | QA, automação VBA | `Resp: Maryele` |
| Luciano Oliveira Gomes | Engenharia de dados, Power Query | `Resp: Luciano` |
