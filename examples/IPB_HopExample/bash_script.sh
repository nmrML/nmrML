#!/bin/bash

BINDIR=../../tools/Parser_and_Converters/Java/converter/bin

INDIR=FIDs
OUTDIR=nmrMLs.v2

for d in $(ls $INDIR); do
  echo "$d"
  $BINDIR/nmrMLcreate -t varian -b -z -i $INDIR/$d/ -o $OUTDIR/$d.nmrML
done


