JAVABIN = "/cygdrive/c/Program Files/Java/jdk1.7.0_45/bin"
#JAVABIN = /usr/bin
JAVAC = $(JAVABIN)/javac
JAR = $(JAVABIN)/jar
JAVACFLAGS = -cp . 
JAVA = $(JAVABIN)/java
JAVAFLAGS = -cp .
XJC = $(JAVABIN)/xjc
XJCFLAGS = -extension -xmlschema -no-header
XSD = ./xsd/nmrML.xsd
XSDVER:=$(shell grep 'version' $(XSD) | grep 'targetNamespace' | sed -e "s/.\+version=//")

PKG_XSD    = org/nmrml/schema
PKG_CV     = org/nmrml/cv
PKG_PARSER = org/nmrml/parser
PKG_BRUKER = org/nmrml/parser/bruker
PKG_VARIAN = org/nmrml/parser/varian
PKG_CONV   = org/nmrml/converter
SCHEMA_NS  = nmrML
SCHEMA_URI = http://nmrml.org/schema

DIR_BIN    = ../bin

all: xsd parser cv converter jar

parser:
	@make install PROG=$(PKG_PARSER)/*
	@make install PROG=$(PKG_BRUKER)/*
	@make install PROG=$(PKG_VARIAN)/*

cv:
	@make install PROG=$(PKG_CV)/*

xsd: xjc schema_class

xjc:
	@rm -f $(PKG_XSD)/*
	@$(XJC) $(XJCFLAGS) $(XSD)
	@sed -i -e 's#^\(import javax.xml.bind.annotation.XmlType;\)#\1\nimport javax.xml.bind.annotation.XmlRootElement;#' -e  's#^\(@XmlAccessorType.*\)#\1\n@XmlRootElement(name = \"$(SCHEMA_NS)\", namespace = \"$(SCHEMA_URI)\")#' $(PKG_XSD)/NmrMLType.java
	@echo 'package org.nmrml.schema; public class nmrMLversion { public static final String value = $(XSDVER); }' > $(PKG_XSD)/nmrMLversion.java

schema_class:
	@make install PROG=$(PKG_XSD)/*

converter:
	@make install PROG=$(PKG_CONV)/*

install: $(PROG).class

$(PROG).class: $(PROG).java
	@$(JAVAC) $(JAVACFLAGS) $(PROG).java

jar:
	@rm -f ./converter.jar
	@$(JAR) cvfm $(DIR_BIN)/converter.jar ./META-INF/MANIFEST.MF  `find ./org/ -name "*.class"` ./resources/ ./xsd/

clean:
	@find ./org/nmrml -type f -name "*class" -exec rm {} \;
	@rm -f $(PKG_XSD)/*
