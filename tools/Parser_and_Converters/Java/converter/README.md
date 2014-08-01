JAVA converter
==============

nmrML converter: development version 1.0b

Only 1D NMR is support today. TODO: 2D NMR
```
usage: converter
 -d,--binary-data            include binary data such as fid and spectrum values
 -h,--help                   prints the help content
 -i,--inputdir <directory>   input directory
 -o,--outputfile <file>      output file
    --only-fid               exclude all spectrum processing parameters and corresponding binary data
 -t,--vendortype <vendor>    vendor type: bruker(default) or varian
 -v,--version                prints the version
 -z,--compress               compress binary data
```


To see Linux usage:
```
    ./bin/converter -h
```

To see Windows usage:
```
   bin\converter.bat -h
```


JAVA reader
==============

nmrML reader: development version 0.1a


```
usage: nmrMLread
    --fid <output text file>             extract FID data onto a text file
 -h,--help                               prints the help content
 -i,--input <nmrML file>                 input  nmrML file
    --real-spectrum <output text file>   extract Real Spectrum data onto a text file
 -v,--version                            prints the version
```

