echo Deleting files
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

REM pdflatex thesis.tex
REM bibtex thesis
REM makeindex thesis.idx
REM makeglossaries thesis
REM pdflatex thesis.tex
REM pdflatex thesis.tex

pdflatex VersaoDigital.tex
bibtex VersaoDigital
makeindex VersaoDigital.idx
makeglossaries VersaoDigital
pdflatex VersaoDigital.tex
pdflatex VersaoDigital.tex

pdflatex VersaoImpressa.tex
bibtex VersaoImpressa
makeindex VersaoImpressa.idx
makeglossaries VersaoImpressa
pdflatex VersaoImpressa.tex
pdflatex VersaoImpressa.tex

pause