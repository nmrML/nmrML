#!/bin/bash

MYDIR=$(dirname $0) && [ ! $(echo "$0" | grep '^\/') ] && MYDIR=$(pwd)/$MYDIR
[ `uname -o` == "Cygwin" ] && MYDIR=$(echo "$MYDIR" | sed -e "s/\/cygdrive\/c/C:\//")

JAVA=$(which java)

CONVERTER="$JAVA -jar $MYDIR/converter.jar"

INPUT=$1
OUTPUTARG=
[ $# -gt 1 ] && OUTPUTARG="-o $2"

echo "$CONVERTER -i $INPUT $OUTPUTARG"
$CONVERTER -i $INPUT $OUTPUTARG

