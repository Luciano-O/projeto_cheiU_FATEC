# memories/

Memória de longo prazo do projeto: o que um agente ou integrante precisa saber e não consegue descobrir só olhando os arquivos.

| Arquivo | Conteúdo | Como escrever |
|---|---|---|
| `glossario.md` | Termos do domínio (demanda, lotação, cadeia modal…) | Uma ou duas frases por termo, dizendo o que ele **é**; sinônimos rejeitados em _Evite_. Sem detalhes de implementação. |
| `decisoes/NNNN-slug.md` | Uma decisão por arquivo | Só quando é difícil de reverter, surpreende quem chega e resultou de um trade-off real. Um parágrafo basta: contexto, decisão, porquê. Numeração sequencial. |
| `fontes-de-dados.md` | URLs, formatos, granularidade, autenticação e pegadinhas de cada fonte e API | Data de verificação em cada fonte (AAAA-MM-DD). Corrija no lugar quando algo mudar. |
| `progresso.md` | Diário das sessões, mais recente no fim | Uma entrada por sessão: data, issue, feito, pendente, próximo passo. Só acrescente. |
| `automacao-excel.md` | Receita para criar e atualizar pastas de trabalho via COM | Criado no passo E0.7. |

Regras gerais:

- Datas sempre absolutas (`2026-10-16`), nunca "ontem" ou "semana que vem".
- Cada fato mora em um lugar só; os outros arquivos apontam para ele.
- Ao perceber que algo aqui está errado ou velho, corrija ou apague na mesma sessão.
