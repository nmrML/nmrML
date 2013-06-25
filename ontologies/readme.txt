Version history for the nmrML.owl versions:

v.1 initial result from the Obo Edit OBO to OWL conversion
v.2 added RA Metadata (just using standard annotation properties, i.e. DC)
v.3 added BFO 1.1 import (better for OBO backwards compatibility)
v.4 This version as v.3, but importing BFO 2.0 instead of non-DL BFO 1.1. BFO 2.0 is experimental, but has a rich set of relations integrated from RO, For BF0 2.0, see
http://ncorwiki.buffalo.edu/index.php/Basic_Formal_Ontology_2.0:_Tutorial_at_ICBO/FOIS, file loads from http://bfo.googlecode.com/svn/releases/2012-11-15-bugfix/owl-group/bfo.owl
v.5 This version as v.4, but additionally  importing MSI NMR.owl developed at EBI
v.6 This version as v.5, but importing BiotopLight2.0 instead of BFO 2.0 as top level ontology

To view and edit this owl CV you have to download and install Protege 4.2 or later on your Computer. As the BFO import goes over a weblink, you need to make sure your Computer is connected to the Internet when opening the owl file.


Remark: We must decide on the formats (OBO vs owl). If we envision a common data annotation pipeline for MSI and PSI, leveraging on the PSI validators and obo ontologies, we should stick with OBO format, as at the moment these do not integrate particularly well.
Making the validator software aware of owl formatted CVs is possible according to their Authors: The OntologyAccess interface would need to be reprogrammed and registered in the ontology manager XML config file.

ToDOs: Depending on the file format we go for we would proceed via the following Steps:

For OBO Edit:
Set OBO layout perspective to e.g. DanielsPerspective: Download  DanielsPerspective (will provide a link), select  Layout/Import perspective
Set Metadata/ID manager to use <cosmos nmr IDs>.
Under Configuration manager/user preferences set your name and allocate enough Ram (>2GB).

What was done on the obo file:
Set ID rule for COSMSO as specified at http://oboedit.org/docs/html/The_ID_Manager_Plugin.htm

$sequence(length, min_value, max_value)$ 

You have to create a new ID profile called <COSMOS ID profile> with the following default rule: NMR:$sequence(7,1000000,9999999)$ 
Currently largest ID is NMR:1002021. It used the default 7 digit Number.


For Protege:
Set namespace (NS)
Set ID ranges
agree versioning
agree RA and RU metadata: Agree on RA annotation (Metadata), RU annotation properties (we get both by using BFO 2.0)
agree semantics, i.e. obo backwards compatibility, crossproducts
	Check if all assumptions made by the OBO to OWL converter worked out right in the owl class definitions
Remove Unit Classes from our CV file and import UO and ref it instead (only 7 classes affected). The UO classes were put directly into the wishard nmr CV before.

Decide on BFO, OBILight or BioTopLight usage: These provide a proper set of object properties (Relations Ontology) as well. At the moment only a few from UO are used.
Add entry classes as provided by new nmrML.xsd to Cruz CV part.
Bin Cruz CV terms under BFO and MSI NMR CV classes
Bin new EBI-NMR CV clases (from PRS) under TLO and Cruz CV classes.
Remove redundant Classes, clean up CV.
Align Class naming schemes
Refactor terms, using opject properties ?
Add new terms according to our use cases at Wishard Lab, Bordeaux, IPB, EBI, ...

From here on we can gather missing terms from the nmr community.


Next Step:
Add CVterms als required in the XSD leafs when CVTermType, CVParamType, CVParamWithUnitType... occures. For, e.g. name="buffer" type="CVTermType", we have to create a term "buffer" in the CV, so it can be further populated according to our use cases?
For e.g. SolventType, decide if we want to have naming coherence of the XSD leafs to the CV entry Class labels ? E.g. Should we put the term "SolventType" or the term "solvent" intop the CV? I suggest the latter is more correct.

List of terms required by current XSD:
buffer
solvent

...

