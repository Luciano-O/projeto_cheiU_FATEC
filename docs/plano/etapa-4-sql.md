# Etapa 4 — Banco de dados SQL

Entregável do professor (aula 13): script `.sql` com DDL e consultas DML em `02-bancodedados-sql`. Marco no Linear: **Etapa 4 — SQL**.

O SQL Server passa a ser a fonte da verdade (`memories/decisoes/0002`). Arquivos em `MA2026-entrega-final/02-bancodedados-sql/`: `docker-compose.yml`, `00_criar_banco.sql` … `04_views.sql`, `carga/` (CSVs gerados por E3.5, fora do Git) e `README.md`.

### E4.0 — Refinar o plano da Etapa 4
- **Resp.** Nicolly · Docs · **Depende de** E3.6
- **Aceite**: os passos refletem as tabelas e colunas reais exportadas em E3.5.

### E4.1 — SQL Server em Docker
- **Resp.** Nicolly · SQL, Setup · **Depende de** E4.0
- **Saídas**: `docker-compose.yml` e `00_criar_banco.sql`.
- **Configuração do container**:
  - imagem `mcr.microsoft.com/mssql/server`, com a tag LTS mais recente;
  - `ACCEPT_EULA=Y`, `MSSQL_PID=Express`, `MSSQL_SA_PASSWORD` lida do `.env`;
  - porta 1433;
  - volume nomeado para os dados e `./carga:/carga:ro` para a carga.
- **Banco**: `00_criar_banco.sql` cria o banco `cheiU` e os schemas `stg` e `dw`.
- **Cliente SQL**: `sqlcmd` (go-sqlcmd via winget) ou SSMS, instalados com o ok do Luciano.
- **Aceite**:
  - `docker compose up -d` deixa o container *healthy*;
  - `sqlcmd -S localhost -U sa -Q "SELECT @@VERSION"` responde;
  - Excel › Obter Dados › SQL Server conecta.

### E4.2 — DDL do modelo dimensional
- **Resp.** Nicolly · SQL · **Depende de** E4.1
- **Saídas**: `01_ddl.sql`, com tabelas `dw.Dim_*`, `dw.Fato_*` e `dw.Param_*` espelhando o modelo da Etapa 2, mais tabelas `stg.*` com as mesmas colunas, tipadas como texto.
- **Regras**:
  - chaves primárias e estrangeiras;
  - `CHECK (origem_dado IN ('real','estimado','simulado'))`;
  - índices nas chaves estrangeiras;
  - script idempotente (`DROP ... IF EXISTS`, na ordem certa).
- **Aceite**: o script roda duas vezes seguidas sem erro; diagrama ER salvo em `modelo-er.png`.

### E4.3 — Carga
- **Resp.** Nicolly · SQL · **Depende de** E4.2, E3.5
- **Saídas**: `02_carga.sql`, com a procedure `dw.usp_carregar_tudo`, que:
  1. faz `TRUNCATE` das tabelas `stg`;
  2. carrega com `BULK INSERT stg.X FROM '/carga/X.csv' WITH (FORMAT='CSV', CODEPAGE='65001', FIRSTROW=2)`;
  3. converte os tipos e grava no `dw` em transação.
- **Opcional**: macro `modSQL.CarregarNoSQL` (ADODB) que chama a procedure a partir do Excel.
- **Aceite**: o número de linhas é igual entre `dw`, CSV e modelo do Excel; rodar a carga duas vezes dá o mesmo resultado.

### E4.4 — Consultas analíticas (DML) e views
- **Resp.** Nicolly · SQL · **Depende de** E4.3
- **Saídas**:
  - `03_consultas.sql`: pelo menos 10 consultas, cada uma com um comentário dizendo a pergunta que responde, usando `GROUP BY`, CTEs e funções de janela (`RANK`, `LAG`). Temas:
    - total por modalidade e mês;
    - dia útil × fim de semana;
    - top linhas;
    - demanda estimada por hora (junção com o perfil);
    - lotação simulada por linha × hora;
    - pico × fora do pico;
    - variação mensal;
    - alternativas de percurso nos corredores;
    - efeito da chuva (depois da Etapa 5).
  - `04_views.sql`: views `dw.vw_*` que o Power BI vai consumir.
- **Aceite**: todas as consultas e views rodam sem erro na base carregada.

### E4.5 — Reconciliação SQL × DAX e fechamento
- **Resp.** Maryele · QA, SQL · **Depende de** E4.4
- **Saídas**: `MA2026-entrega-parcial/04-documentacao/qa/etapa-4.md`, comparando 5 KPIs-chave entre o SQL e as medidas DAX; `README.md` da pasta com o passo a passo do zero (`.env` → compose → scripts → carga).
- **Aceite**: os 5 KPIs são iguais nos dois lados (tolerância de arredondamento); outra pessoa sobe o banco seguindo só o README.
