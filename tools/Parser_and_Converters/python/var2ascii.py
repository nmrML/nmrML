import nmrglue

dic,data = nmrglue.varian.read("sucrosesample_varian/")
for row in data:
	print row.real,"\t",row.imag

