import sys, os, glob

# add the converter tools to the syspath
sys.path.append(os.path.join(os.path.dirname(__file__), '..'))

from pynmrml import io
from pynmrml import nmrML

#for filename in files:
input_file   = "sucrose.fid"
output_file = "sucrose.nmrML"

writer = io.factory.varian_converter(input_file)

# Add additional information to the document
doc = writer.doc()

# Add some contacts
contactList = nmrML.ContactListType()
contact = nmrML.ContactType(id= "ID004",fullname= "Michael Wilson",email= "michael.wilson@ualberta.ca" )
contactList.add_contact(contact)
doc.set_contactList(contactList)

# Add some software
software_list = nmrML.SoftwareListType()
software_list.add_software(nmrML.SoftwareType(
    id="SOFTWARE_1", cvRef="NMRCV", accession="NMR:1000277",
    name="VnmrJ software", version="2.2C"))
doc.set_softwareList(software_list)

# Add some instrument configurations
configList = doc.get_instrumentConfigurationList()
instconfig = nmrML.InstrumentConfigurationType(id="INST_CONFIG_1")
instconfig.add_cvTerm(
    nmrML.CVTermType(cvRef="NMRCV", accession="NMR:400234", name="Varian NMR instrument"))
instconfig.add_cvTerm(
    nmrML.CVTermType(cvRef="NMRCV", accession="??", name="Varian VNMRS 600 NMR spectrometer"))
instconfig.add_userParam(
    nmrML.UserParamType(name="5 mm inverse detection cryoprobe"))

writer.write(open("sucrose.nmrML","w"))
