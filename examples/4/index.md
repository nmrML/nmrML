---
layout: main
title: Examples
nav:
  examples: active
---

# 1-Methylhistidine reference spectrum

<a href="/examples/4/HMDB00001.nmrML">Download nmrML file</a>

This spectrum is a a reference spectrum for 1-Methylhistidine (HMDB metabolite HMDB00001). The atom assignments have been done using  <a href="http://nmrml.bayesil.ca" >nmrML-Assign</a>, which is an interactive tool for creating reference spectra and generating nmrML-formatted files. nmrML-Assign first runs Bayesil on the uploaded fid. The user also provides a structure for the compound of interest. Atom assignments are made using this structure by the user to spectral clusters/peaks of interest.

### Reference
<a href="http://www.hmdb.ca/spectra/nmr_one_d/1022">HMDB00001</a> - Viewer

### nmrML
```xml
{% include examples/4.nmrML %}
```