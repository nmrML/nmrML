<p align="center">
<img src="https://raw.github.com/nmrML/nmrML/master/docs/logo/images/horizontal-logo-500.png" alt="nmrML logo" >
</p>

[nmrML](http://nmrml.org/) is an open mark-up language for NMR raw and spectral data. It has recently seen its first release, ready for public use. The development of this standard was previously coordinated by the COSMOS FP7- COordination Of Standards In MetabOlomicS Project. It is now maintained within the PhenoMeNal H2020 project, setting up metabolomics data analysis e-infrastructures. The nmrML data standard is approved by the Metabolomics Standards Initiative and was derived from an earlier NMR XML format that was developed by the Metabolomics Innovation Centre (TMIC). It follows design principles of its role model, the mzML data standard, created by HUPO-PSI community for mass spectrometry.

## nmrML links

* [Official Website](http://nmrml.org/)
* [nmrML on Google-Groups](https://groups.google.com/group/nmrml/subscribe?note=1&hl=en&noredirect=true&pli=1)
* [nmrML wiki](https://github.com/nmrML/nmrML/wiki)
* [nmrML at COSMOS](http://cosmos-fp7.eu/nmrML/index.php?title=Main_Page)
* [News Feed](https://github.com/organizations/nmrML)

## Development Partners & Contributions

[**The Metabolomics Innovation Centre**](http://www.metabolomicscentre.ca/exchangeformats)

The Metabolomics Innovation Centre (TMIC) is a Canadian-funded core facility that has a unique combination of infrastructure and personnel to perform a wide range of cutting-edge metabolomic studies for clinical trials research, biomedical studies, bioproducts studies, nutrient profiling and environmental testing.
The TMIC platform is led by Dr. David Wishart (University of Alberta), Dr. Christoph Borchers (University of Victoria) and Dr. Liang Li (University of Alberta). This group delivered the nmrML predecessor that is amended and extended in the COSMOS Project.

[**Leibniz-Institute of Plant Biochemistry**](http://www.ipb-halle.de/en/)

The Institute of Plant Biochemistry (IPB) is a non-university research centre of the Leibniz Association (www.wgl.de), It investigates in a multidisciplinary style structure and function of natural products from plants and fungi, analyse interactions of plants with pathogenic and symbiotic microorganisms and study molecular interactions as part of complex biological processes. At the IPB, plant metabolomics has been an important area of research for many years.
The IPB leads the standards development workpackage within the COSMOS project.

[**The Metabolome Facility of Bordeaux Functional Genomics Centre**](http://www.cgfb.u-bordeaux2.fr/fr/metabolome)

The Metabolome Facility of Bordeaux Functional Genomics Centre (MFB) is mostly dedicated to plant and plant-derived products metabolomics. 
MFB is implicated in the [French Metabolomics and Fluxomics Network](https://www.bordeaux.inra.fr/ifr103/reseau_metabolome/)
and is a partner of [MetaboHUB](https://www6.inra.fr/metabohub) project aiming at the development of a French Metabolome Infrastructure. 
MFB provides expertise and tools along the complete metabolomics pipeline. In collaboration with the Bioinformatics Facility of Bordeaux, 
it has developed [MeRy-B](http://bit.ly/meryb) database for NMR plant metabolome data. Recent dry-lab developments of MFB concern 
1H-NMR spectra processing. MFB participates in the NMR group within the COSMOS project.

[...]

### Versioning

The versioning follow the [Major].[Minor].[Build], the version number is tracked inthe [VERSION](https://github.com/nmrML/nmrML/blob/master/VERSION) file in the root of the nmrML directory. Versioning is tracked using the taggin feature of git. All previous versions can be viewed [here](https://github.com/nmrML/nmrML/tags).

Follow these intructions to create release a tagged version: 

1. Commit changes in your working directory that you want in this release. It is a good idea to push these changes to GitHub before continuing. Make sure the changes you want in this release are merged with master.
2. Make sure the [HISTORY.md](https://github.com/nmrML/nmrML/blob/master/HISTORY.md) file is updated with the changes in this release. Follow the format in the file.
3. Bump the version, rebuild the docs, tag the release and push the release to Github with one of the following commands:
	* For a major release: `make release_major`
	* For a minor release: `make release_minor`	
	* For a build release: `make release_build`
4. Now you can push the release with: 
	git push --tags

## Directory Structure

* [docs](https://github.com/nmrML/nmrML/tree/master/docs) 
	* [SchemaDocumentation](https://github.com/nmrML/nmrML/tree/master/docs/SchemaDocumentation) - The docs generated from the schema and ontology files
* [examples](https://github.com/nmrML/nmrML/tree/master/examples)
    * [vendor](https://github.com/nmrML/nmrML/tree/master/examples/vendor) - Useful example files from other software and data formats
    * [nmrML](https://github.com/nmrML/nmrML/tree/master/examples/nmrML) - Example files for different use cases of nmrML
* [lib](https://github.com/nmrML/nmrML/tree/master/lib) - Scripts/code used for generating docs, etc.
* [mappings](https://github.com/nmrML/nmrML/tree/master/mappings) - Files that map variable names in other formats to variable names
in nmrML. Used by conversion software.
* [ontologies](https://github.com/nmrML/nmrML/tree/master/ontologies) - The ontology files describing the controlled vocabulary
* [xml-schemata](https://github.com/nmrML/nmrML/tree/master/xml-schemata) - The .xsd files describing the nmrML schema
* [tools](https://github.com/nmrML/nmrML/tree/master/tools) - Example software using nmrML

