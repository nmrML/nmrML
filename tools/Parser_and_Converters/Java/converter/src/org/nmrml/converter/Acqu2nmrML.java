/*
 * $Id: Converter.java,v 1.0.alpha Feb 2014 (C) INRA - DJ $
 * 
 * CC-BY 4.0
 */

package org.nmrml.converter;

import java.io.File;
import java.math.BigDecimal;
import java.math.BigInteger;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.channels.FileChannel;
import java.nio.file.Files;
import java.util.GregorianCalendar;

import java.util.*;
import java.lang.*;

import org.nmrml.parser.*;

import org.nmrml.schema.*;
import org.nmrml.cv.*;

import javax.xml.datatype.DatatypeConfigurationException;
import javax.xml.datatype.DatatypeFactory;
import javax.xml.datatype.XMLGregorianCalendar;

import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBElement;
import javax.xml.bind.JAXBException;
import javax.xml.bind.Marshaller;

public class Acqu2nmrML {

    private static final String nmrMLVersion = nmrMLversion.value;

    public static int ID_count;

    public static String getNewIdentifier ( ) { return String.format("ID%05d",++ID_count); }

    public static BigInteger getBigInteger (Integer entier) { return new BigInteger(entier.toString()); }

    private enum BinaryFile_Type { FID_FILE; }

    private Acqu acq = null;
    private CVLoader cvLoader = null;
    private SpectrometerMapper vendorMapper = null;

    private String  schemaLocation = null;
    private String  inputFolder = null;
    private String  vendorLabel = null;
    private String  acqIdentifier = null;
    private boolean ifbinarydata = false;
    private boolean compressed = false;

    public void setAcqu(Acqu acq) {
        this.acq = acq;
    }
    public void setVendorMapper(SpectrometerMapper vendorMapper) {
        this.vendorMapper = vendorMapper;
    }
    public void setCVLoader(CVLoader cvLoader) {
        this.cvLoader = cvLoader;
    }
    public void setInputFolder(String inputFolder) {
        this.inputFolder = inputFolder;
    }
    public void setSchemaLocation(String schemaLocation) {
        this.schemaLocation = schemaLocation;
    }
    public void setVendorLabel(String vendorLabel) {
        this.vendorLabel = vendorLabel;
    }
    public void setAcqIdentifier(String acqIdentifier) {
        this.acqIdentifier = acqIdentifier;
    }
    public boolean getIfbinarydata() {
        return ifbinarydata;
    }
    public void setIfbinarydata(boolean ifbinarydata) {
        this.ifbinarydata = ifbinarydata;
    }
    public void setCompressed(boolean compressed) {
        this.compressed=compressed;
    }
    public boolean isCompressed() {
        return compressed;
    }

    public Acqu2nmrML( ) { }

    public void Convert2nmrML( String outputFile ) {

        /* HashMap for Source Files */
        HashMap<String,SourceFileType> hSourceFileObj = new HashMap<String,SourceFileType>();
        HashMap<String,BinaryData> hBinaryDataObj = new HashMap<String,BinaryData>();

        try {
       /* NmrMLType object */
            ObjectFactory objFactory = new ObjectFactory();
            NmrMLType nmrMLtype = objFactory.createNmrMLType();

            nmrMLtype.setVersion(nmrMLVersion);

    /* ACQUISITION PARAMETERS */

       /* CV List : used as references for all CV in the document */
            int cvCount = 0;
            CVListType cvList = objFactory.createCVListType();
            for (String cvKey : cvLoader.getCVOntologySet()) {
                CVType cv = cvLoader.fetchCVType(cvKey);
                cvList.getCv().add(cv);
                cvCount = cvCount + 1;
            }
            nmrMLtype.setCvList(cvList);

       /* FileDescription */
            FileDescriptionType filedesc = objFactory.createFileDescriptionType();
            ParamGroupType paramgrp = objFactory.createParamGroupType();
            paramgrp.getCvParam().add(cvLoader.fetchCVParam("NMRCV","ONE_DIM_NMR"));
            filedesc.setFileContent(paramgrp);
            nmrMLtype.setFileDescription(filedesc);


       /* Contact List */
            ContactListType contactlist = objFactory.createContactListType();
            ContactType contact1 = objFactory.createContactType();
            contact1.setId(getNewIdentifier());
            contact1.setFullname(acq.getOwner()!=null ? acq.getOwner() : "undefined");
            contact1.setEmail(acq.getEmail()!=null ? acq.getEmail() : "undefined");
            contactlist.getContact().add(contact1);
            nmrMLtype.setContactList(contactlist);


       /* Contact Ref List */
            ContactRefListType contactRefList = objFactory.createContactRefListType();
            ContactRefType contactRef = objFactory.createContactRefType();
            contactRef.setRef(contact1);
            contactRefList.getContactRef().add(contactRef);

       /* AcquisitionParameter Ref List */
            AcquisitionParameterFileRefListType acquisitionParameterFileRefList = objFactory.createAcquisitionParameterFileRefListType();

       /* SourceFile List */
            int sourceFileCount = 0;
            SourceFileListType srcfilelist = objFactory.createSourceFileListType();
            for (String sourceName : vendorMapper.getSection("FILES").keySet()) {
               File sourceFile = null;
               if (vendorLabel.equals("JEOL")) {
                  sourceFile = new File(inputFolder);
               } else {
                  sourceFile = new File(inputFolder + vendorMapper.getTerm("FILES", sourceName));
               }
               if (sourceFile.isFile() & sourceFile.canRead()) {
                   SourceFileType srcfile = objFactory.createSourceFileType();
                   srcfile.setId(getNewIdentifier());
                   srcfile.setName(sourceFile.getName());
                   srcfile.setLocation(sourceFile.toURI().toString());
                   switch (vendorLabel) {
                       case "BRUKER":
                            srcfile.getCvParam().add(cvLoader.fetchCVParam("NMRCV","BRUKERFORMAT"));
                            break;
                       case "VARIAN":
                            srcfile.getCvParam().add(cvLoader.fetchCVParam("NMRCV","VARIANFORMAT"));
                            break;
                       case "JEOL":
                            srcfile.getCvParam().add(cvLoader.fetchCVParam("NMRCV","JEOLFORMAT"));
                            break;
                   }
                   srcfile.getCvParam().add(cvLoader.fetchCVParam("NMRCV",sourceName));
                   hSourceFileObj.put(sourceName, srcfile);
                   boolean doBinData = false;
                   for(BinaryFile_Type choice:BinaryFile_Type.values()) if (choice.name().equals(sourceName)) doBinData = true;
                   if (doBinData) {
                       boolean bComplexData = false;
                       if ( BinaryFile_Type.FID_FILE.name().equals(sourceName) ) {
                           bComplexData = true;
                       }
                       BinaryData binaryData = new BinaryData(sourceFile, acq, bComplexData, this.isCompressed());
                       hBinaryDataObj.put(sourceName, binaryData);
                       if (binaryData.isExists()) { srcfile.setSha1(binaryData.getSha1()); }
                   }
                   AcquisitionParameterFileRefType acquisitionParameterFileRef = objFactory.createAcquisitionParameterFileRefType();
                   acquisitionParameterFileRef.setRef(srcfile);
                   acquisitionParameterFileRefList.getAcquisitionParameterFileRef().add(acquisitionParameterFileRef);
                   srcfilelist.getSourceFile().add(srcfile);
                   sourceFileCount = sourceFileCount + 1;
               }
            }
            nmrMLtype.setSourceFileList(srcfilelist);


       /* Software List */
            SoftwareListType softwareList = objFactory.createSoftwareListType();
            SoftwareType software1 = objFactory.createSoftwareType();
            CVTermType softterm1 = cvLoader.fetchCVTerm("NMRCV",acq.getSoftware());
            software1.setCvRef(softterm1.getCvRef());
            software1.setAccession(softterm1.getAccession());
            software1.setId(getNewIdentifier());
            software1.setName(softterm1.getName());
            software1.setVersion(acq.getSoftVersion());
            softwareList.getSoftware().add(software1);
            nmrMLtype.setSoftwareList(softwareList);

       /* Software Ref List */
            SoftwareRefListType softwareRefList = objFactory.createSoftwareRefListType();
            SoftwareRefType softref1 = objFactory.createSoftwareRefType();
            softref1.setRef(software1);
            softwareRefList.getSoftwareRef().add(softref1);

       /* InstrumentConfiguration List */
            InstrumentConfigurationListType instrumentConfList = objFactory.createInstrumentConfigurationListType();
            InstrumentConfigurationType instrumentConf = objFactory.createInstrumentConfigurationType();
            instrumentConf.getSoftwareRef().add(softref1);
            instrumentConf.setId(getNewIdentifier());
            instrumentConf.getCvParam().add(cvLoader.fetchCVParam("NMRCV",vendorLabel));
            if (acq.getInstrumentName()!=null) {
               UserParamType instrumentName = objFactory.createUserParamType();
               instrumentName.setName("Instrument Name");
               instrumentName.setValue(acq.getInstrumentName());
               instrumentConf.getUserParam().add(instrumentName);
            }
            UserParamType probeParam = objFactory.createUserParamType();
            probeParam.setName("ProbeHead");
            probeParam.setValue(acq.getProbehead());
            instrumentConf.getUserParam().add(probeParam);
            instrumentConfList.getInstrumentConfiguration().add(instrumentConf);
            nmrMLtype.setInstrumentConfigurationList(instrumentConfList);

       /* Acquition */

            /* CV Units */
            CVTermType cvUnitNone = cvLoader.fetchCVTerm("UO","NONE");
            CVTermType cvUnitPpm = cvLoader.fetchCVTerm("UO","PPM");
            CVTermType cvUnitHz = cvLoader.fetchCVTerm("UO","HERTZ");
            CVTermType cvUnitmHz = cvLoader.fetchCVTerm("UO","MEGAHERTZ");
            CVTermType cvUnitT = cvLoader.fetchCVTerm("UO","TESLA");
            CVTermType cvUnitK = cvLoader.fetchCVTerm("UO","KELVIN");
            CVTermType cvUnitDeg = cvLoader.fetchCVTerm("UO","DEGREE");
            CVTermType cvUnitSec = cvLoader.fetchCVTerm("UO","SECOND");
            CVTermType cvUnitmSec = cvLoader.fetchCVTerm("UO","MICROSECOND");

            /* AcquisitionParameterSet1D object */
            AcquisitionParameterSet1DType acqparam = objFactory.createAcquisitionParameterSet1DType();
            acqparam.setNumberOfScans(acq.getNumberOfScans());
            acqparam.setNumberOfSteadyStateScans(acq.getNumberOfSteadyStateScans());

            /* sample container */
            acqparam.setSampleContainer(cvLoader.fetchCVTerm("NMRCV","TUBE"));

            /* AcquisitionParameterFile Ref List, Software Ref List, Contact Ref List */
            acqparam.setAcquisitionParameterRefList(acquisitionParameterFileRefList);
            acqparam.setSoftwareRef(softref1);
            acqparam.setContactRefList(contactRefList);

            /* sample temperature */
            ValueWithUnitType  temperature = objFactory.createValueWithUnitType();
            temperature.setValue(String.format("%6.2f",acq.getTemperature()).trim());
            temperature.setUnitCvRef(cvUnitK.getCvRef());
            temperature.setUnitAccession(cvUnitK.getAccession());
            temperature.setUnitName(cvUnitK.getName());
            acqparam.setSampleAcquisitionTemperature(temperature);

            /* Relaxation Delay */
            ValueWithUnitType  relaxationDelay = objFactory.createValueWithUnitType();
            relaxationDelay.setValue(String.format("%18.12f",acq.getRelaxationDelay()).trim());
            relaxationDelay.setUnitCvRef(cvUnitSec.getCvRef());
            relaxationDelay.setUnitAccession(cvUnitSec.getAccession());
            relaxationDelay.setUnitName(cvUnitSec.getName());
            acqparam.setRelaxationDelay(relaxationDelay);

            /* Spinning Rate */
            ValueWithUnitType  spinningRate = objFactory.createValueWithUnitType();
            spinningRate.setValue(String.format("%d",acq.getSpiningRate()).trim());
            spinningRate.setUnitCvRef(cvUnitNone.getCvRef());
            spinningRate.setUnitAccession(cvUnitNone.getAccession());
            spinningRate.setUnitName(cvUnitNone.getName());
            acqparam.setSpinningRate(spinningRate);

            /* Group Delay */
            ValueWithUnitType  groupDelay = objFactory.createValueWithUnitType();
            groupDelay.setValue(String.format("%8.4f",acq.getDspGroupDelay()).trim());
            groupDelay.setUnitCvRef(cvUnitNone.getCvRef());
            groupDelay.setUnitAccession(cvUnitNone.getAccession());
            groupDelay.setUnitName(cvUnitNone.getName());
            acqparam.setGroupDelay(groupDelay);

            /* PulseSequenceType object */
            PulseSequenceType pulse_sequence = objFactory.createPulseSequenceType();
            UserParamType pulseParam = objFactory.createUserParamType();
            pulseParam.setName("Pulse Program");
            pulseParam.setValue(acq.getPulseProgram());
            pulse_sequence.getUserParam().add(pulseParam);
            acqparam.setPulseSequence(pulse_sequence);

            /* ShapedPulseFile object */
            if ( hSourceFileObj.get("PULSEPROGRAM_FILE") != null ) {
                SourceFileRefType pulseFileRef = objFactory.createSourceFileRefType();
                pulseFileRef.setRef(hSourceFileObj.get("PULSEPROGRAM_FILE"));
                acqparam.setShapedPulseFile(pulseFileRef);
            }
           /* DirectDimensionParameterSet object */
            AcquisitionDimensionParameterSetType acqdimparam = objFactory.createAcquisitionDimensionParameterSetType();
            acqdimparam.setNumberOfDataPoints(getBigInteger(acq.getAquiredPoints()));
            acqdimparam.setAcquisitionNucleus(cvLoader.fetchCVTerm("CHEBI",acq.getObservedNucleus()));
            // Spectral Width (Hz)
            ValueWithUnitType  SweepWidth = objFactory.createValueWithUnitType();
            SweepWidth.setValue(String.format("%18.12f",acq.getSpectralWidthHz()).trim());

            SweepWidth.setUnitCvRef(cvUnitHz.getCvRef());
            SweepWidth.setUnitAccession(cvUnitHz.getAccession());
            SweepWidth.setUnitName(cvUnitHz.getName());
            acqdimparam.setSweepWidth(SweepWidth);
            // Irradiation Frequency (Hz)
            ValueWithUnitType  IrradiationFrequency = objFactory.createValueWithUnitType();
            IrradiationFrequency.setValue(String.format("%18.12f",acq.getTransmiterFreq()).trim());
            IrradiationFrequency.setUnitCvRef(cvUnitmHz.getCvRef());
            IrradiationFrequency.setUnitAccession(cvUnitmHz.getAccession());
            IrradiationFrequency.setUnitName(cvUnitmHz.getName());
            acqdimparam.setIrradiationFrequency(IrradiationFrequency);
            // setEffectiveExcitationField (Hz)
            ValueWithUnitType  effectiveExcitationField = objFactory.createValueWithUnitType();
            effectiveExcitationField.setValue(String.format("%18.12f",acq.getSpectralFrequency()).trim());
            effectiveExcitationField.setUnitCvRef(cvUnitmHz.getCvRef());
            effectiveExcitationField.setUnitAccession(cvUnitmHz.getAccession());
            effectiveExcitationField.setUnitName(cvUnitmHz.getName());
            acqdimparam.setEffectiveExcitationField(effectiveExcitationField);
            /* Pulse Width */
            ValueWithUnitType  pulseWidth = objFactory.createValueWithUnitType();
            pulseWidth.setValue(String.format("%18.12f",acq.getPulseWidth()).trim());
            pulseWidth.setUnitCvRef(cvUnitmSec.getCvRef());
            pulseWidth.setUnitAccession(cvUnitmSec.getAccession());
            pulseWidth.setUnitName(cvUnitmSec.getName());
            acqdimparam.setPulseWidth(pulseWidth);
            /* decouplingNucleus */
            CVTermType cvDecoupledNucleus = null;
            if ( acq.getDecoupledNucleus().equals("off") ) {
                acqdimparam.setDecoupled(false);
                cvDecoupledNucleus = cvLoader.fetchCVTerm("NMRCV","OFF_DECOUPLE");
            }
            else {
                acqdimparam.setDecoupled(true);
                cvDecoupledNucleus = cvLoader.fetchCVTerm("CHEBI",acq.getDecoupledNucleus());
            }
            acqdimparam.setDecouplingNucleus(cvDecoupledNucleus);
            /* TODO: samplingStrategy */
            acqdimparam.setSamplingStrategy(cvLoader.fetchCVTerm("NMRCV","UNIFORM_SAMPLING"));

            acqparam.setDirectDimensionParameterSet(acqdimparam);

            /* Acquisition1D object */
            Acquisition1DType acq1Dtype = objFactory.createAcquisition1DType();
            acq1Dtype.setAcquisitionParameterSet(acqparam);
            if ( acqIdentifier !=null ) {
                acq1Dtype.setId(acqIdentifier);
                // acq1Dtype.setName("");
            }

            /* fidData object */
            if (hBinaryDataObj.containsKey("FID_FILE") && hBinaryDataObj.get("FID_FILE").isExists()) {
                BinaryDataArrayType fidData = objFactory.createBinaryDataArrayType();
                fidData.setEncodedLength(hBinaryDataObj.get("FID_FILE").getEncodedLength());
                fidData.setByteFormat(hBinaryDataObj.get("FID_FILE").getByteFormat());
                fidData.setCompressed(hBinaryDataObj.get("FID_FILE").isCompressed());
                if(this.getIfbinarydata()) {
                   fidData.setValue(hBinaryDataObj.get("FID_FILE").getData());
                }
                acq1Dtype.setFidData(fidData);
            }

            /* Acquisition oject */
            AcquisitionType acqtype = objFactory.createAcquisitionType();
            acqtype.setAcquisition1D(acq1Dtype);
            nmrMLtype.setAcquisition(acqtype);

       /* Generate XML */
            JAXBElement<NmrMLType> nmrML = (JAXBElement<NmrMLType>) objFactory.createNmrML(nmrMLtype);

            // create a JAXBContext capable of handling classes generated into the org.nmrml.schema package
            JAXBContext jc = JAXBContext.newInstance(NmrMLType.class);

            // create a Marshaller and marshal to a file / stdout
            Marshaller m = jc.createMarshaller();
            m.setProperty( Marshaller.JAXB_FORMATTED_OUTPUT, Boolean.TRUE );
            m.setProperty(Marshaller.JAXB_SCHEMA_LOCATION, schemaLocation);
            if ( outputFile == null) {
               m.marshal( nmrML, System.out );
            } else {
               m.marshal( nmrML, new File(outputFile) );
            }

        } catch( JAXBException je ) {
            je.printStackTrace();
        } catch( Exception e ) {
            e.printStackTrace();
        }

    }

}
