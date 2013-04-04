import nmrglue
from lxml import etree

dic,data = nmrglue.varian.read("sucrosesample_varian/")

root = etree.Element("nmrML")

fid = etree.SubElement(root,"fid")
for row in data:
	point = etree.SubElement(fid,"point")
	real  = etree.SubElement(point, "real")
	real.text =  str(row.real)
	imag  = etree.SubElement(point,"imaginary")
	imag.text = str(row.imag)

print(etree.tostring(root,pretty_print=True))
