# Espelho das issues do Linear no repositório do grupo

Em 2026-11-21 o Luciano pediu que o caminho completo do projeto aparecesse nas issues do repositório do grupo (`Ve3e3/projeto_cheiU_FATEC`), com os passos prontos fechados. Esse repositório é o oficial da proposta e recebe as entregas (decisão `0003`). O workspace do Linear é privado: quem não tem conta nele, como o professor e os outros integrantes, não vê o plano nem o status.

- **O Linear continua sendo a fonte do status.** As issues do GitHub são uma cópia: cada uma traz o link para a issue do Linear, o status no Linear, o marco, o link para a seção de `docs/plano/` e a descrição do passo copiada do plano.
- **Correspondência**: as 71 issues foram criadas na ordem TRA-5 → TRA-75, então TRA-n = #(n−4) até a TRA-75. Uma issue nova no Linear ou um PR no repositório do grupo quebram essa conta. Daí em diante, a cópia se acha pelo título (`[E2.2] …`) ou buscando `TRA-<n>` no corpo.
- **Estrutura**: um milestone por marco do Linear, as mesmas labels de ferramenta e de responsável, e a label `Em andamento` para as issues em In Progress. Issue em Done vira issue fechada como concluída.
- **Sincronização manual** por `docs/scripts/espelhar_linear.py`, com a tabela de issues atualizada à mão a partir do Linear. O script é idempotente: cria o que falta, atualiza o corpo e as labels e fecha as que estão em Done. Ele não reabre issue fechada.

Alternativas descartadas:

- Criar no repositório `origin`: só o Luciano veria, e o objetivo era o repositório avaliado.
- Issues sem milestones nem labels: perderia a leitura por etapa e por responsável.

Risco assumido: a cópia fica desatualizada se ninguém sincronizar, e então mostra um status errado num repositório público. Mitigação: a regra de sincronização no `AGENTS.md` (passo 5 do Fluxo). A integração do Linear com o GitHub (E0.3, TRA-7) pode tornar a sincronização manual desnecessária quando uma pessoa a autorizar.
