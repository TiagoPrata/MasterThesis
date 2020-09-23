echo ============== Deleting files =====================
del "*.acn" /s /f /q
del "*.acr" /s /f /q
del "*.alg" /s /f /q
del "*.aux" /s /f /q
del "*.bbl" /s /f /q
del "*.blg" /s /f /q
del "*.brf" /s /f /q
del "*.fdb_latexmk" /s /f /q
del "*.fls" /s /f /q
del "*.glg" /s /f /q
del "*.glo" /s /f /q
del "*.gls" /s /f /q
del "*.glsdefs" /s /f /q
del "*.idx" /s /f /q
del "*.ilg" /s /f /q
del "*.ind" /s /f /q
del "*.ist" /s /f /q
del "*.lof" /s /f /q
del "*.log" /s /f /q
del "*.loq" /s /f /q
del "*.lot" /s /f /q
del "*.lol" /s /f /q
del "*.sbl" /s /f /q
del "*.simbolos" /s /f /q
del "*.synctex.gz" /s /f /q
del "*.toc" /s /f /q

echo ============= Compilando Versao Impressa ==============
pdflatex -jobname=VersaoImpressa "\def\isprintedversion{1} \input{thesis.tex}"
bibtex thesis
makeindex thesis.idx
makeglossaries thesis
pdflatex -jobname=VersaoImpressa "\def\isprintedversion{1} \input{thesis.tex}"
pdflatex -jobname=VersaoImpressa "\def\isprintedversion{1} \input{thesis.tex}"

echo ============= Compilando Versao Digital ==============
pdflatex -jobname=VersaoDigital thesis.tex
bibtex thesis
makeindex thesis.idx
makeglossaries thesis
pdflatex -jobname=VersaoDigital thesis.tex
pdflatex -jobname=VersaoDigital thesis.tex

pause