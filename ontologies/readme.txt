Version history for the nmrML.owl versions:

v.1 initial result from the Obo Edit OBO to OWL conversion
v.2 added RA Metadata
v.3 added BFO 1.1 import (better for OBO backwards compatibility)
v.4 This version as v.3, but importing BFO 2.0 instead of non-DL BFO 1.1, BFO 2.0 is experimental, but has a rich set of relations integrated from RO, For BF= 2.0 see
http://ncorwiki.buffalo.edu/index.php/Basic_Formal_Ontology_2.0:_Tutorial_at_ICBO/FOIS file loads from http://bfo.googlecode.com/svn/releases/2012-11-15-bugfix/owl-group/bfo.owl
v.5 This version as v.4, but additionally  importing MSI NMR.owl developed at EBI
v.6 This version as v.5, but importing BiotopLight2.0 instead of BFO 2.0 as top level ontology

To view and edit this owl CV you have to download and install Protege 4.2 or later on your Computer. As the BFO import goes over a weblink, you need to make sure your Computer is connected to the Internet when opening the owl file.


---
Ignore:


ToDOs:

Remark: We miust decide on the formats (OBO vs owl). If we envision a common data annotation pipeline afor MSi and PSI, leveraging on the PSI validators and obo ontologies, we should stick with OBO format, as at the moment these do not integrate particularly well.

For OBO Edit:
Set OBO layout perspective to DanielsPerspective: Download  DanielsPerspective, select  Layout/Import perspective
Set Metadata/ID manager to use <cosmos nmr IDs>.
Under Configuration manager/user preferences set your name and allocate enough Ram (>2GB).
Under Configuration manager/icons one can set an icon to appear in the hiertarchy to indicate a certain object property(relation).

What was done on the obo file:
Set ID rule as specified at http://oboedit.org/docs/html/The_ID_Manager_Plugin.htm

$sequence(length, min_value, max_value)$ 
e.g.
We create a new ID profile called <COSMOS ID profile> with the following default rule: NMR:$sequence(7,1000000,9999999)$ 

Currently largest ID is NMR:1002021, It used the default 7 digit Number.

For Protege:
Set NS
Set ID ranges
RA annotation (Metadata), RU annotation properties (We get both by using BFO 2.0)
agree versioning
agree semantics, i.e. obo backwards compatibility
agree RA and RU metadata
Check if all assumptions made by the OBO to OWL converter worked out right in the owl class definitions
Remove Unit Classes from our file and import UO and ref it instead (only 7 classes affected).

Decide on BFO, OBI or BioTop TLO usage: These provide a proper set of object properties (Relations Ontology) as well. At the moment only a few from UO are used.
Add entry classes as provided by new nmrML.xsd to Cruz CV part
Bin Cruz CV under BFO classes, bin EBI NMR CV clases under BFO Classes and Cruz CV classes. Remove redundant Classes
Align Class naming schemes


Next Step:
Add CVterms als required in the XSD leafs when CVTermType, CVParamType, CVParamWithUnitType... occures. For, e.g. name="buffer" type="CVTermType", we have to create a term "buffer" in the CV, so it camn be further populated according to our use cases?
For e.g. SolventType, decide if we want to have naming coherence of the XSD leafs to the CV entry Class labels ? E.g. Should we put the term Solventtype or the term soplvent intop the CV?

List:
buffer
solvent


