#  [NMR-ML](http://nmr-ml.org/)

[NMR-ML](http://nmr-ml.org/) is an open mark-up language for NMR data. It is currently under heavy development and is not yet ready for public use.
The development of this standard is coordinated by Workpackage 2 of the [**COSMOS - COordination Of Standards In MetabOlomicS**](http://cosmos-fp7.eu/) Project. COSMOS is a global effort to enable free and open sharing of metabolomics data. Coordinated by Dr Christoph Steinbeck of the EMBL-European Bioinformatics Institute, COSMOS brings together European data providers to set and promote community standards that will make it easier to disseminate metabolomics data through life science e-infrastructures. This Coordination Action has been financed with €2 million by the European Commission's Seventh Framework Programme. 
The NMR-ML data standard will be approved by the Metabolomics standards Initiative and was derived from an earlier NMR-ML that was developed by the Metabolomics Innovation Centre (TMIC).

## NMR-ML links

* [Official Website](http://nmr-ml.org/)
* [NMR-ML on Google-Groups](https://groups.google.com/group/nmrml/subscribe?note=1&hl=en&noredirect=true&pli=1)
* [NMR-ML wiki](https://github.com/NMR-ML/NMR-ML/wiki)
* [NMR-ML at COSMOS](http://cosmos-fp7.eu/nmrML/index.php?title=Main_Page)
* [News Feed](https://github.com/organizations/NMR-ML)

## Development Partners & Contributions

[**The Metabolomics Innovation Centre**](http://www.metabolomicscentre.ca/exchangeformats)

The Metabolomics Innovation Centre (TMIC) is a Canadian-funded core facility that has a unique combination of infrastructure and personnel to perform a wide range of cutting-edge metabolomic studies for clinical trials research, biomedical studies, bioproducts studies, nutrient profiling and environmental testing.
The TMIC platform is led by Dr. David Wishart (University of Alberta), Dr. Christoph Borchers (University of Victoria) and Dr. Liang Li (University of Alberta). This group devivered the NMR-ML predecessor that is amended and extended in the COSMOS Project.

[**Leibniz-Institute of Plant Biochemistry (IPB)**](http://www.ipb-halle.de/en/)

The IPB is a non-university research centre of the Leibniz Association (www.wgl.de), It investigates in a multidisciplinary style structure and function of natural products from plants and fungi, analyse interactions of plants with pathogenic and symbiotic microorganisms and study molecular interactions as part of complex biological processes. At the IPB, plant metabolomics has been an important area of research for many years.
The IPB leads the standards development workpackage within the COSMOS project.
[...]

### Versioning

The versioning follow the [Major].[Minor].[Build], the version number is tracked inthe [VERSION](https://github.com/NMR-ML/NMR-ML/blob/master/VERSION) file in the root of the NMR-ML directory. Versioning is tracked using the taggin feature of git. All previous versions can be viewed [here](https://github.com/NMR-ML/NMR-ML/tags).

Follow these intructions to create release a tagged version: 

1. Commit changes in your working directory that you want in this release. It is a good idea to push these changes to GitHub before continuing. Make sure the changes you want in this release are merged with master.
2. Make sure the [HISTORY.md](https://github.com/NMR-ML/NMR-ML/blob/master/HISTORY.md) file is updated with the changes in this release. Follow the format in the file.
3. Bump the version, rebuild the docs, tag the release and push the release to Github with one of the following commands:
	* For a major release: `make release_major`
	* For a minor release: `make release_minor`	
	* For a build release: `make release_build`
4. Now you can push the release with: 
	git push --tags

## Directory Structure

* [docs](https://github.com/NMR-ML/NMR-ML/tree/master/docs) - The docs generated from the schema and ontology files
* [examples](https://github.com/NMR-ML/NMR-ML/tree/master/examples)
    * [vendor](https://github.com/NMR-ML/NMR-ML/tree/master/examples/vendor) - Useful example files from other software and data formats
    * [nmr-ml]((https://github.com/NMR-ML/NMR-ML/tree/master/examples/nmr-ml) - Example files for different use cases of NMR-ML
* [lib](https://github.com/NMR-ML/NMR-ML/tree/master/lib) - Scripts/code used for generating docs, etc.
* [mappings](https://github.com/NMR-ML/NMR-ML/tree/master/mappings) - Files that map variable names in other formats to variable names
in NMR-ML. Used by conversion software.
* [ontologies](https://github.com/NMR-ML/NMR-ML/tree/master/ontologies) - The ontology files describing the controlled vocabulary
* [schemas](https://github.com/NMR-ML/NMR-ML/tree/master/schemas) - The .xsd files describing the NMR-ML schema
* [tools](https://github.com/NMR-ML/NMR-ML/tree/master/tools) - Example software using NMR-ML

