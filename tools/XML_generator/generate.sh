#!/bin/bash
MYDIR=`dirname $0` && [ ! `echo "$0" | grep '^\/'` ] && MYDIR=`pwd`/$MYDIR

JAVABIN=/cygdrive/c/jdk7/bin
XJC=$JAVABIN/xjc
JAVAC=$JAVABIN/javac
JAVA=$JAVABIN/java

VER=$( $JAVA -version 2>&1 | head -1 | cut -d' ' -f3 | sed -e "s/\"//g" | cut -d'.' -f1,2 )
[ "$VER" != "1.7" ] && echo "WARNING: this test program has only been tested with the JDK 7"

TEST=dx2nmrML
XSD=nmrML.xsd
PKG=org/nmrml/schema

#1/ Generate Class object
$XJC -extension -xmlschema -no-header  $XSD

# --  XJC BUGS ?? ---
# In the root object nmrMLType insert the line:
# import javax.xml.bind.annotation.XmlRootElement;
#
# And just before the Public class NmrMLType declaration, put the line:
# @XmlRootElement

sed -i -e "s/import javax.xml.bind.annotation.XmlType;/import javax.xml.bind.annotation.XmlType;\nimport javax.xml.bind.annotation.XmlRootElement;/" \
       -e "s/public class NmrMLType/@XmlRootElement\npublic class NmrMLType/" $MYDIR/$PKG/NmrMLType.java


# 2/ Compile Class object
$JAVAC ./$PKG/*.java

#3/ Compile the test program
$JAVAC -cp ./ $TEST.java

#4/ Run Test
echo
echo "Launch test program"
echo
$JAVA -cp ./ $TEST
