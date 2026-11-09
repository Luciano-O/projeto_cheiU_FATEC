# Roteiro da apresentação da Parcial 1

Slides: `apresentacao-parcial-1.pptx` (as falas também estão nas anotações de cada slide). Tempo previsto: 12min30s, dentro da faixa de 10 a 15 minutos.

**Ensaio cronometrado: não realizado.** O tempo abaixo é uma estimativa. Responsável pela apresentação: Victor Lima Conceição; a divisão das falas é uma proposta para o grupo ajustar.

| Slide | Tema | Quem | Tempo |
|---|---|---|---|
| 1 | Capa | Victor | 0:30 |
| 2 | Problema e pergunta central | Victor | 1:00 |
| 3 | Recorte da N1 e fontes | Victor | 1:00 |
| 4 | Defeitos reais | Maryele | 1:30 |
| 5 | Etapa 1: base auditável | Maryele | 1:00 |
| 6 | Etapa 2: tratamento e reconciliação | Luciano | 1:30 |
| 7 | Etapa 3: modelo em estrela | Luciano | 1:30 |
| 8 | KPIs | Luciano | 1:00 |
| 9 | Demonstração ao vivo | Luciano | 2:00 |
| 10 | Limitações | Maryele | 1:00 |
| 11 | Próximos passos | Victor | 0:30 |

Total por pessoa: Victor 3:00, Maryele 3:30, Luciano 6:00.

## Demonstração (slide 9)

Antes de começar: deixe `MA2026-entrega-parcial/03-powerpivot/cheiU_03_PowerPivot.xlsx` aberto. O arquivo deriva o caminho sozinho, desde que o clone tenha a pasta `02-powerquery` ao lado.

1. Dados › Atualizar Tudo (menos de 1 minuto).
2. Aba `Conferencia`: as 12 diferenças continuam em 0; passageiros 2.124.704.175 na Etapa 2 e no modelo; 461.839 linhas na fato; 6.672 rejeitadas.
3. Aba `Validacao`: clicar em "Feriado" na segmentação de tipo de dia e mostrar que as 5 tabelas dinâmicas mudam; limpar o filtro.

Se a atualização falhar ao vivo, mostre os valores já salvos no arquivo e a tabela da seção 6 do relatório parcial.

## Perguntas prováveis

- **Por que só ônibus?** O portal do Metrô estava fora do ar e a CPTM só libera o download pelo navegador; as duas fontes entram quando houver arquivo.
- **Por que os dados não batem com o total oficial?** De agosto a dezembro a diferença fica até 0,40%; de janeiro a julho vai de 0,77% a 5,15%. Janeiro confere com o consolidado da própria SPTrans, então não é perda no tratamento. A causa ainda não foi confirmada.
- **Como garantem que nenhuma linha sumiu?** `Conf_Reconciliacao`: 486.864 lidas = 480.192 aceitas + 6.672 rejeitadas, todas com motivo.
