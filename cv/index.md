---
layout: main
title: nmrCV
nav:
  specs: active
---

You can view the documentation and download current and past releases here:

<table class="table table-hover">
<thead>
<tr><th>nmvCV Version</th><th>Documenation</th><th>Download</th></tr>
</thead>
<tbody>
<tr><td>v1.0.rc1</td><td><a href="/cv/v1.0.rc1/doc">Browse Ontology</a>&nbsp;/&nbsp;<a href="/cv/jOWL/">jOWL Treeview</a></td><td><a href="/cv/v1.0.rc1/nmrCV.owl">nmrCV.owl</a></td></tr>
</tbody>
</table>



### nmrCV Overview

The nmrCV.owl ontology momentarily contains ~ 600 classes under nmr namespace. Around 2000 terms are imported from the units ontology and BFO top level ontology.

We choose the OWL Syntax  over the OBO format  as exchange syntax for the CV, as the OBO tools are instable, the OBO format is only established in the biology domain (lack of off-the-shelf development tools, OBO expressivity is not as formal as OWL-DL) and there are hence less resources to integrate with.

We maintain a pure taxonomy without use of axiomatic definitions. Multiple parenthood is however allowed, but needs to be maintained manually, as DL reasoning is not possible without DL axiomatisations.

#### Minimal metadata on a CV term

Representational Unit (RU) metadata is captured via standardized owl annotation properties drawn from imported artefacts like DC, SKOS and Information Artefact Ontology (IAO). Not all of our terms currently have natural language definitions as these are time-intensive. None has deeper provenance data explicitly annotated (there is only an implicit indication on from which predecessor CV a term came in the ID ranges). We try to avoid getting stuck in the meta-ether, and have been pragmatic about this.

A term batch submission table, i.e. for submitting new CV terms for inclusion into nmrCV, should have the following mandatory fields:

* term name (rdfs:label)-->skos:prefLabel,ideally adhering to labelling best practice descibed at  http://www.obofoundry.org/wiki/index.php/Naming

* term definition in natural language (IAO_0000115)-->skos:definition

* superclass (ideally a term from the current nmrCV.owl, or an own suggestion)

Optional fields (good to have) are:

* synonym (oboInOwl:hasExactSynonym)-->skos:altLabel

* term definition source-->dc:source

* dc:creator-->dc:author

* example of usage-->skos:example



Here is an example of the definition of the FID file term (NMR:1400119)

```xml
<owl:Class rdf:about="http://nmrML.org/nmrCV#NMR:1400119">
    <rdfs:label rdf:datatype="&xsd;string">FID file</rdfs:label>
    <rdfs:subClassOf rdf:resource="http://nmrML.org/nmrCV#NMR:1400267"/>
    <rdfs:comment rdf:datatype="&xsd;string">def: A reference to a file containing the raw FID.
synonym: FID file reference</rdfs:comment>
    <oboInOwl:hasExactSynonym>FID file reference</oboInOwl:hasExactSynonym>
</owl:Class>
```

#### Top Level Ontology usage

There are a few top and upper level ontologies (TLO) already established. From BFO, OBILight &
 BioTopLight (btl2), we choose BFO as top level ontology to guide our CV upper level development. The reason was that it is abundantly used within existing bioontology frameworks. At the moment only a few relations from unit ontology (UO) are used. We can at some later point still switch the TLO, as we do not use any axioms (It is only ~10 classes, so rebinning will be quick). It can be argued why we use a TLO when developing a CV not an Ontology. There has already been a case where the TLO provided modeling restrictions that allowed an automatic DL reasoner to discover CV modelling errors, e.g. https://github.com/nmrML/nmrML/issues/62

Nevertheless, at the moment we avoid any usage of object properties from the CV. E.g. for coding the vendor of an NMR instrument, we could have the following axiom in the CV:  ‘NMR Instrument’ hasVendor Vendor


Instead, we say in the mapping file that for an Instrument, the Name and Vendor has to be specified. In an equal way we amend CV information describing Software, e.g. the version info is stored in an XSD attribute.


