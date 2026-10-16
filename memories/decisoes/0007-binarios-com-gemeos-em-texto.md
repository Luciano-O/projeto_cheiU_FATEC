# Binários no Git com "gêmeos" em texto, sem Git LFS

Pastas de trabalho do Excel e arquivos do Power BI são binários: o Git não mostra o que mudou neles. Eles são versionados normalmente, sem LFS (que não estava instalado e criaria atrito para o grupo). Ao lado de cada binário fica a lógica em texto, que é a fonte da verdade:

- `.pq` — uma consulta Power Query por arquivo;
- `.dax` — medidas;
- `.bas` — módulos VBA, em CRLF;
- `.sql` — scripts do banco.

Dados brutos com mais de 25 MB por arquivo ficam fora do Git: versionamos o script de download e o `manifesto.csv`.

O passo E0.7 testa se dá para montar e atualizar as pastas de trabalho a partir desses textos via COM. Se der, a pasta de trabalho passa a ser gerada a partir do texto.
