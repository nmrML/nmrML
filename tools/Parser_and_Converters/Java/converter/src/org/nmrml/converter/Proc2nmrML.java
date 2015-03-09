/*
 * $Id: Converter.java,v 1.0.alpha Feb 2014 (C) INRA - DJ $
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
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

            if ( nmrMLtype.getSpectrum() != null ) {
               System.err.println("nmrMLproc: Error - a spectrum section already exists. It must have only one spectrum per nmrML file.");
               System.exit(1);
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

       /* DataProcessing List */
            ReferenceableParamGroupListType refParamGroupList = null;
            if ( nmrMLtype.getReferenceableParamGroupList() != null ) {
                 refParamGroupList = nmrMLtype.getReferenceableParamGroupList();
            } else {
                 refParamGroupList = objFactory.createReferenceableParamGroupListType();
            }
            DataProcessingListType dataproclist = objFactory.createDataProcessingListType();
            DataProcessingType dataproc = objFactory.createDataProcessingType();
            ProcessingMethodType procmethod = objFactory.createProcessingMethodType();
            procmethod.setOrder(getBigInteger(1));
            procmethod.setSoftwareRef(software1);
            if (proc.getPhasingType()>0) {
                 procmethod.getCvParam().add(cvLoader.fetchCVParam("NMRCV","PHASE_CORRECTION"));
            }
            procmethod.getCvParam().add(cvLoader.fetchCVParam("NMRCV","FFT_TRANSFORM"));

            /* ReferenceableParamGroupRef : Solvent Suppression */
            if ( proc.getSolventSuppressionType() != null && proc.getSolventSuppressionType().length()>0) {
                 ReferenceableParamGroupType refParamGroup1 = objFactory.createReferenceableParamGroupType();
                 refParamGroup1.setId(getNewIdentifier());
                 refParamGroup1.getCvParam().add(cvLoader.fetchCVParam("NMRCV","SOLVENT_SUPPRESSION"));
                 UserParamType userParam1 = objFactory.createUserParamType();
                 userParam1.setName("Method");
                 userParam1.setValue(proc.getSolventSuppressionType());
                 refParamGroup1.getUserParam().add(userParam1);
                 refParamGroupList.getReferenceableParamGroup().add(refParamGroup1);
                 ReferenceableParamGroupRefType ParamGroupRef1 = objFactory.createReferenceableParamGroupRefType();
                 ParamGroupRef1.setRef(refParamGroup1);
                 procmethod.getReferenceableParamGroupRef().add(ParamGroupRef1);
            }
            /* ReferenceableParamGroupRef : Baseline Correction */
            if (proc.getBaselineCorrectionType() != null && proc.getBaselineCorrectionType().length()>0) {
                 ReferenceableParamGroupType refParamGroup2 = objFactory.createReferenceableParamGroupType();
                 refParamGroup2.setId(getNewIdentifier());
                 refParamGroup2.getCvParam().add(cvLoader.fetchCVParam("NMRCV","BASELINE_CORRECTION"));
                 UserParamType userParam2 = objFactory.createUserParamType();
                 userParam2.setName("Method");
                 userParam2.setValue(proc.getBaselineCorrectionType());
                 refParamGroup2.getUserParam().add(userParam2);
                 refParamGroupList.getReferenceableParamGroup().add(refParamGroup2);
                 ReferenceableParamGroupRefType ParamGroupRef2 = objFactory.createReferenceableParamGroupRefType();
                 ParamGroupRef2.setRef(refParamGroup2);
                 procmethod.getReferenceableParamGroupRef().add(ParamGroupRef2);
            }
            /* ReferenceableParamGroupRef : Group Delay Correction */
            if (proc.getGroupDelay()>0) {
                 ReferenceableParamGroupType refParamGroup3 = objFactory.createReferenceableParamGroupType();
                 refParamGroup3.setId(getNewIdentifier());
                 refParamGroup3.getCvParam().add(cvLoader.fetchCVParam("NMRCV","GRPDELAY"));
                 UserParamType userParam3 = objFactory.createUserParamType();
                 userParam3.setName("group delay");
                 userParam3.setValue(String.format("%d",proc.getGroupDelay()));
                 userParam3.setUnitCvRef(cvUnitCount.getCvRef());
                 userParam3.setUnitAccession(cvUnitCount.getAccession());
                 userParam3.setUnitName(cvUnitCount.getName());
                 refParamGroup3.getUserParam().add(userParam3);
                 refParamGroupList.getReferenceableParamGroup().add(refParamGroup3);
                 ReferenceableParamGroupRefType ParamGroupRef3 = objFactory.createReferenceableParamGroupRefType();
                 ParamGroupRef3.setRef(refParamGroup3);
                 procmethod.getReferenceableParamGroupRef().add(ParamGroupRef3);
            }
            /* ReferenceableParamGroupRef : Spectral referecing */
            if ( proc.getRef_cmpd() != null && proc.getRef_cmpd().length()>0 ) {
                 ReferenceableParamGroupType refParamGroup4 = objFactory.createReferenceableParamGroupType();
                 refParamGroup4.setId(getNewIdentifier());
                 refParamGroup4.getCvParam().add(cvLoader.fetchCVParam("NMRCV","REFERENCING"));
                 /* compound name */
                 UserParamType userParam4 = objFactory.createUserParamType();
                 userParam4.setName("Compound");
                 userParam4.setValue(proc.getRef_cmpd());
                 refParamGroup4.getUserParam().add(userParam4);
                 /* ppm value */
                 UserParamType userParam5 = objFactory.createUserParamType();
                 userParam5.setName("ppm");
                 userParam5.setValue(String.format("%f",proc.getRef_ppm()));
                 userParam5.setUnitCvRef(cvUnitPpm.getCvRef());
                 userParam5.setUnitAccession(cvUnitPpm.getAccession());
                 userParam5.setUnitName(cvUnitPpm.getName());
                 refParamGroup4.getUserParam().add(userParam5);
                 refParamGroupList.getReferenceableParamGroup().add(refParamGroup4);
                 ReferenceableParamGroupRefType ParamGroupRef4 = objFactory.createReferenceableParamGroupRefType();
                 ParamGroupRef4.setRef(refParamGroup4);
                 procmethod.getReferenceableParamGroupRef().add(ParamGroupRef4);
            }
            dataproc.getProcessingMethod().add(procmethod);
            dataproc.setId(getNewIdentifier());
            dataproclist.getDataProcessing().add(dataproc);
            nmrMLtype.setDataProcessingList(dataproclist);
            if (refParamGroupList.getReferenceableParamGroup().size()>0) {
                 nmrMLtype.setReferenceableParamGroupList(refParamGroupList);
            }

       /* ACQUISITION PARAMETERS */
            Acquisition1DType acq1D = nmrMLtype.getAcquisition().getAcquisition1D();
            AcquisitionDimensionParameterSetType acqdimparam = acq1D.getAcquisitionParameterSet().getDirectDimensionParameterSet();
            double spectralWidthHz = Double.parseDouble(acqdimparam.getSweepWidth().getValue());
            double spectralFrequency = Double.parseDouble(acqdimparam.getEffectiveExcitationField().getValue());

       /* Spectrum List */
            SpectrumContainerType spectrumContainer = objFactory.createSpectrumContainerType();
            spectrumContainer.setDefaultDataProcessingRef(dataproc);
            Spectrum1DType spectrum1D = objFactory.createSpectrum1DType();
            spectrum1D.setNumberOfDataPoints(getBigInteger(proc.getTransformSize()));

       /* Spectrum1D - FirstDimensionProcessingParameterSet object */
            FirstDimensionProcessingParameterSetType ProcParam1D = objFactory.createFirstDimensionProcessingParameterSetType();

       /* Spectrum1D - WindowFunction */
            FirstDimensionProcessingParameterSetType.WindowFunction windowFunction =
                                                     objFactory.createFirstDimensionProcessingParameterSetTypeWindowFunction();

            CVTermType cvWinFunc = cvLoader.fetchCVTerm("NMRCV",vendorMapper.getTerm("WDW", String.format("%d",proc.getWindowFunctionType())));
            windowFunction.setWindowFunctionMethod(cvWinFunc);
            CVParamType cvWinParam = cvLoader.fetchCVParam("NMRCV","LINE_BROADENING");
            cvWinParam.setValue(String.format("%f",proc.getLineBroadening()));
            windowFunction.getWindowFunctionParameter().add(cvWinParam);
            ProcParam1D.getWindowFunction().add(windowFunction);
            ProcParam1D.setNoOfDataPoints(getBigInteger(proc.getTransformSize()));

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

       /* Spectrum1D - Source File Ref */
            SourceFileRefType procFileRef = objFactory.createSourceFileRefType();
            procFileRef.setRef(hSourceFileObj.get("PROCESSING_FILE"));
            ProcParam1D.setParameterFileRef(procFileRef);
            spectrum1D.setFirstDimensionProcessingParameterSet(ProcParam1D);

       /* SpectrumType - X Axis */
            AxisWithUnitType Xaxis = objFactory.createAxisWithUnitType();
            Xaxis.setUnitCvRef(cvUnitPpm.getCvRef());
            Xaxis.setUnitAccession(cvUnitPpm.getAccession());
            Xaxis.setUnitName(cvUnitPpm.getName());
            Xaxis.setStartValue(String.format( "%f", proc.getMaxPpm() ));
            Xaxis.setEndValue(String.format( "%f", proc.getMaxPpm() - spectralWidthHz/spectralFrequency));
            spectrum1D.setXAxis(Xaxis);

       /* SpectrumType - Y Axis */
            spectrum1D.setYAxisType(cvUnitNone);

       /* SpectrumType - Software, Contact Ref List */
            spectrum1D.getProcessingSoftwareRefList().add(softwareRefList);
            spectrum1D.setProcessingContactRefList(contactRefList);

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
                RealData.setDataProcessingRef(dataproc);

                if(this.getIfbinarydata()) {
                    RealData.setValue(hBinaryDataObj.get("REAL_DATA_FILE").getData());
                }
                spectrum1D.setSpectrumDataArray(RealData);
            }


            spectrumContainer.setSpectrum1D(spectrum1D);
            nmrMLtype.setSpectrum(spectrumContainer);


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
