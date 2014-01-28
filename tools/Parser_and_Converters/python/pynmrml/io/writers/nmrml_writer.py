import sys, os
import nmrglue
import hashlib

import numpy as np

from ...nmrML import *

#uoCV  = CvFactory.uo()
#nmrCV = CvFactory.nmrCV()

class nmrmlWriter(object):

    def __init__(self,reader_class,infile):
        self.reader_class = reader_class
        self.infile       = infile
        self.reader       = reader_class(infile)
        self.instance     = self.build_instance()

        # Default is no namespace
        self.namespace    = ""

    # building this as a script then moving functionality into the
    # class definitions, and making the parser oo

    #TODO methods to move:

    def get_sha1(self,filename):
        return hashlib.sha1(open(filename).read()).hexdigest()

    def write(self,out):
        # Have to set name_ to be the name the root element...
        # not sure why the default is the name of the element's type. Doesn't seem right.
        self.instance.export(out, 0, self.namespace, name_ = 'nmrML',
            namespacedef_ = 'xmlns="http://nmrml.org/schema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://nmrml.org/schema ../../../xml-schemata/nmrML.xsd"')

    def doc(self):
      return self.instance

    def build_instance(self):
        instance = nmrMLType(version="1.0.0")

        # Add the CVs
        cvList = CVListType(count="2")

        cv = CVType(
            id       = "NMRCV",
            fullName = "nmrML Controlled Vocabulary",
            URI      = "http://www.nmrml.org/nmrml-cv.0.0.1.owl",
            version  = "0.0.1" )
        cvList.add_cv(cv)

        cv = CVType(
            id       = "UO",
            fullName = "Unit Ontology",
            URI      = "http://unit-ontology.googlecode.com/svn/trunk/uo.owl/",
            version  = "3.2.0" )
        cvList.add_cv(cv)

        instance.set_cvList(cvList)

        # Add fileDescription

        # Add contacts
        contactList = ContactListType()

        #contact = ContactType(
        #    id       = "ID004",
        #    fullname = "Michael Wilson",
        #    email    = "michael.wilson@ualberta.ca" )
        #contactList.add_contact(contact)

        instance.set_contactList(contactList)

        # Add sourceFileList

        # for Varian 1D NMR
        source_file_list = SourceFileListType(count="2")

        # TODO make this into a method
        #<cvTerm cvRef="NMRCV" accession="NMR:1400119" name="FID file"/>
        #    <cvTerm cvRef="NMRCV" accession="NMR:1400297" name="Varian VNMR Format"/>

        for i,filename in enumerate([ "procpar","fid" ]):
          paramfile = os.path.join(self.infile,filename)
          fileid = "SOURCE_FILE_" + str(i)
          source_file = SourceFileType(id=fileid, name=filename, location="file://"+paramfile)

          source_file.set_sha1(self.get_sha1(paramfile))
          source_file.add_cvTerm( CVTermType( cvRef="NMRCV",
              accession="NMR:1400297", name="Varian VNMR Format"))

          if filename == "fid":
              source_file.add_cvTerm(CVTermType(cvRef="NMRCV",
                  accession="NMR:1400119", name="FID file" ))
          elif filename == "procpar":
              source_file.add_cvTerm( CVTermType(cvRef="NMRCV",
                  accession="NMR:1002006", name="acquisition parameter file"))

          source_file_list.add_sourceFile(source_file)

        instance.set_sourceFileList(source_file_list)


        # Add instrumentConfigurationList


        # Add acquisition
        acquisition_1D = Acquisition1DType()
        param_set = AcquisitionParameterSet1DType(
            numberOfScans = self.reader.number_of_scans(),
            numberOfSteadyStateScans = self.reader.number_of_steady_state_scans() )

        param_set.set_sampleAcquisitionTemperature( ValueWithUnitType(
          value = self.reader.sample_acquisition_temperature(),
          unitName = "kelvin", unitAccession = "UO:0000012", unitCvRef = "UO" ))

        param_set.set_spinningRate( ValueWithUnitType(
            value= self.reader.spinning_rate(),
            unitName="hertz", unitAccession="UO:0000106", unitCvRef="UO" ))

        param_set.set_relaxationDelay( ValueWithUnitType(
          value= self.reader.relaxation_delay(),
          unitName="second", unitCvRef="UO", unitAccession="UO:0000010" ))

        ## TODO how do we get this value??
        ## need to analyze the input dir to find if any relevant files exist
        pulse_sequence = PulseSequenceType()
        #pulse_sequence.add_cvTerm( CVTermType( name="??", accession="??", cvRef="NMRCV" ))

        ps_file_list = pulseSequenceFileRefListType()
        #ps_file_list.add_pulseSequenceFileRef( SourceFileRefType(ref="PULSE_SEQ_SRC") )
        #pulse_sequence.set_pulseSequenceFileRefList(ps_file_list)
        param_set.set_pulseSequence(pulse_sequence)

        dd_param_set = AcquisitionDimensionParameterSetType(
            decoupled= self.reader.decoupling_method(),
            numberOfDataPoints=self.reader.number_of_data_points() )
        dd_param_set.set_decoupled(False)

        # TODO varian gives H1 need to get correct CV term from this
        # and actually set it based on the procpar`
        #dd_param_set.set_acquisitionNucleus(
        #    CVTermType(name=self.reader.acquisition_nucleus(), cvRef="NMRCV", accession="NMR:1400151"))
        dd_param_set.set_acquisitionNucleus(
            CVTermType(name="1H", cvRef="NMRCV", accession="NMR:1400151"))

        dd_param_set.set_gammaB1PulseFieldStrength(ValueWithUnitType(
            value=self.reader.gamma_b1_pulse_field_strength(), 
            unitName="tesla", unitCvRef="UO", unitAccession="UO:0000228"))

        dd_param_set.set_irradiationFrequency(ValueWithUnitType(
            value=self.reader.irradiation_frequency(),
            unitName="hertz", unitCvRef="UO", unitAccession="UO:0000106" ))

        # TODO how to get??
        #dd_param_set.set_decouplingMethod(CVTermType(name=self.reader.decoupling_method(),
        #  accession="NMR:1000046", cvRef="NMRCV"))

        param_set.set_DirectDimensionParameterSet(dd_param_set)

        acquisition_1D.set_acquisitionParameterSet(param_set)

        acquisition_1D.set_fidData(
            BinaryDataArrayType(
                #encodedLength=0,
                encodedLength=self.reader.fid_data_length(),
                compressed="true",
                byteFormat="Complex128",
                #valueOf_="",
                valueOf_=self.reader.fid_data()
            )
        )


        # add contacts + acquisitionParameterFileRefList + sampleContainer

        acquisition = AcquisitionType(acquisition1D=acquisition_1D)
        instance.set_acquisition(acquisition)

        return instance


