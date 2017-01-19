---
layout: main
title: Examples
nav:
  examples: active
---

# Example 5: Human urine sample spectra from the MTBLS1 study

<a href="/examples/5/MTBLS1.zip">Download nmrML files</a>

Bayesil quantification of complex bodyfluid sample and nmrML results (MTBLS1). The spectra of human urine samples acquired on a Bruker DRX700 NMR spectrometer using a 5 mm TXI ATMA probe at a proton frequency of 700.1 MHz and ambient temperature of 27 °C. A 1D NOESY presaturation pulse sequence was used to analyze the urine samples. For each sample 128 transients were collected into 64k data points using a spectral width of 14.005 kHz (20 ppm) and an acquisition time of 2.34 s per FID. Samples are from both control and T2D patients. More details about the experiment and sample conditions can be found in the MTBLS1 data description in <a href="http://www.ebi.ac.uk/metabolights/MTBLS1">metaboLights</a>.

### Reference
Salek RM, Maguire ML, Bentley E, Rubtsov DV, et al. (2007) A metabolomic comparison of urinary changes in type 2 diabetes in mouse, rat, and human. Physiological Genomics, 29(2):99-108 (PMID:17190852)

### sample nmrML
```xml
{% include examples/5.nmrML %}
```
