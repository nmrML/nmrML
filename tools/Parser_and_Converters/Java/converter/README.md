Java based nmrML converter: development version 1.2
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
    --xsd-version                prints the nmrML XSD version
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
    --xsd-version                prints the nmrML XSD version
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

### NOTE:

### Java-based converter and the versionning

##### 1/ How does the converter manage to catch both versions nmrML & nmrCV ?

* nmrML XSD - directly within its XML header at the compilation time:

```
<?xml version="1.0" encoding="UTF-8"?>
<xs:schema xmlns:dx="http://nmrml.org/schema" 
  attributeFormDefault="unqualified"
  elementFormDefault="qualified"
  targetNamespace="http://nmrml.org/schema"
  version="1.0.rc1"                              <---- XSD version
  xmlns:xs="http://www.w3.org/2001/XMLSchema" 
  xmlns="http://nmrml.org/schema">
```
At the execution time, the converter retrieves the XSD version from a JAVA Class built at the compilation time.

* nmrCV - In the resources/onto.ini, the nmrCV version has to be defined as follow : :

```
NMRCV = Nuclear Magnetic Resonance CV;1.0.rc1;http://nmrml.org/cv/v1.0.rc1/nmrCV.owl
```
In the execution time, the converter retrieves the nmrCV version:
* either within the resources/onto.ini file
* or in the onto.ini file defined in the config.properties if this latter is specifiy in the parameters (the --prop option)

##### 2/ As results, we should have in the header within the output nmrML file
```
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<nmrML xmlns="http://nmrml.org/schema" 
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       version="1.0.rc1"
       xsi:schemaLocation="http://nmrml.org/schema http://nmrml.org/schema/v1.0.rc1/nmrML.xsd">
```


##### 3/ an new option '--xsd-version' has been added (ver 1.2) to both nmrMLcreate & nmrMLproc commands to get the XSD version on which they were built
```
$ ./bin/nmrMLcreate --xsd-version
nmrML XSD version = 1.0.rc1
```

### License

Creative Commons CC-BY Version 4.0 (See https://creativecommons.org/licenses/)
