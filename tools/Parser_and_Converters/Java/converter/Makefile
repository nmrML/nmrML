JAVABIN = "/cygdrive/c/Program Files/Java/jdk1.7.0_45/bin"
#JAVABIN = /usr/bin
JAVAC = $(JAVABIN)/javac
JAR = $(JAVABIN)/jar
JAVACFLAGS = -cp "./;./library/ini4j-0.5.2.jar;./library/commons-cli-1.2.jar"
JAVA = $(JAVABIN)/java
JAVAFLAGS = -cp "./;./library/ini4j-0.5.2.jar;./library/commons-cli-1.2.jar"
XJC = $(JAVABIN)/xjc
XJCFLAGS = -extension -xmlschema -no-header
XSD = ./xsd/nmrML.xsd

PKG_XSD   = org/nmrml/schema
PKG_CV    = org/nmrml/cv
PKG_CONV    = org/nmrml/converter
PKG_BRUKER = org/nmrml/converter/bruker
PKG_BIN   = org/nmrml/execs

#EXAMPLE = examples/MMBBI_10M12-CE01-1a
#EXPNO   = 1
EXAMPLE = examples/bmse000325.fid
EXPNO   = 1H

all: xsd parser cv converter jar

bruker:
parser:
	@make install PROG=$(PKG_CONV)/*
	@make install PROG=$(PKG_BRUKER)/*

cv:
	@make install PROG=$(PKG_CV)/*

xsd: xjc schema_class

xjc:
	@rm -f $(PKG_XSD)/*
	@$(XJC) $(XJCFLAGS) $(XSD)

schema_class:
	@make install PROG=$(PKG_XSD)/*

converter:
	@make install PROG=$(PKG_BIN)/*
	$(JAVA) $(JAVAFLAGS) $(PKG_BIN)/Converter -i $(EXAMPLE)/$(EXPNO)

install: $(PROG).class

$(PROG).class: $(PROG).java
	@$(JAVAC) $(JAVACFLAGS) $(PROG).java

jar:
	@rm -f ./converter.jar
	@$(JAR) cvfm ./converter.jar ./META-INF/MANIFEST.MF ./org/ ./library/ ./resources/ ./xsd/

clean:
	@find ./org/nmrml -type f -name "*class" -exec rm {} \;
	@rm -f $(PKG_XSD)/*
