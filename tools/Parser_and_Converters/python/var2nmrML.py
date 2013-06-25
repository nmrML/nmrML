#!/usr/bin/env python
import sys
import nmrglue
#from lxml import etree

filename = str(sys.argv[1])

dic,data = nmrglue.varian.read(filename)
procpar  = dic["procpar"]

#print(procpar.keys())
print( "number of scans",  procpar["nt"]['values'][0] )

print( "number of steady state scans",  procpar["ss"]['values'][0] )

print( "relaxation delay", procpar["d1"]['values'][0] )
print( "spectral width",  procpar["sw"]['values'][0] )
print("transmitter offset", procpar["tof"]["values"][0])
print("transmitter power", procpar["tpwr"]["values"][0])
print("solvent parameter", procpar["solvent"]["values"][0])
print("acquisition time", procpar["at"]["values"][0])
print("number of data points", procpar["np"]["values"][0])
print("nucleus being detected", procpar["tn"]["values"][0])
# in MHz
print("spectrometer frequency", procpar["sfrq"]["values"][0]) 

# TODO may not work without vttype, look into this more
print("probe/sample temperature", procpar["temp"]["values"][0]) 

print("spin rate", procpar["spin"]["values"][0]) 
print("decoupler offset", procpar["dof"]["values"][0]) 
print("decoupler nucleus", procpar["dn"]["values"][0]) 
# In MHz:
print("decoupler frequency", procpar["dfrq"]["values"][0]) 
# decoupler mode; sets when the decoupler is turned on
#for example, dm = nnn means 
# decoupler is set to no for the whole experiment; dm = 'nny' means decoupler is on during 
# timer period 3, usually the acquisition time; dm = 'ynn' means decoupler is on during 
# time period 1, normally the d1 relaxation delay
print("decoupler mode", procpar["dm"]["values"][0]) 
print("decoupler modulation mode", procpar["dmm"]["values"][0]) 
print("decoupler power", procpar["dpwr"]["values"][0]) 
print("decoupler modulation frequency", procpar["dmf"]["values"][0]) 
print("2nd decoupler nucleus frequency", procpar["dfrq2"]["values"][0]) 
# Then need: dmf2, dpwr2, dmm2, dm2 

# values we should consider including?
# gain


exit()

root = etree.Element("nmrML")

fid = etree.SubElement(root,"fid")
for row in data:
	point = etree.SubElement(fid,"point")
	real  = etree.SubElement(point, "real")
	real.text =  str(row.real)
	imag  = etree.SubElement(point,"imaginary")
	imag.text = str(row.imag)

print(etree.tostring(root,pretty_print=True))
