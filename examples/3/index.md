---
layout: main
title: Examples
nav:
  examples: active
---

# Example 3: An HMDB reference spectrum for a single identified molecule (2-Ketobutyric acid), created with nmrML-Assign

<a href="/examples/3/HMDB00005.nmrML">Download nmrML file</a> | <a href="/examples/3/HMDB00005.fid.zip">Download original FID</a>

This spectrum is a reference spectrum for 2-Ketobutyric acid (HMDB metabolite HMDB00005). Keep in mind that this is a synonym to '2-oxobutanoic acid', as shown in Fig. 2 of the nmrML paper, where a graphical Spectrum visualization with assignment for this reference compound is depicted. The atom assignments have been done using  <a href="http://nmrml.bayesil.ca" >nmrML-Assign</a>, which is an interactive tool for creating reference spectra and generating nmrML-formatted files. nmrML-Assign first processes the uploaded fid with Bayesil. The user also provides a structure for the compound of interest. Atom assignments to spectral clusters/peaks of interest can be made using this structure.

### Reference
<a href="http://www.hmdb.ca/spectra/nmr_one_d/1024">HMDB00005</a>

### nmrML
```xml
{% include examples/3.nmrML %}
```
