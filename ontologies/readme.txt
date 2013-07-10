Version history for the nmrML.owl versions:

v.1 initial result from the Obo Edit OBO to OWL conversion
v.2 added RA Metadata (just using standard annotation properties, i.e. DC)
v.3 added BFO 1.1 import (better for OBO backwards compatibility)
v.4 This version as v.3, but importing BFO 2.0 instead of non-DL BFO 1.1. BFO 2.0 is experimental, but has a rich set of relations integrated from RO, For BF0 2.0, see
http://ncorwiki.buffalo.edu/index.php/Basic_Formal_Ontology_2.0:_Tutorial_at_ICBO/FOIS, file loads from http://bfo.googlecode.com/svn/releases/2012-11-15-bugfix/owl-group/bfo.owl
v.5 This version as v.4, but additionally  importing MSI NMR.owl developed at EBI
v.6 This version as v.5, but importing BiotopLight2.0 instead of BFO 2.0 as top level ontology

v.7 This version is a complete new start (as v.6 ended up being too complex and error prone). For this version I removed the unit import from the Wishard nmr.obo, converted it into owl and imported biotop light 2 and the msi-nmr.owl. To make editing easier, I will merge the owl files physically rather than importing the msi-nmr.owl. The tol level classes from OBI and BFO will then vanish as well.
v.8 This version as v.7, but namespace set to NMR, added _purgatory helperclass and started rebinning under biotopLight 2. 
v.9 This version as v8, but Wishard CV binned under biotopLight2 (btl2). Added RA metadata.

To view and edit this owl CV you have to download and install Protege 4.2 or later on your Computer. As the BFO import goes over a weblink, you need to make sure your Computer is connected to the Internet when opening the owl file.

Remark: We must decide on the formats (OBO vs owl) soon. If we envision a common data annotation pipeline for MSI and PSI, leveraging on the PSI validators and obo ontologies, we should stick with OBO format, as at the moment these do not integrate particularly well.
Making the validator software aware of owl formatted CVs is possible according to their Authors: The OntologyAccess interface would need to be reprogrammed and registered in the ontology manager XML config file.

As P4 does not display the part_of hierarchy (as OBO Edit does), in the converted owl file you only see the is a Hierarchy in the class browser to the left. This results in the Wishard CV to look distorted, as in the top level it made much use of part_of relations, which do not display here in P4. I sugggest to rebin these so that they all have proper is_a superclasses that ease navigation.

ToDOs: Depending on the file format we go for we would proceed via the following Steps:

For OBO Edit:
Set OBO layout perspective to e.g. DanielsPerspective: Download  DanielsPerspective (will provide a link), select  Layout/Import perspective
Set Metadata/ID manager to use <cosmos nmr IDs>.
Under Configuration manager/user preferences set your name and allocate enough Ram (>2GB).

What was done on the obo file:
Set ID rule for COSMOS as specified at http://oboedit.org/docs/html/The_ID_Manager_Plugin.htm

$sequence(length, min_value, max_value)$ 

You have to create a new ID profile called <COSMOS ID profile> with the following default rule: NMR:$sequence(7,1000000,9999999)$ 
Currently largest ID is NMR:1002021. It used the default 7 digit Number.


For Protege:

Look at the P4 Setup guideline at https://github.com/nmrML/nmrML/blob/master/docs/CVDocumentation/ConfiguratingProtege4.docx

Set namespace (NS)
Set ID ranges/policies
agree versioning
agree RA and RU metadata: Agree on RA annotation (Metadata), RU annotation properties (we get both by using BFO 2.0)
agree semantics, i.e. obo backwards compatibility, crossproducts
	Check if all assumptions made by the OBO to OWL converter worked out right in the owl class definitions
	As P4 does not display the part_of hierarchy (as OBO Edit does), in the converted owl file you only see the is a Hierarchy in the class browser to the left. I sugggest to rebin these 25? part_of so that they all have proper is_a superclasses that ease navigation.

Remove Unit Classes from our CV file and import UO and ref it instead (only 7 classes affected). The UO classes were put directly into the wishard nmr CV before.

Decide on BFO, OBILight or BioTopLight usage: These provide a proper set of object properties (Relations Ontology) as well. At the moment only a few from UO are used.
Add entry classes as provided by new nmrML.xsd to Cruz CV part.
Bin Cruz CV terms under BFO and MSI NMR CV classes
Bin new EBI-NMR CV clases (from PRS) under TLO and Cruz CV classes.
clean up CV, e.g. rectify modelling errors as described in CV criticism paper
Remove redundant Classes
Align Class naming schemes
Refactor terms, using object properties ?
Add new terms according to our use cases at Wishard Lab, Bordeaux, IPB, EBI, ...

Conclusion: The resulting owl file is quite ugly, as it suffers from unnecessary complexity: The oboInIOwl metadata is something we do not need in the future and which doies only confuse people. The converters are error-prone with current OWL specifications. 
The imports of UO and PATO are at the moment not really justified as they are only used in 7 classes. As most of the partOf relations were wrong in the CV in the first plase it seems unnecessary to try to keep the original CVs crossproducts. It could be that we want to keep e.g. database cross reference [Type:String] value-type:xsd:float i.e. to specify allowed values for sample volume. If we keep this oboInOwl annotations, it might be easier to make the validators aware of the full obo semantiocs in OWL.


I believe we are better off creating the owl file from scratch. This will result in a much cleaner, smaller and more performant CV.

All this will leave us with a version 1.0 to be the first release. From here on we can (finally )gather missing terms from the nmr community.


Next Step:
Add CVterms als required in the XSD leafs when CVTermType, CVParamType, CVParamWithUnitType... occures. For, e.g. name="buffer" type="CVTermType", we have to create a term "buffer" in the CV, so it can be further populated according to our use cases?
For e.g. SolventType, decide if we want to have naming coherence of the XSD leafs to the CV entry Class labels ? E.g. Should we put the term "SolventType" or the term "solvent" intop the CV? I suggest the latter is more correct.

List of terms required by current XSD:

CVTermType occurrences:
buffer
solvent
concentration standard type
concentration standard name	we here see a use-mention problem arising for the CV. The xsd should probably change here to avoid this.
encoding method (Quadrature detection method)	is this the same as for encoding scheme ?
sample container
(spectrum) y axis type
post acquisition solvent suppression method	Two usages in xsd, but with differrent type ?
calibration compound	Two usages in xsd, but with differrent type ?
data transformation method
(spectral) projection method
spectral denoising method
window function method
baseline correction method

CVParamType occurrences:
chemical shift standard
solvent suppression method
encoding scheme (Quadrature detection method)
window function parameter

CVParamWithUnitType occurrences:
CVParamWithUnitType is currently not used in the xsd and dangling ! I assume ValueWithUnitType substitutes it ?

ValueWithUnitType occurrences:
These will have to be used from the Unit ontology.

CVParam:
file content
software type
source file type
instrument configuration type
processing method type

UserParamType:




...


