/*
 * $Id: Converter.java,v 1.0.alpha Feb 2014 (C) INRA - DJ $
 * 
 * CC-BY 4.0
 */

package org.nmrml.converter;

//import java.io.File;
import java.io.*;
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
import javax.xml.bind.Unmarshaller;

public class Proc2nmrML {

    public static int ID_count=100;

    public static String getNewIdentifier ( ) { return String.format("ID%05d",++ID_count); }

    public static BigInteger getBigInteger (Integer entier) { return new BigInteger(entier.toString()); }

    private enum BinaryFile_Type { REAL_DATA_FILE; }

    private Proc proc = null;
    private CVLoader cvLoader = null;
    private SpectrometerMapper vendorMapper = null;

    private String  schemaLocation = null;
    private String  inputFile = null;
    private String  procFolder = null;
    private String  vendorLabel = null;
    private boolean ifbinarydata = false;
    private boolean compressed = false;

    public void setProc(Proc proc) {
        this.proc = proc;
    }
    public void setVendorMapper(SpectrometerMapper vendorMapper) {
        this.vendorMapper = vendorMapper;
    }
    public void setCVLoader(CVLoader cvLoader) {
        this.cvLoader = cvLoader;
    }
    public void setInputFile(String inputFile) {
        this.inputFile = inputFile;
    }
    public void setProcFolder(String procFolder) {
        this.procFolder = procFolder;
    }
    public void setSchemaLocation(String schemaLocation) {
        this.schemaLocation = schemaLocation;
    }
    public void setVendorLabel(String vendorLabel) {
        this.vendorLabel = vendorLabel;
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

    public Proc2nmrML( ) { }

    public void Add2nmrML( String outputFile ) {

        /* HashMap for Source Files */
        HashMap<String,SourceFileType> hSourceFileObj = new HashMap<String,SourceFileType>();
        HashMap<String,BinaryData> hBinaryDataObj = new HashMap<String,BinaryData>();
        HashMap<String,ReferenceableParamGroupType> hRefParamGroupObj = new HashMap<String,ReferenceableParamGroupType>();

        try {
        /* Read nmrML file */
            JAXBContext injc = JAXBContext.newInstance(NmrMLType.class);
            Unmarshaller unmarshaller = injc.createUnmarshaller();
            NmrMLType nmrMLtype = null;
            if (inputFile == null) {
                 nmrMLtype = (NmrMLType) unmarshaller.unmarshal(new InputStreamReader(System.in));
            } else {
                 nmrMLtype = (NmrMLType) unmarshaller.unmarshal(new File(inputFile));
            }
            ObjectFactory objFactory = new ObjectFactory();


        /* Read the Spectrum List - Adjust the range for the identifiers */
            int procno=1;
            SpectrumListType spectrumList = null;
            if ( nmrMLtype.getSpectrumList() != null ) {
               spectrumList = nmrMLtype.getSpectrumList();
               procno=spectrumList.getSpectrum1D().size() + 1;
               ID_count *= procno;
            } else {
               spectrumList = objFactory.createSpectrumListType();
            }

        /* CV Units */
            CVTermType cvUnitNone = cvLoader.fetchCVTerm("UO","NONE");
            CVTermType cvUnitPpm  = cvLoader.fetchCVTerm("UO","PPM");
            CVTermType cvUnitHz   = cvLoader.fetchCVTerm("UO","HERTZ");
            CVTermType cvUnitmHz  = cvLoader.fetchCVTerm("UO","MEGAHERTZ");
            CVTermType cvUnitT    = cvLoader.fetchCVTerm("UO","TESLA");
            CVTermType cvUnitK    = cvLoader.fetchCVTerm("UO","KELVIN");
            CVTermType cvUnitDeg  = cvLoader.fetchCVTerm("UO","DEGREE");
            CVTermType cvUnitSec  = cvLoader.fetchCVTerm("UO","SECOND");
            CVTermType cvUnitmSec = cvLoader.fetchCVTerm("UO","MICROSECOND");
            CVTermType cvUnitCount = cvLoader.fetchCVTerm("UO","COUNT");

            boolean bstop=false;

       /* ProcessingParameter Ref List */
            ProcessingParameterFileRefListType processingParameterFileRefList = objFactory.createProcessingParameterFileRefListType();

        /* SourceFile List */
            int sourceFileCount = 0;
            SourceFileListType srcfilelist = nmrMLtype.getSourceFileList();
            for (String sourceName : vendorMapper.getSection("FILES").keySet()) {
               File sourceFile = new File(procFolder + vendorMapper.getTerm("FILES", sourceName));
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
                   }
                   srcfile.getCvParam().add(cvLoader.fetchCVParam("NMRCV",sourceName));
                   hSourceFileObj.put(sourceName, srcfile);
                   boolean doBinData = false;
                   for(BinaryFile_Type choice:BinaryFile_Type.values()) if (choice.name().equals(sourceName)) doBinData = true;
                   if (doBinData) {
                       Acqu acq = new Acqu(Acqu.Spectrometer.BRUKER);
                       acq.setByteOrder(proc.getByteOrder());
                       acq.setBiteSyze(proc.getBiteSyze());
                       BinaryData binaryData = new BinaryData(sourceFile, acq, false, this.isCompressed());
                       proc.setByteOrder(acq.getByteOrder());
                       proc.setBiteSyze(acq.getBiteSyze());
                       hBinaryDataObj.put(sourceName, binaryData);
                       if (binaryData.isExists()) { srcfile.setSha1(binaryData.getSha1()); }
                   }
                   ProcessingParameterFileRefType processingParameterFileRef = objFactory.createProcessingParameterFileRefType();
                   processingParameterFileRef.setRef(srcfile);
                   processingParameterFileRefList.getProcessingParameterFileRef().add(processingParameterFileRef);
                   srcfilelist.getSourceFile().add(srcfile);
                   sourceFileCount = sourceFileCount + 1;
               }
            }
            nmrMLtype.setSourceFileList(srcfilelist);

       /* Contact List */
            ContactListType contactlist = (nmrMLtype.getContactList().getContact().size()>0) ? 
                                           nmrMLtype.getContactList() : objFactory.createContactListType();
            ContactType contact1 = objFactory.createContactType();
            if (proc.getUser()!=null) {
                contact1.setId(getNewIdentifier());
                contact1.setFullname(proc.getUser());
                contact1.setEmail(proc.getEmail());
                for(int i=0; i<contactlist.getContact().size(); i++){
                    ContactType contact = contactlist.getContact().get(i);
                    if (contact.getFullname().equals(contact1.getFullname()) && contact.getEmail().equals(contact1.getEmail()) ) {
                        contact1=contact;
                        bstop=true;
                        break;
                    }
                }
                if (!bstop) {
                   contactlist.getContact().add(contact1);
                   nmrMLtype.setContactList(contactlist);
                }
            } else {
                contact1 = contactlist.getContact().get(0);
            }

       /* Contact Ref List */
            ContactRefListType contactRefList = objFactory.createContactRefListType();
            ContactRefType contactRef = objFactory.createContactRefType();
            contactRef.setRef(contact1);
            contactRefList.getContactRef().add(contactRef);

        /* Software List */
            SoftwareType software1 = objFactory.createSoftwareType();
            CVTermType softterm1 = cvLoader.fetchCVTerm("NMRCV",proc.getSoftware());
            software1.setCvRef(softterm1.getCvRef());
            software1.setAccession(softterm1.getAccession());
            software1.setId(getNewIdentifier());
            software1.setName(softterm1.getName());
            software1.setVersion(proc.getSoftVersion());

            SoftwareListType softwareList = nmrMLtype.getSoftwareList();
            bstop=false;
            for(int i=0; i<softwareList.getSoftware().size(); i++){
              SoftwareType soft = softwareList.getSoftware().get(i);
              if (soft.getVersion().equals(software1.getVersion()) && soft.getAccession().equals(software1.getAccession()) ) {
                  software1=soft;
                  bstop=true;
                  break;
              }
            }
            if (!bstop) {
                softwareList.getSoftware().add(software1);
                nmrMLtype.setSoftwareList(softwareList);
            }

       /* Software Ref List */
            SoftwareRefListType softwareRefList = objFactory.createSoftwareRefListType();
            SoftwareRefType softref1 = objFactory.createSoftwareRefType();
            softref1.setRef(software1);
            softwareRefList.getSoftwareRef().add(softref1);


       /* ACQUISITION PARAMETERS */
            Acquisition1DType acq1D = nmrMLtype.getAcquisition().getAcquisition1D();
            AcquisitionDimensionParameterSetType acqdimparam = acq1D.getAcquisitionParameterSet().getDirectDimensionParameterSet();
            double spectralWidthHz = Double.parseDouble(acqdimparam.getSweepWidth().getValue());
            double spectralFrequency = Double.parseDouble(acqdimparam.getEffectiveExcitationField().getValue());

       /* Spectrum List */
            Spectrum1DType spectrum1D = objFactory.createSpectrum1DType();
            spectrum1D.setNumberOfDataPoints(getBigInteger(proc.getTransformSize()));
            spectrum1D.setId(getNewIdentifier());
            spectrum1D.setName(Integer.toString(procno));

       /* Spectrum1D - FirstDimensionProcessingParameterSet object */
            FirstDimensionProcessingParameterSetType ProcParam1D = objFactory.createFirstDimensionProcessingParameterSetType();

       /* Spectrum1D - WindowFunction */
            FirstDimensionProcessingParameterSetType.WindowFunction windowFunction =
                                                     objFactory.createFirstDimensionProcessingParameterSetTypeWindowFunction();
            String WDWFunction = String.format("%d",proc.getWindowFunctionType());
            CVTermType cvWinFunc = cvLoader.fetchCVTerm("NMRCV",vendorMapper.getTerm("WDW", WDWFunction));
            windowFunction.setWindowFunctionMethod(cvWinFunc);
            CVParamType cvWinParam = null;
            switch (WDWFunction) {
                case "1":
                     cvWinParam = cvLoader.fetchCVParam("NMRCV","LINE_BROADENING");
                     cvWinParam.setValue(String.format("%f",proc.getLineBroadening()));
                     windowFunction.getWindowFunctionParameter().add(cvWinParam);
                     break;
                case "2":
                     cvWinParam = cvLoader.fetchCVParam("NMRCV","LINE_BROADENING");
                     cvWinParam.setValue(String.format("%f",proc.getLineBroadening()));
                     windowFunction.getWindowFunctionParameter().add(cvWinParam);
                     cvWinParam = cvLoader.fetchCVParam("NMRCV","GAUSSIAN_BROADENING");
                     cvWinParam.setValue(String.format("%f",proc.getGbFactor()));
                     windowFunction.getWindowFunctionParameter().add(cvWinParam);
                     break;
                case "3":
                case "4":
                     cvWinParam = cvLoader.fetchCVParam("NMRCV","SSB");
                     cvWinParam.setValue(String.format("%f",proc.getSsbSine()));
                     windowFunction.getWindowFunctionParameter().add(cvWinParam);
                     break;
                case "5":
                     cvWinParam = cvLoader.fetchCVParam("NMRCV","TM1");
                     cvWinParam.setValue(String.format("%f",proc.getLeftTrap()));
                     windowFunction.getWindowFunctionParameter().add(cvWinParam);
                     cvWinParam = cvLoader.fetchCVParam("NMRCV","TM2");
                     cvWinParam.setValue(String.format("%f",proc.getRightTrap()));
                     windowFunction.getWindowFunctionParameter().add(cvWinParam);
                     break;
                case "6":
                     cvWinParam = cvLoader.fetchCVParam("NMRCV","SSB");
                     cvWinParam.setValue(String.format("%f",proc.getSsbSine()));
                     windowFunction.getWindowFunctionParameter().add(cvWinParam);
                     cvWinParam = cvLoader.fetchCVParam("NMRCV","GAUSSIAN_BROADENING");
                     cvWinParam.setValue(String.format("%f",proc.getGbFactor()));
                     windowFunction.getWindowFunctionParameter().add(cvWinParam);
                     break;
                case "7":
                case "8":
                     cvWinParam = cvLoader.fetchCVParam("NMRCV","LINE_BROADENING");
                     cvWinParam.setValue(String.format("%f",proc.getLineBroadening()));
                     cvWinParam = cvLoader.fetchCVParam("NMRCV","TM1");
                     cvWinParam.setValue(String.format("%f",proc.getLeftTrap()));
                     windowFunction.getWindowFunctionParameter().add(cvWinParam);
                     cvWinParam = cvLoader.fetchCVParam("NMRCV","TM2");
                     cvWinParam.setValue(String.format("%f",proc.getRightTrap()));
                     windowFunction.getWindowFunctionParameter().add(cvWinParam);
                     break;
            }
            ProcParam1D.getWindowFunction().add(windowFunction);

       /* Spectrum1D - Phasing */
            ValueWithUnitType  zeroOrderPhaseCorrection = objFactory.createValueWithUnitType();
            zeroOrderPhaseCorrection.setValue(String.format( "%f", proc.getZeroOrderPhase() ));
            zeroOrderPhaseCorrection.setUnitCvRef(cvUnitDeg.getCvRef());
            zeroOrderPhaseCorrection.setUnitAccession(cvUnitDeg.getAccession());
            zeroOrderPhaseCorrection.setUnitName(cvUnitDeg.getName());
            ProcParam1D.setZeroOrderPhaseCorrection(zeroOrderPhaseCorrection);
            ValueWithUnitType  firstOrderPhaseCorrection = objFactory.createValueWithUnitType();
            firstOrderPhaseCorrection.setValue(String.format( "%f", proc.getFirstOrderPhase() ));
            firstOrderPhaseCorrection.setUnitCvRef(cvUnitDeg.getCvRef());
            firstOrderPhaseCorrection.setUnitAccession(cvUnitDeg.getAccession());
            firstOrderPhaseCorrection.setUnitName(cvUnitDeg.getName());
            ProcParam1D.setFirstOrderPhaseCorrection(firstOrderPhaseCorrection);

       /* Calibration Reference Shift */
            ValueWithUnitType  calibrationReferenceShift = objFactory.createValueWithUnitType();
            calibrationReferenceShift.setValue("undefined");
            calibrationReferenceShift.setUnitCvRef(cvUnitNone.getCvRef());
            calibrationReferenceShift.setUnitAccession(cvUnitNone.getAccession());
            calibrationReferenceShift.setUnitName(cvUnitNone.getName());
            ProcParam1D.setCalibrationReferenceShift(calibrationReferenceShift);

       /* spectralDenoisingMethod */
            ProcParam1D.setSpectralDenoisingMethod(cvLoader.fetchCVTerm("NCIThesaurus","UNDEFINED"));
       /* baselineCorrectionMethod */
            ProcParam1D.setBaselineCorrectionMethod(cvLoader.fetchCVTerm("NCIThesaurus","UNDEFINED"));

       /* SpectrumType - X Axis */
            AxisWithUnitType Xaxis = objFactory.createAxisWithUnitType();
            Xaxis.setUnitCvRef(cvUnitPpm.getCvRef());
            Xaxis.setUnitAccession(cvUnitPpm.getAccession());
            Xaxis.setUnitName(cvUnitPpm.getName());
            Xaxis.setStartValue(String.format( "%f", proc.getMaxPpm() ));
            Xaxis.setEndValue(String.format( "%f", proc.getMaxPpm() - spectralWidthHz/spectralFrequency));
            spectrum1D.setXAxis(Xaxis);

       /* SpectrumType - Y Axis */
       /*     spectrum1D.setYAxisType(cvUnitNone); */

       /* Spectrum1D - Set FirstDimensionProcessingParameterSet */
            spectrum1D.setFirstDimensionProcessingParameterSet(ProcParam1D);

       /* SpectrumType - Software Ref List */
            spectrum1D.setProcessingSoftwareRefList(softwareRefList);

       /* SpectrumType - ProcessingParameterFile Ref List */
            spectrum1D.setProcessingParameterFileRefList(processingParameterFileRefList);

       /* SpectrumType - ProcessingParameterSet */
            SpectrumType.ProcessingParameterSet procParamSet = objFactory.createSpectrumTypeProcessingParameterSet();
            procParamSet.setDataTransformationMethod(cvLoader.fetchCVTerm("NMRCV","FFT_TRANSFORM"));
            procParamSet.setPostAcquisitionSolventSuppressionMethod(cvLoader.fetchCVTerm("NCIThesaurus","UNDEFINED"));
            procParamSet.setCalibrationCompound(cvLoader.fetchCVTerm("NCIThesaurus","UNDEFINED"));
            spectrum1D.setProcessingParameterSet(procParamSet);

            /* Real Data object */
            if (hBinaryDataObj.containsKey("REAL_DATA_FILE") && hBinaryDataObj.get("REAL_DATA_FILE").isExists()) {
                BinaryDataArrayType RealData = objFactory.createBinaryDataArrayType();
                RealData.setEncodedLength(hBinaryDataObj.get("REAL_DATA_FILE").getEncodedLength());
                RealData.setByteFormat(hBinaryDataObj.get("REAL_DATA_FILE").getByteFormat());
                RealData.setCompressed(hBinaryDataObj.get("REAL_DATA_FILE").isCompressed());
                /*RealData.setDataProcessingRef(dataproc);*/

                if(this.getIfbinarydata()) {
                    RealData.setValue(hBinaryDataObj.get("REAL_DATA_FILE").getData());
                }
                spectrum1D.setSpectrumDataArray(RealData);
            }


            spectrumList.getSpectrum1D().add(spectrum1D);
            nmrMLtype.setSpectrumList(spectrumList);


       /* Generate XML */
            JAXBElement<NmrMLType> nmrML = (JAXBElement<NmrMLType>) objFactory.createNmrML(nmrMLtype);

            // create a JAXBContext capable of handling classes generated into the org.nmrml.schema package
            JAXBContext outjc = JAXBContext.newInstance(NmrMLType.class);

            // create a Marshaller and marshal to a file / stdout
            Marshaller m = outjc.createMarshaller();
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
