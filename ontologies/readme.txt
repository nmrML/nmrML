README:

nmrCV big scrub - March2015:

-remove BFO2 import (which carried all temporal relations)
-replace with BFO class only and RO as used by OBI, much lighter and simpler to use.
-remove full UO and PATO import
-replace with small set of core units

-implementation of targeted class import from the following key resources using OntoFox tool
OBI: import of a number of mid level classes for material processing, data preprocessing and data transformations.
CHEBI: all chemical entities created under nmrCV have been deprecated, all corresponding terms have been imported from CHEBI, all missing terms are being submitted to CHEBI
UO: import of only key units (considerably simplified nmrCV)
PSI-MS: to avoid replication of terms already defined under PSI for standards and references
CHMO: import of a number of well defined pulse sequences -> TODO review and merge is required -> liaising with CHMO may be needed.

Why? -> facilitate data integration and implementation of good practice of linked data work -> reuse, do not reinvent.

for more information, inspect OntoFoxInput folder under ./git/NMRml-prs/nmrML/ontologies/ontoFoxInput


-update to class metadata
-on all classes: replacement of 'comment' to 'definition' when the keyword 'defneed' or 'tempdef' was found
-on all classes: creation of 'alternative term' metadata when the keyword 'synonym' was found in a 'comment' metadata tag where def", tempdef or defneed were found too
-on relevant classes: creation of a 'definition source' metadata when the keyword 'defpro' was found in a 'comment' metadata tag where def", tempdef or defneed were found too
-add 'editor note' metadata to provide information or requests


-update on ontology metadata:
	-big scrub:
	-listing of all people involved in the creation of NMRcv (those who attended the Halle meeting) as 'contributor'
	-change to description to avoid verbose and confusing text
	-change to creator: from Daniel Schober to COSMOS group
	-correction to Last Names of several authors (e.g. David Wishard => David Wishart)

-creation of very simple DL axioms on a number of chemical to avoid multiple asserted inheritance. (for chemical shift standard, buffer, solvent...)


revision to ontology metadata:


Quality Control:
1. running reasoner (Hermit + Fact): all ok
2. running Alejandra metadata checker -> report committed -> TODO: add definition
3. import and integration with OBI test. all ok





Tickets:

TODO: harmonize all metadata to IAO ones
TODO: provide definition and definition source for more important terms. ALL DEFINITIONS MUST BE REVIEWED
TODO: a number of chemical still need to be submitted to CHEBI.
