View instructions:
To view and edit this owl CV you have to download and install Protege 4.2 or later on your Computer. As the BiotopLight 2 (BTL2) import goes over a weblink, you should make sure your Computer is connected to the Internet when opening the owl file. An HTML serialization of this CV is available from

For Protege: Look at the P4 Setup guideline at https://github.com/nmrML/nmrML/blob/master/docs/CVDocumentation/ConfiguratingProtege4.docx

Version history for the nmrML.owl versions:
http://www.w3.org/TR/2009/REC-owl2-syntax-20091027/#Versioning_of_OWL_2_Ontologies

v.1 initial result from the Obo Edit OBO to OWL conversion
v.2 added RA Metadata (just using standard annotation properties, i.e. DC)
v.3 added BFO 1.1 import (better for OBO backwards compatibility)
v.4 This version as v.3, but importing BFO 2.0 instead of non-DL BFO 1.1. BFO 2.0 is experimental, but has a rich set of relations integrated from RO, For BF0 2.0, see
http://ncorwiki.buffalo.edu/index.php/Basic_Formal_Ontology_2.0:_Tutorial_at_ICBO/FOIS, file loads from http://bfo.googlecode.com/svn/releases/2012-11-15-bugfix/owl-group/bfo.owl
v.5 This version as v.4, but additionally  importing MSI NMR.owl developed at EBI
v.6 This version as v.5, but importing BiotopLight2.0 instead of BFO 2.0 as top level ontology
v.7 This version is a complete new start (as v.6 ended up being too complex and error prone). For this version I removed the unit import from the Wishard nmr.obo, converted it into owl and imported biotop light 2 and the msi-nmr.owl. To make editing easier, I will merge the owl files physically rather than importing the msi-nmr.owl. The tol level classes from OBI and BFO will then vanish as well.
v.8 This version as v.7, but namespace set to NMR, added _purgatory helperclass and started rebinning under biotopLight 2. 
v.9 This version as v.8, but Wishard CV binned under biotopLight2 (btl2). Added RA metadata.
v1.0 As v.9, but removed OBI temporary and outdated IDs and Refs.Taxonomic re-binning of classes that part_of /is_a 'Metabolomics Standards Initiative NMR Spectrometry Vocabularies' under appropriate Biotop classes. Integration of required xsd leaf nodes into CV (see below). Removed Wishard Top Level nodes of doubtful justification, i.e. 'Metabolomics Standards Initiative NMR Spectrometry Vocabularies' and 'spectrum generation information' and 'spectrum interpretation'. 
v1.1 Merged msi namespace nmr ontology (Schober NMR) into Wishard CV (using P4 Refactoring/Merge) in order to get rid of import statements and restriction overriding.
v1.2 Entity (ID) renaming of newly (physically) integrated MSI NMR Terms from MSI namespace to Cosmos nmrML namespace
v1.3 File renaming to get rid of version in Filname (now stores as RA annotation property) infile. New Namespace (now set to http://nmrML.org/nmrCV to distinguish it from xsd namespace). Alignment of ID schemes:To archieve this, we substituted 541 occurances of "nmrCV_" for "nmrCV#NMR:" in the complete owl file. Then we substituited 710 occurrances of "nmrCV#MSI_" with "nmrCV#NMR:1" to align the old MSI IDs to the new NMR prefix and 7 digit length.  Importing DOAP, added RA metadata using http://usefulinc.com/ns/doap#, then removed doap import to get rid of confusing class top level.
v1.4 Empty outdated namespace declarations and NS prefix declarations were removed from the file. The following object properties were taken out of the owl file: 
http://nmrML.org/nmrCV#has_regexp
http://nmrML.org/nmrCV#has_units
http://nmrML.org/nmrCV#part_of
Their usage in the ole Cruz obo file was minor and has to be recreated by hand, but ideally with relations from btl2 with the following mapping:
http://nmrML.org/nmrCV#has_regexp-->
http://nmrML.org/nmrCV#has_units-->
http://nmrML.org/nmrCV#part_of-->http://purl.org/biotop/btl2.owl#isPartOf
v1.5 Major restructuring and redundancy removal, i.e. instruments are now captured as instrument attribute/models.
v1.6 CV is now also covering the term-needs for the BML-NMR XSD. But, again, the CV is still considered to be a prototype. Its coverage can be very shallow at times. For some cases there is merely a corresponding CV Entry Class available (to be referenceable by the xsd), which has no further subclasses. These leaf nodes will have to be expanded successively via our use cases and later by term-requests from the practitioners/users. We can expect the CV to grow from currently to about 2500 Terms (as in PSI MS CV). Labels were aligned to be consistent, i.e. NMR_spectrum_post-processing_parameter_set was changed to NMR_data_post-processing_parameter_set to be in harmony with the existing NMR_data_pre-processing_parameter_set. 'run attribute' was moved into purgatory. Use acquisition parameter instead. This version imports the owl versions of Unit Ontology and PATO (Qualities).


OWL versus OBO Format:
If we envision a common data annotation pipeline for MSI and PSI, leveraging on the PSI validators and obo ontologies, we should stick with OBO format, as at the moment these do not integrate particularly well.
Making the validator software aware of owl formatted CVs is possible according to their Authors: The OntologyAccess interface would need to be reprogrammed and registered in the ontology manager XML config file. An alternative would be a complete re-implementation.

ToDOs:
Add new terms according to our use cases at Wishard Lab, Bordeaux, IPB, EBI, ...
Bin new EBI-NMR CV clases (from PRS) under TLO and Cruz CV classes.
Remove redundant Classes
Remove unused classes/terms not needed by the XSD from the CV ? e.g. acquisition nucleus was required in xsd as sting then it would be redundant to also all these as CV terms.
Align Class naming schemes i.e. replace underscore with space
Refactor terms, using object properties ?
Add links to UO and Pato ? i.e. as were present in the Wishard obo predecessor:
bin end (NMR:1002017) generated 1 warning:
  The term bin end links to the dangling identifier UO:0000169
bin start (NMR:1002016) generated 1 warning:
  The term bin start links to the dangling identifier UO:0000169




List of terms required by current XSD:
these were bookmarked in CV (annotation property) and are visible in the new nmrTab

CVTerm occurrences:
buffer-->buffer
solvent-->solvent
concentration standard type-->calibration compound , what is chemical shift reference ?  What calibration_reference_shift under calibration compound ?
concentration standard name	we here see a use-mention problem arising for the CV. The xsd should probably change here to avoid this.
encoding method (Quadrature detection method)	is this the same as encoding method ?
sample container-->NMR_sample_holder
(spectrum) y axis type-->coordinate system descriptor
post acquisition solvent suppression method	Two usages in xsd, but with differrent type ?  -->solvent suppression method
calibration compound	Two usages in xsd, but with differrent type ?-->calibration compound
data transformation method-->data transformation method
(spectral) projection method-->projection method
spectral denoising method-->spectral denoising method
window function method-->window function method
baseline correction method-->baseline correction
sample type-->NMR sample

CVParam occurrences:
file content-->data file content
software type-->software
source file type-->data file attribute (needs refactoring)
instrument configuration type-->instrument configuration
processing method type-->data processing method

CVParamType occurrences:
chemical shift standard-->chemical shift standard
solvent suppression method-->solvent suppression method
encoding scheme (Quadrature detection method)-->encoding method
window function parameter-->window function parameter

CVParamWithUnitType occurrences:
CVParamWithUnitType is currently not used in the xsd and dangling ! I assume ValueWithUnitType substitutes it ?

UserParamType occurrences:
No CV terms needed

ValueWithUnitType occurrences:
These will have to be used from the Unit ontology.
