
JAVABIN = /cygdrive/c/jdk7/bin
JAVAC = $(JAVABIN)/javac
JAVACFLAGS = -cp ./
JAVA = $(JAVABIN)/java
JAVAFLAGS = -cp ./
XJC = $(JAVABIN)/xjc
XJCFLAGS = -extension -xmlschema -no-header
XSD = ./xsd/nmrML.xsd

PKG_XSD   = org/nmrml/schema
PKG_CV    = org/nmrml/cv
PKG_UK    = uk/ac/ebi/nmr/fid
PKG_UK_IO = uk/ac/ebi/nmr/fid/io
PKG_DEV   = org/nmrml/test
DIR_BRUKER=./test


all: parser cv xsd dev

parser:
	@make install PROG=$(PKG_UK)/*
	@make install PROG=$(PKG_UK_IO)/*

cv:
	@make install PROG=$(PKG_CV)/*

xsd: xjc schema_class

xjc:
	@$(shell [ `find $(PKG_XSD)/ -type f -name "*.java" | wc -l` -eq 0 ] && $(XJC) $(XJCFLAGS) $(XSD) 1>/dev/null 2>/dev/null)

schema_class:
	@make install PROG=$(PKG_XSD)/*

dev:
	@make install PROG=$(PKG_DEV)/*

install: $(PROG).class

$(PROG).class: $(PROG).java
	$(JAVAC) $(JAVACFLAGS) $(PROG).java

testcv: cv dev
	$(JAVA) $(JAVAFLAGS) $(PKG_DEV)/CVTest

testxml: xsd dev
	$(JAVA) $(JAVAFLAGS) $(PKG_DEV)/dx2nmrML

testparser: parser dev
	$(JAVA) $(JAVAFLAGS) $(PKG_DEV)/TestReader $(DIR_BRUKER)
