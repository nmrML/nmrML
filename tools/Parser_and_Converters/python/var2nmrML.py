#!/usr/bin/env python
import sys
import nmrglue
#from lxml import etree

#
# This code is a work in progress, but will eventually be used to create
# a python library for outputting nmrML
# 
# As a preliminary step, we are just printing out the values required to 
# build an nmrML instance so that we can piece together the mappings from
# Varian to nmrML.
#
# We are using nmrglue to load and parse the Varian files as it should allow
# us a standard way to parse NMR input files. (https://code.google.com/p/nmrglue/)
# 
# The general idea is to grab the values we need, and fill an nmrML data object
# with them, then convert the data object into nmrML. This will allow us to 
# easily re-use the nmrML output code and easily create new parsers.
#
#
# To use this code:
#
#   python tools/Parser_and_Converters/python/var2nmrML.py filename

filename = str(sys.argv[1])

# Load the FID file with nmglue 
dic,data = nmrglue.varian.read(filename)
# nmrglue parses the procpar into a dictionary allowing us easy access to
# all the parameters
procpar  = dic["procpar"]

# Print out all the parameters in the dictionary
# print(procpar.keys())


# Using the guide at 

print( "number of scans",  procpar["nt"]['values'][0] )
print( "number of steady state scans",  procpar["ss"]['values'][0] )

print("relaxation delay", procpar["d1"]['values'][0] )
print("spectral width",  procpar["sw"]['values'][0] )
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

print("decoupler frequency", procpar["dfrq"]["values"][0]) # MHz

# decoupler mode; sets when the decoupler is turned on
#   dm = nnn means decoupler is set to no for the whole experiment; 
#   dm = 'nny' means decoupler is on during timer period 3, usually the
#     acquisition time;
#   dm = 'ynn' means decoupler is on during time period 1, normally the d1 
#     relaxation delay
print("decoupler mode", procpar["dm"]["values"][0]) 
print("decoupler modulation mode", procpar["dmm"]["values"][0]) 
print("decoupler power", procpar["dpwr"]["values"][0]) 
print("decoupler modulation frequency", procpar["dmf"]["values"][0]) 
print("2nd decoupler nucleus frequency", procpar["dfrq2"]["values"][0]) 
# Then need: dmf2, dpwr2, dmm2, dm2 

print("magnetic field strength (guass)", procpar["B0"]["values"][0]) 


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
