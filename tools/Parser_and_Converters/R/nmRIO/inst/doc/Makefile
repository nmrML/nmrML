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
        Rplots.pdf\
	nmRIO-plotspectrum.pdf\
        *.dvi\
        *.map\
        *.out\

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
	rm -f *~

