# Master Thesis

[![CC BY-NC-ND 3.0](https://licensebuttons.net/l/by-nc-nd/3.0/88x31.png)](https://creativecommons.org/licenses/by-nc-nd/3.0/)

[![made-with-latex](https://img.shields.io/badge/Made%20with-LaTeX-1f425f.svg)](https://www.latex-project.org/)
[![using-matlab](https://img.shields.io/badge/Using-MATLAB-red)](https://www.mathworks.com)
[![using-python](https://img.shields.io/badge/Using-Python-blue)](https://www.python.org)


Este é o repositório contendo os arquivos da tese de mestrado em formato Latex.

Abaixo estão algumas instruções gerar um PDF deste tese com base nos arquivos encontrados.

## Configurando computador Windows

Computadores Windows não suportam arquivos Tex nativamente, então alguns passos são necessários antes da compilação.

1. Instalar o [MikTex](https://miktex.org/). Este é o 'backend' dos arquivos Tex;
2. Instalar o [TexMaker](http://www.xm1math.net/texmaker/). 'Frontend' para desenvolvimento e compilação do texto.
3. Instalar o [Strawberry Perl](http://strawberryperl.com/). Uma distribuição open-souce do Perl para Windows.

## Compilando os arquivos

O arquivo mestre desta tese é o `thesis.tex`, encontrado na raíz desse repositório.É possível compilá-lo utilizando a própria interface gráfica do TexMaker, porém ela não compila o glossário automáticamente, sendo necessário disparar o comando `makeglossaries` no prompt de comando do Windows.

Para facilitar todas as etapas de compilação requeridas, basta executar o arquivo `compile.bat`, também encontrado na raíz do repositório.
