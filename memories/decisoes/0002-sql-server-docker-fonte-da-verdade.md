# SQL Server em Docker como fonte da verdade a partir da Etapa 4

O pipeline do curso é uma sequência de ferramentas, mas os dados precisam fluir de forma coerente entre elas. Nas Etapas 1–3 o Excel (Power Query + Power Pivot) é o centro. A partir da Etapa 4, o SQL Server passa a ser a fonte da verdade consolidada: recebe as tabelas tratadas (exportadas pela macro VBA) e os dados de API, e o Power BI lê dele (views `dw.vw_*`), reaproveitando as medidas DAX da Etapa 2.

Escolhemos SQL Server Express porque Excel, Power Query, VBA (ADODB) e Power BI se conectam a ele sem driver extra. Ele roda via `docker-compose` (o Docker já está instalado), o que deixa o ambiente reprodutível para o grupo. Quem não puder usar Docker instala o Express nativo e roda os mesmos scripts T-SQL.

## Opções consideradas

- **SQLite**: um arquivo só, mas Excel e Power BI precisam de driver ODBC.
- **PostgreSQL**: também funcionaria via Docker, porém fora do ecossistema Microsoft do curso.
- **Power BI lendo direto do Excel**: mais simples, mas o SQL viraria só enfeite.
