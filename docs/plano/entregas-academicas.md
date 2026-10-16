# Entregas acadêmicas — Parcial 1, Checkpoint e Final

Marcos no Linear: **Parcial 1**, **Checkpoint — Marco de Validação** e **Entrega Final**. As apresentações valem nota: os números citados vêm do modelo, nunca de memória.

## Parcial 1 (aula 8): defesa oral de 10–15 min + relatório parcial + repositório congelado

### P1.1 — Relatório parcial
- **Resp.** Victor · Docs · **Depende de** E2.10
- **Saídas**: `MA2026-entrega-parcial/04-documentacao/relatorio-parcial.md` e o PDF exportado.
- **Conteúdo**:
  - contexto e pergunta central;
  - fontes, cobertura e limitações (`origem_dado`);
  - tratamento no Power Query;
  - modelo dimensional (diagrama);
  - KPIs iniciais com prints do painel;
  - próximos passos.
- **Aceite**: todo número citado aparece no modelo; todo integrante revisou.

### P1.2 — Apresentação da Parcial 1
- **Resp.** Victor · Docs, Humano · **Depende de** P1.1
- **Saídas**: `04-documentacao/apresentacao-parcial-1.pptx` e `04-documentacao/roteiro-parcial-1.md`, com a fala e o tempo de cada um dos 4 integrantes.
- **Aceite**: ensaio cronometrado entre 10 e 15 minutos; demonstração de "Atualizar tudo" com o painel funcionando.

### P1.3 — Congelar o repositório da Parcial 1
- **Resp.** Luciano · Setup · **Depende de** P1.1, P1.2, E0.4
- **Passos**:
  1. PRs da etapa com merge.
  2. `README.md` da raiz com o status atualizado.
  3. `git tag parcial-1` e `git push origin main --tags`.
  4. `git push grupo main --tags`.
- **Aceite**: a tag `parcial-1` aparece nos dois repositórios, apontando para o mesmo commit.

## Checkpoint (aula 16): marco de validação técnica, sem nota

### C.1 — Apresentar o andamento e registrar o feedback
- **Resp.** Victor · Docs, Humano · **Depende de** E5.5
- **Passos**:
  1. Montar um roteiro curto do andamento das Etapas 3–5 e uma lista de dúvidas para o professor.
  2. Depois da aula, registrar o feedback em `memories/progresso.md` e as mudanças de rumo em `memories/decisoes/`.
  3. Criar issues para os ajustes pedidos.
- **Aceite**: todo ponto levantado pelo professor tem registro e, quando for o caso, uma issue.

## Entrega final (aula 20): defesa completa ao vivo

### F.1 — Roteiro da demonstração ao vivo
- **Resp.** Victor · Docs, Humano · **Depende de** E6.7
- **Saídas**: `MA2026-entrega-final/04-powerbi-dashboard/roteiro-demo.md`, com a ordem, o tempo e o responsável de cada parte:
  1. subir o Docker e checar o SQL Server;
  2. atualizar o Excel pela macro;
  3. rodar a macro de QA;
  4. gerar o relatório em PDF;
  5. rodar uma consulta SQL;
  6. fazer uma chamada de API ao vivo;
  7. navegar no Power BI.
- **Plano B**: vídeo gravado e prints de cada parte, para o caso de rede ou máquina falhar.
- **Aceite**: o roteiro foi executado do zero numa máquina que não é a do Luciano, ou o plano B cobre a diferença.

### F.2 — Apresentação final e ensaio
- **Resp.** Victor · Docs, Humano · **Depende de** F.1
- **Saídas**: `MA2026-entrega-final/04-powerbi-dashboard/apresentacao-final.pptx`.
- **Aceite**: ensaio completo cronometrado com os 4 integrantes; a resposta à pergunta central é dita explicitamente.

### F.3 — Congelar a entrega final
- **Resp.** Luciano · Setup · **Depende de** F.2
- **Passos**: merge de tudo, `README.md` final, `git tag final` e push para `origin` e `grupo`.
- **Aceite**: a tag `final` aparece nos dois repositórios; o repositório do grupo abre com o README final.
