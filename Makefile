# Allgemeines Makefile zur Erzeugung von Studien/Diplomarbeiten
# mittels LaTeX und der studdipl.cls von Wolfgang Heidrich
# Makefile (C) 98 Christian Vogelgsang <cnvogelg@immd9.informatik.uni-erlangen.de>

# Aufruf:
#  make           Erzeugt alle Figures, die dvi Dateien und die ps Ausgabe
#  make show      Zeigt die Arbeit als DVI datei unter X11 an
#  make clean     Loescht alle temporaeren und erzeugten Daten
#  make editclen  Loescht zusaetzlich zu clean noch alle Backup-Dateien

# Name der BibTeX Datei fuer das Literaturverzeichnis: xxx.bib als File
BIB=Literatur

# Name des .tex Hauptdokuments
FRAME=Arbeit

# Name der .tex Datei fuer das Titelblatt
TITLE=Deckblatt

# Verzeichnis fuer die Kapitel (LaTeX Dateien)
CHAPTER_DIR := chapters

# Verzeichnis fuer den Anhang (LaTeX Dateien)
APPENDIX_DIR := appendices

# Verzeichnis fuer die Abbildungen (xfig Dateien)
FIGURE_DIR := figures

# Verzeichnis fuer die Bilder (png Dateien)
PICTURE_DIR := pictures

# Verzeichnis fuer GNU plots
PLOT_DIR := plots

CHAPTER_LIST := Chapter.tex
APPENDIX_LIST := Appendix.tex

# Quelldateien
CHAPTER  := $(wildcard $(CHAPTER_DIR)/*.tex)
APPENDIX := $(wildcard $(APPENDIX_DIR)/*.tex)
FIGURE   := $(wildcard $(FIGURE_DIR)/*.fig)
PICTURE  := $(wildcard $(PICTURE_DIR)/*.png)
PLOT     := $(wildcard $(PLOT_DIR)/*.plt)

# Erzeugte Dateien
FIGURE_PS    := $(patsubst %.fig,%.ps,$(FIGURE))
FIGURE_TEX   := $(patsubst %.fig,%.tex,$(FIGURE))
PICTURE_PS   := $(patsubst %.png,%.ps,$(PICTURE))
PLOT_PS      := $(patsubst %.plt,%.ps,$(PLOT))
CHAPTER_INP  := $(patsubst %,\input{%},$(CHAPTER))
APPENDIX_INP := $(patsubst %,\input{%},$(APPENDIX))

# Dateien, die bei clean geloescht werden
TEMPFILES := Makefile.fig transfig.tex \
	$(FIGURE_PS) $(FIGURE_TEX) $(PICTURE_PS) $(PLOT_PS) \
	$(CHAPTER_LIST) $(APPENDIX_LIST)

# virtuelle Targets
.PHONY: all showdvi showps showpdf clean editclean pictures figures ps dvi pdf


# ---- Kommandos ----

# Erzeuge ps datei als default
all: showps

title: ps
	gv $(TITLE).ps

# Zeige Dokument mit xdvi
showdvi: dvi
	xdvi $(FRAME).dvi

showps: ps
	gv $(FRAME).ps

showpdf: pdf
	acroread $(FRAME).pdf

# Loesche alle temporaeren Dateien
clean:
	-rm -f $(TEMPFILES)
	-rm -f *.dvi *.aux *.log *.lof *.lot *.toc *.ps *.bbl *.blg *.pdf

# Loesche alle Temporaeren Dateien 
editclean: clean
	-find . -name "*~" -exec rm {} \;
	-find . -name "#*#" -exec rm {} \;
	-find . -name "*.bak" -exec rm {} \;

# Hilfe!
help:
	@echo "all       (default) erzeuge Arbeit PS und zeige es"
	@echo "title     erzeuge Deckblatt PS und zeige es"
	@echo "showdvi   zeige DVI der Arbeit"
	@echo "showps    zeige PS der Arbeit"
	@echo "showpdf   zeige PDF der Arbeit"
	@echo "clean     loesche generierte Dateien"
	@echo "editclean loesche Editor Dateien"

# ---- LaTeX -----

dvi: $(FRAME).dvi $(TITLE).dvi
ps:  $(FRAME).ps  $(TITLE).ps
pdf: $(FRAME).pdf $(TITLE).pdf

# ---- Allgemeine Regeln ----

# ps -> pdf
%.pdf: %.ps
	ps2pdf14 $< $@

# dvi -> ps 
%.ps: %.dvi
	dvips -o $@ $<

# fig -> ps
%.ps: %.fig
	transfig -L pstex -M Makefile.fig -T transfig.tex $<
	$(MAKE) -f Makefile.fig
	rm Makefile.fig

# png -> ps
%.ps: %.png
	convert $< $@

# plt -> ps
%.ps: %.plt
	gnuplot $<

# ---- Arbeit ----

pictures: $(PICTURE_PS)
	@echo "----- Converted Pictures -----"

figures: $(FIGURE_PS)
	@echo "----- Converted Figures -----"

plots: $(PLOT_PS)
	@echo "----- Converted GNU plots -----"

$(CHAPTER_LIST): $(CHAPTER)
	@echo "$(CHAPTER_INP)" > $(CHAPTER_LIST)

$(APPENDIX_LIST): $(APPENDIX)
	@echo "$(APPENDIX_INP)" > $(APPENDIX_LIST)

FRAME_FILES := figures pictures plots \
	$(CHAPTER_LIST) $(APPENDIX_LIST) $(BIB).bib $(FRAME).tex

$(FRAME).dvi: $(FRAME_FILES)
	@echo "----- LaTeX for Work: $(FRAME) -----"
	latex $(FRAME)
	bibtex $(FRAME)
	latex $(FRAME) > /dev/null < /dev/null
	latex $(FRAME) > /dev/null < /dev/null
	@echo "----- Warnings: -----"
	@-grep "Warning" $(FRAME).log || true
	@echo "----- ERRORS: -----"
	@-grep "Error" $(FRAME).log || true

# ----- Deckblatt -----

$(TITLE).dvi: $(TITLE).tex
	@echo "----- LaTeX for Title: $(TITLE) -----"
	latex $(TITLE)
