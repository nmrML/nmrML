Here is the place to develop the Validator software. We might as well alternatively use a differrent git for this effort, e.g. https://github.com/nmrML/validator 

The semantic validator was developed originally for PSI and is merely re-used here for the MSI nmr validation efforts. The Validator tackles the issue of automatically checking that experimental nmr data is reported using a specific enforceable format (i.e. correct nmrML.xml) and that the used semantic resources (i.e. CVs) are indeed compliant with a given Validation setting, i.e. a Mibbi MI standard like the CIMR - Core Information for Metabolomics Reporting guideline (http://biosharing.org/bsg-000175). The semantic validator does not only check the XML syntax but enforces customizable rules as to how controlled vocabulary terms are used in a particular nmrML.xml data file. It verifies that the terms mentioned exist in its source CV (and it is not just a random string reported in the XML document), and more importantly that the correct terms are used in the correct location, i.e. xml node in an xml document. Moreover the semantic validator framework is extremely flexible and it can be adapted to any PSI/MSI workgroup standard just by customizing the three input files:

    a list of ontologies or CVs necessary to annotate exchanged data in a MIAPE compliant way
    a mapping file formalizing how the necessary CVs and an exchange format are interrelated (see documentation)
    a list of object rules to be run by the validator.
    
    