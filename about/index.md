---
layout: main
title: home
nav:
  about: active
---

### Overview

nmrML is an open mark-up language for NMR data. It is currently under heavy development and is not yet ready for public use. The development of this standard is coordinated by Workpackage 2 of the [COSMOS - COordination Of Standards In MetabOlomicS Project](http://www.cosmos-fp7.eu). COSMOS is a global effort to enable free and open sharing of metabolomics data. Coordinated by Dr Christoph Steinbeck of the EMBL-European Bioinformatics Institute. COSMOS brings together European data providers to set and promote community standards that will make it easier to disseminate metabolomics data through life science e-infrastructures. This Coordination Action has been financed with €2 million by the European Commission's Seventh Framework Programme. The nmrML data standard will be approved by the Metabolomics standards Initiative and was derived from an earlier nmrML that was developed by the [Metabolomics Innovation Centre (TMIC)](http://www.metabolomicscentre.ca/).

### Why do we need a better NMR data standard? 

NMR is an important analytical method in metabolomics experiments. The instrument vendors (the dominant ones are Bruker, Varian and JEOL) typically provide the software to process the vendor specific data. Alternative data analysis software needs to put considerable efforts into reading and writing these specific vendor format, this applies both to commercial software such as NmrPipe, MestReNova (Mnova) or Chenomx NMR Suite, but even more so to community developed open source efforts such as Metaboquant  (Matlab-based), the Batman R package or rNMR. Currently existing standard data formats such as the JCAMP family have several drawbacks, especially in metabolomics applications. One problem is that there is no semantic validation of JCAMP-DX files, and that the JCAMP-DX website says even about their own test data  that “these files do not always comply 100% to the written standard but do represent files commonly found -- they do not claim to cover all possible allowed variations but are a good starting point to test your software.” This was the starting point that a new, well-specified NMR data standard was needed.

