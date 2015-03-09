Java based nmrML converter: development version 1.1b
==============

(Only 1D NMR is support today. TODO: 2D NMR)

Based on both nmrML.xsd (XML Schema Definition) and CV params (such as ontologies nmrCV, UO, CHEBI ...), a converter written in Java was developed that automatically generates nmrML files, from raw files of the major NMR vendors. The choice of Java was guided by i)  the JAXB framework  (Java Architecture for XML Binding), ii) its OS-platform independence and iii) strengthened by the existence of a useful java library (i.e [nmr-fid-tool](https://github.com/LuisFF/nmr-fid-tool)) for further processing and visualisation of the resulting nmrML data. 

As nmrML intents to gather and integrate several types of data and corresponding metadata in a single file, it is necessary to process each data source separately. Thus, two command tools were developed.

The first one, nmrMLcreate allows to create a new nmrML file, based on available Bruker or Varian/Agilent raw files.
```
$ ./bin/nmrMLcreate -h
usage: nmrMLcreate
 -b,--binary-data                include fid binary data
 -h,--help                       prints the help content
 -i,--inputdir <directory>       input directory
 -o,--outputfile <file>          output file
    --prop <config.properties>   properties configuration file
 -t,--vendortype <vendor>        type
 -v,--version                    prints the version
 -z,--compress                   compress binary data
```

The second one, nmrMLproc allows to add and fill in additional sections corresponding to the data processing step.
```
$ ./bin/nmrMLproc -h
usage: nmrMLproc
 -b,--binary-data                include spectrum binary data
 -d,--procdir <directory>        proc data directory
 -h,--help                       prints the help content
 -i,--nmrml <nmrML file>         nmrML file
 -o,--nmrmlout <file>            output nmrML file
    --prop <config.properties>   properties configuration file
 -t,--vendortype <vendor>        type
 -v,--version                    prints the version
 -z,--compress                   compress binary data
```

Note: Regarding the nmrMLproc command, the nmrML input file can be either  specified  with the '-i' or '--nmrML' options, or be piped.

### Example
Consider we have the following bruker directory tree , with a minimal set of files:
```
./examples/Sample
./examples/Sample/1
./examples/Sample/1/acqus
./examples/Sample/1/fid
./examples/Sample/1/pdata
./examples/Sample/1/pdata/1
./examples/Sample/1/pdata/1/1r
./examples/Sample/1/pdata/1/procs
```
Thus, we can generate the corresponding nmrML file as follow:
```
 ./bin/nmrMLcreate -b -z -t bruker -i ./examples/Sample/1/  |
 ./bin/nmrMLproc -b -z -t bruker -d ./examples/Sample/1/pdata/1/ -o ./examples/Sample.nmrML
```

To make this converter usable without a local installation, it is implemented as a lightweight and easy to access web application (see [here](http://nmrml.org/converter/))





