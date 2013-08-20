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
Word separator (_ vs spc) alignment
ID scheme alignmemnt
Amalgamating nmr and msi namespaces into one NS without imports.
Adding structure, terms required by use case examples, include terms to be refactored from Rubtsov xsd?
Clean up: remove terms not needed by the XSD from the CV ? e.g. acquisition nucleus was required in xsd as sting then it would be redundant to also all these as CV terms.


ID alignment:
 Right now, we find the two ID schemes:
     <!-- http://nmrML.org/nmrCV_1002021 -->
      <owl:Class rdf:about="http://nmrML.org/nmrCV_1002021">
      
     <!-- http://nmrML.org/nmrCV#MSI_400001 -->
     <owl:Class rdf:about="http://nmrML.org/nmrCV#MSI_400001">

These should be aligned into the new scheme:

    <!-- http://nmrML.org/nmrCV#NMR:1000003 -->
    <owl:Class rdf:about="http://nmrML.org/nmrCV#NMR:1000003">
        <rdfs:label xml:lang="en">newcls</rdfs:label>
        <rdfs:subClassOf rdf:resource="http://nmrML.org/nmrCV#_purgatory"/>
    </owl:Class>

To archieve this, we substituted 541 occurances of "nmrCV_" for "nmrCV#NMR:" in the complete owl file. Then we substituited 710 occurrances of "nmrCV#MSI_" with "nmrCV#NMR:1" to alin the old MSI IDs to the new NMR prefix and 7 digit length.

Synomyn capture:
Do we use obo exact synonym or skos or multiple labels or multiople classes set equivalent?

General design premises:
Avoid roles.
Avoid redundance between xsd and CV.
Keep mnames between PSI MzML and MSI nmrML equal where possible: Lets just add the above distinctions into each elements definition to be clearer.
Regarding 'renaming' of elements/terms, we have to find a cutoff between a) making the ML and ontology more intuituive and b) keeping it similar to the PSI MLs, i.e. in order to ease mapping and alignments. In the future there might be the case where people have to orient themselves in both PSI and MSI Standards, i.e. when considering systems biologic research questions. To be future proof I think we should try to use equal labels for the same concepts in PSI and MSI.
So lets stick to the names for the moment and just alter their definitions to be more explicit.


List of terms required by current XSD: these were bookmarked in CV (annotation property) and are visible in the new nmrTab

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
