# Etapa 0 — Ambiente

Deixa o ambiente pronto para que qualquer agente ou integrante execute as etapas seguintes. Marco no Linear: **Etapa 0 — Ambiente**.

### E0.1 — Estrutura do repositório e documentação para agentes
- **Resp.** Luciano · Docs · **Depende de** —
- **Objetivo**: repositório com a estrutura do professor, `AGENTS.md`, `CLAUDE.md`, `memories/` e este plano.
- **Saídas**:
  - pastas `MA2026-entrega-parcial/*` e `MA2026-entrega-final/*`, cada uma com `README.md`;
  - `AGENTS.md`, `CLAUDE.md`, `.gitignore`, `.gitattributes`, `.env.example`;
  - `memories/` e `docs/plano/`.
- **Aceite**: um agente novo, lendo só o `AGENTS.md`, consegue localizar o próximo passo e as regras de entrega.
- **Status**: concluído na sessão de 2026-10-16.

### E0.2 — Repositório GitHub e projeto no Linear
- **Resp.** Luciano · Setup · **Depende de** E0.1
- **Objetivo**: `origin` publicado e o plano espelhado no Linear.
- **Saídas**:
  - `https://github.com/Luciano-O/projeto_cheiU_FATEC`;
  - projeto "cheiU — Mobilidade Urbana (ILP590)" no time TRA, com marcos por etapa, labels e uma issue por passo.
- **Aceite**: todo passo de `docs/plano/` tem uma issue `[ID] …` no marco correto, e `origin/main` contém o commit inicial.
- **Status (2026-10-16)**: Linear concluído (issues TRA-5 a TRA-69). A publicação do repositório depende da liberação do Luciano.

### E0.3 — Integração GitHub ↔ Linear
- **Resp.** Luciano · Setup, Humano · **Depende de** E0.2
- **Objetivo**: PRs e branches movem as issues sozinhos.
- **Passos**:
  1. No Linear: Settings → Integrations → GitHub → Connect, autorizando o repositório `Luciano-O/projeto_cheiU_FATEC`.
  2. Conferir a automação de status do time TRA: PR aberto → *In Progress*; PR com merge → *Done*. O time não tem status de revisão.
- **Aceite**: um PR de teste cuja branch contém `tra-<n>` aparece anexado à issue e muda o status dela.

### E0.4 — Repositório do grupo como remote `grupo`
- **Resp.** Victor · Setup, Humano · **Depende de** E0.2
- **Objetivo**: o repositório oficial da proposta recebe as entregas (`memories/decisoes/0003`).
- **Passos**:
  1. Victor adiciona `Luciano-O` como colaborador com permissão *Write* em `Ve3e3/projeto_cheiU_FATEC`.
  2. Agente: `git remote add grupo https://github.com/Ve3e3/projeto_cheiU_FATEC.git` e `git push grupo main`.
  3. Combinar no grupo que commits diretos no repositório do grupo passam a ir pelo `origin`, para evitar divergência.
- **Aceite**: `gh api repos/Ve3e3/projeto_cheiU_FATEC --jq .permissions.push` retorna `true`, e `git ls-remote grupo main` mostra o mesmo commit que `origin/main`.

### E0.5 — Cadastro no DevPlace da SPTrans
- **Resp.** Luciano ou Victor · API, Humano · **Depende de** —
- **Objetivo**: token da API Olho Vivo e acesso ao GTFS.
- **Passos**:
  1. Criar conta em https://www.sptrans.com.br/desenvolvedores/ e confirmar o e-mail.
  2. Em "Meus Aplicativos", criar o app "cheiU-FATEC" e copiar o token para `OLHOVIVO_TOKEN` no `.env`.
  3. Na mesma área, baixar o GTFS e salvar o zip em `MA2026-entrega-parcial/01-excel/dados-brutos/gtfs/_zip/`.
- **Aceite**: `POST https://api.olhovivo.sptrans.com.br/v2.1/Login/Autenticar?token=<token>` retorna `true`, e o GTFS está na pasta.
- **Validar**: o agente testa a autenticação por PowerShell (`Invoke-WebRequest -Method Post`), lendo o token do `.env`.

### E0.6 — Python e ambiente virtual
- **Resp.** Luciano · Python, Setup · **Depende de** —
- **Objetivo**: Python disponível para os scripts de aquisição (`memories/decisoes/0004`).
- **Passos**:
  1. Com o ok do Luciano: `winget install --id Python.Python.3.13 -e` (ou uma versão estável mais recente).
  2. Na raiz: `py -3 -m venv .venv`.
  3. Criar `MA2026-entrega-parcial/01-excel/scripts/requirements.txt` com `requests`, `beautifulsoup4`, `dbfread` e instalar com `.venv\Scripts\python -m pip install -r …`.
- **Aceite**: `.venv\Scripts\python -c "import requests, bs4, dbfread"` roda sem erro.

### E0.7 — Prova de conceito: automação do Excel via COM
- **Resp.** Luciano · Excel, Power Query, Setup · **Depende de** —
- **Objetivo**: confirmar que um agente monta e atualiza pastas de trabalho a partir dos gêmeos em texto (`memories/decisoes/0007`).
- **Saídas**:
  - `MA2026-entrega-parcial/02-powerquery/scripts/ExcelCom.psm1`, com funções reutilizáveis;
  - `memories/automacao-excel.md`, com a receita e os limites encontrados.
- **Passos** (PowerShell, `New-Object -ComObject Excel.Application`):
  1. Criar uma pasta de trabalho de teste com uma célula nomeada `CaminhoRepo`.
  2. `Workbook.Queries.Add(nome, textoDoArquivo.pq)` com uma consulta que lê um CSV pequeno usando `CaminhoRepo`.
  3. Carregar a consulta numa planilha e no Modelo de Dados (`Workbook.Connections.Add2` com `CreateModelConnection`).
  4. Adicionar uma medida DAX (`Workbook.Model.ModelMeasures.Add`) e uma relação (`Workbook.Model.ModelRelationships.Add`).
  5. `RefreshAll` e ler o valor da medida (`CUBEVALUE` numa célula, ou consulta DAX pela conexão ADO do modelo).
  6. Exportar de volta: `Workbook.Queries(i).Formula` → `.pq`; `ModelMeasures(i).Formula` → `.dax`.
  7. Testar importar e exportar `.bas` (`VBProject.VBComponents`). Isso exige a opção "Confiar no acesso ao modelo de objeto do projeto do VBA", que só o Luciano pode ligar na Central de Confiabilidade; registre o resultado.
- **Aceite**: o script cria a pasta de trabalho do zero, atualiza e lê a medida sem intervenção manual. Cada operação está marcada em `memories/automacao-excel.md` como "funciona via COM" ou "exige GUI".
- **Validar**: rodar o script duas vezes seguidas (idempotência) e anexar a saída na issue.
