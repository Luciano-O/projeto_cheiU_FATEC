# Publicação direta no repositório do grupo

Em 2026-11-27 o Luciano pediu que todas as atualizações chegassem direto ao repositório do grupo (`Ve3e3/projeto_cheiU_FATEC`). Até então, a `main` só ia para lá nas entregas (decisão `0003`), e o merge de cada PR esperava a revisão dele. Por isso, a `main` do grupo estava 4 commits atrás da do `origin`.

- **O agente publica**: com o Aceite verificado, ele mergeia o PR no `origin` (`gh pr merge <n> --merge`, merge commit como nos PRs anteriores) e empurra a `main` para o grupo (`git push grupo origin/main:main`). A `main` do grupo é sempre um avanço rápido da do `origin`, e as duas ficam iguais depois de cada publicação.
- **PR parcial**: um PR que entrega parte de um passo (`Refs TRA-<n>`, sem `Closes`) também é publicado. A issue continua em *In Progress*.
- **Linear e espelho**: quando o PR fecha o Aceite, a issue vai para *Done* e a cópia no grupo é fechada como concluída (decisão `0011`).
- **Tags**: `parcial-1` e `final` continuam marcando as entregas.
- **Commits de outro integrante**: nada muda (decisão `0008`). O responsável faz o commit e abre o PR; o agente publica depois.

Alternativas descartadas:

- **PRs direto no repositório do grupo**: o `origin` deixaria de ser onde o trabalho acontece, e o espelho de issues e os PRs anteriores ficariam em lugares diferentes.
- **Continuar com o merge manual e só empurrar depois**: não atende o pedido, porque o grupo ficaria esperando cada revisão.

Risco assumido: um erro que passe pela verificação do Aceite chega ao repositório que o professor avalia. Mitigação: só se publica com a evidência do Aceite (ou da parte entregue) no PR. Se algo der errado, a correção vem como um novo commit, sem reescrever a `main`.
