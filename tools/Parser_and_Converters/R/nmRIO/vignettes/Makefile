LATEXFILES = *.aux\
	*.bbl\
	*.blg\
	*.ilg\
	*.log\
	*.nlo\
	*.nls\
	*.toc\
	*.aux\
	nmRIO.tex\
	nmRIO.pdf\
	nmRIO-plot.pdf\
	*.dvi\
	*.map\
	*.out\
	nmRIO.synctex.gz\
	*concordance.tex

all:
	make vignette
	make clean

setvars:
ifeq (${R_HOME},)
R_HOME= $(shell R RHOME)
endif

vignette:
	"$(R_HOME)/bin/R" CMD Sweave nmRIO.Rnw
	pdflatex nmRIO.tex
	bibtex nmRIO
	pdflatex nmRIO.tex
	pdflatex nmRIO.tex

clean:
	rm -f $(LATEXFILES)


