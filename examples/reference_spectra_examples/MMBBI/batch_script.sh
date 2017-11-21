#!/bin/bash

BINDIR=../../../tools/Parser_and_Converters/Java/converter/bin

$BINDIR/nmrMLcreate -b -z -i ./MMBBI_10M12-CE01-1a/1/ | \
$BINDIR/nmrMLproc   -b -z -d ./MMBBI_10M12-CE01-1a/1/pdata/1/ -o ./MMBBI_10M12-CE01-1a.nmrML

