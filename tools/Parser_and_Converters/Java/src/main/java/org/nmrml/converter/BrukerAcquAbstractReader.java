/*
 * Copyright (c) 2013. EMBL, European Bioinformatics Institute
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



import org.nmrml.cv.BrukerMapper;
import org.nmrml.cv.CVLoader;
import org.nmrml.model.Acquisition1DType;
import org.nmrml.model.AcquisitionDimensionParameterSetType;
import org.nmrml.model.AcquisitionParameterSetType;
import org.nmrml.model.AcquisitionType;
import org.nmrml.model.BinaryDataArrayType;
import org.nmrml.model.CVListType;
import org.nmrml.model.CVParamType;
import org.nmrml.model.NmrMLType;
import org.nmrml.model.ObjectFactory;
import org.nmrml.model.SourceFileListType;
import org.nmrml.model.SourceFileRefType;
import org.nmrml.model.SourceFileType;
import org.nmrml.model.ValueWithUnitType;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileReader;
import java.io.IOException;
import java.math.BigInteger;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.channels.FileChannel;
import java.text.DecimalFormat;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Reader for Bruker's acqu and acqus files
 *
 * @author Luis F. de Figueiredo
 *
 * User: ldpf
 * Date: 27/07/2013
 *
 */
public class BrukerAcquAbstractReader implements AcquReader {



    public enum BitOrder{
        LITTLE_ENDIAN (0),
        BIG_ENDIAN    (1);
        private final int type;

        private BitOrder(int type){
            this.type=type;
        }

        private int getType(){return type;}
    }

    public enum IntegerLength{
        BIT32         (4),  // integer
        BIT64         (8); //double
        private final int length;


        private IntegerLength(int length){
            this.length=length;
        }
        private int getLength(){return length;}

    }
    public enum AcquisitionMode {
        SEQUENTIAL      (1),
        SIMULTANIOUS    (2),
        DISP            (3),
        CUSTOM_DISP     (4);

        private final int type;

        private AcquisitionMode(int type){
            this.type=type;
        }

        private double getType(){return type;};
    }

    public enum FidData {
        INT32       (1),
        DOUBLE      (2),
        FLOAT       (3),
        INT16       (4);

        private final int type;

        private FidData(int type){
            this.type=type;
        }

        private double getType(){return type;};
    }

    private BufferedReader inputAcqReader;
    private ObjectFactory objectFactory;
    private NmrMLType nmrMLType;
    private CVLoader cvLoader;
    private File inputFile;
    private BrukerMapper brukerMapper;
    private boolean is2D = false;

    // files for 2D nnmr
    private final static Pattern REGEXP_ACQU2 = Pattern.compile("acqu2"); //file name
    // parameters from acqu
    private final static Pattern REGEXP_SFO1 = Pattern.compile("\\#\\#\\$SFO1= (-?\\d+\\.\\d+)"); //transmitter frequency
    private final static Pattern REGEXP_BF1 = Pattern.compile("\\#\\#\\$BF1= (-?\\d+\\.\\d+)"); //magnetic field frequency of channel 1
    private final static Pattern REGEXP_SFO2 = Pattern.compile("\\#\\#\\$SFO2= (-?\\d+\\.\\d+)"); //decoupler frequency
    private final static Pattern REGEXP_SFO3 = Pattern.compile("\\#\\#\\$SFO3= (\\d+\\.\\d+)"); //second decoupler frequency
    private final static Pattern REGEXP_O1 = Pattern.compile("\\#\\#\\$O1= (\\d+\\.\\d+)"); //frequency offset in Hz
    private final static Pattern REGEXP_SW = Pattern.compile("\\#\\#\\$SW= (\\d+\\.\\d+)"); //spectral width (ppm)
    private final static Pattern REGEXP_SW_H = Pattern.compile("\\#\\#\\$SW_h= (\\d+\\.\\d+)"); //spectral width (Hz)
    private final static Pattern REGEXP_TD = Pattern.compile("\\#\\#\\$TD= (\\d+)"); //acquired points (real+imaginary)
    private final static Pattern REGEXP_DECIM = Pattern.compile("\\#\\#\\$DECIM= (-?\\d+)"); //DSP decimation factor
    private final static Pattern REGEXP_DSPFVS = Pattern.compile("\\#\\#\\$DSPFVS= (-?\\d+)"); //DSP firmware version
    // obtain the GRPDLY from the acqus and not from acqu...
    private final static Pattern REGEXP_GRPDLY = Pattern.compile("\\#\\#\\$GRPDLY= (-?\\d+)"); //DSP group delay
    private final static Pattern REGEXP_BYTORDA = Pattern.compile("\\#\\#\\$BYTORDA= (\\d+)"); //byte order
    // variables not yet defined in Experiment
    private final static Pattern REGEXP_AQ_MODE = Pattern.compile("\\#\\#\\$AQ\\_mod= (\\d+)"); //acquisition mode
    private final static Pattern REGEXP_DIGMOD = Pattern.compile("\\#\\#\\$DIGMOD= (\\d+)"); //filter type
    private final static Pattern REGEXP_NS = Pattern.compile("\\#\\#\\$NS= (\\d+)"); //number of scans
    //TODO review REGEXP_PULPROG
    // examples of REGEXP_PULPROG : <zg> <cosydfph> <bs_hsqcetgpsi>; basically a word between < >
    private final static Pattern REGEXP_PULPROG = Pattern.compile("\\#\\#\\$PULPROG= (.+)"); //pulse program
    //TODO review REGEXP_NUC1
    // examples of REGEXP_NUC1 : <1H>; basically <isotope number + element>
    private final static Pattern REGEXP_NUC_INDEX = Pattern.compile("\\#\\#\\$NUC(\\d)=.+"); // index of the nucleus
    private final static Pattern REGEXP_NUC = Pattern.compile("\\#\\#\\$NUC\\d= (.+)"); // observed nucleus
    //TODO review REGEXP_INSTRUM
    // examples of REGEXP_INSTRUM : <amx500> ; basically <machine name>
    private final static Pattern REGEXP_INSTRUM = Pattern.compile("\\#\\#\\$INSTRUM= (.+)"); // instrument name
    private final static Pattern REGEXP_DTYPA = Pattern.compile("\\#\\#\\$DTYPA= (\\d+)"); //data type (0 -> 32 bit int, 1 -> 64 bit double)
    //TODO review REGEXP_SOLVENT
    // examples of REGEXP_SOLVENT : <DMSO> ; basically <solvent name>
    private final static Pattern REGEXP_SOLVENT = Pattern.compile("\\#\\#\\$SOLVENT= (.+)"); // instrument name
    //TODO review REGEXP_PROBHD
    // examples of REGEXP_PROBHD : <32> <>; basically <digit?>
    private final static Pattern REGEXP_PROBHD = Pattern.compile("\\#\\#\\$PROBHD= (.+)"); // probehead
    //TODO review REGEXP_ORIGIN
    // examples of REGEXP_ORIGIN : Bruker Analytik GmbH; basically a name
    private final static Pattern REGEXP_ORIGIN = Pattern.compile("\\#\\#\\$ORIGIN= (.+)"); // origin
    //TODO review REGEXP_OWNER
    // examples of REGEXP_OWNER : guest; basically the used ID
    private final static Pattern REGEXP_OWNER = Pattern.compile("\\#\\#\\$OWNER= (.+)"); // owner


//    public BrukerAcquAbstractReader() {
//        objectFactory = new ObjectFactory();
//        nmrMLType = objectFactory.createNmrMLType();
//    }

    public BrukerAcquAbstractReader(File acquFile) throws IOException {
        this(acquFile,new ObjectFactory().createNmrMLType(), new BrukerMapper(), new CVLoader());
    }
    public BrukerAcquAbstractReader(File acquFile,
                                    NmrMLType nmrMLType,
                                    BrukerMapper brukerMapper,
                                    CVLoader cvLoader) throws IOException {
//        Path path = Paths.get(acquFile.getPath());
//        is2D = REGEXP_ACQU2.matcher(path.toString()).find() || new File(path.getParent().toString()+"/acqu2").exists();
        objectFactory = new ObjectFactory();
        this.brukerMapper = brukerMapper;
        this.cvLoader= cvLoader;
        this.nmrMLType = nmrMLType;
        this.inputFile = acquFile;
        this.inputAcqReader = new BufferedReader(new FileReader(acquFile));
    }

    public BrukerAcquAbstractReader(String filename) throws IOException {
        this(new File(filename), new ObjectFactory().createNmrMLType(), new BrukerMapper(), new CVLoader());
    }
    public BrukerAcquAbstractReader(String filename, NmrMLType nmrMLType) throws IOException {
        this(new File(filename), nmrMLType, new BrukerMapper(),new CVLoader());
        // required parameters so far...
        // AquiredPoints: FidReader
        // SpectraWidth: FidReader
        // transmiterFreq: FidReader
        //
    }

    @Override
    public NmrMLType read() throws IOException {
        nmrMLType.setSourceFileList(loadSourceFileList());
        AcquisitionType acquisition = objectFactory.createAcquisitionType();
        acquisition.setAcquisition1D(readDirectDimension());
        nmrMLType.setAcquisition(acquisition);

        CVListType cvListType = objectFactory.createCVListType();
        for(String keys : cvLoader.getCvTypeHashMap().keySet()){
            cvListType.getCv().add(cvLoader.getCvTypeHashMap().get(keys));
        }
        nmrMLType.setCvList(cvListType);
        loadSourceFileRefs();
        return nmrMLType;
    }




    private Acquisition1DType readDirectDimension() throws IOException{

        Acquisition1DType acquisition = objectFactory.createAcquisition1DType();
        //TODO check if I can usd this instanciation


        AcquisitionReader acquisitionReader = new AcquisitionReader();
        acquisition.setAcquisitionParameterSet(acquisitionReader.getParameterSet());
        acquisition.setFid(readFid(acquisitionReader));

        //add the reference list

        
        


        // just for the record to use in 2D nmr
//        AcquisitionParameterSet2DType parameterSet2DType = new AcquisitionParameterSet2DType();
//        parameterSet2DType.setDirectDimensionParameterSet(parameter);




        //TODO read contact details
        //contact parameters
//        String line = inputAcqReader.readLine();
//        ContactType contact = new ContactType();
//        if (REGEXP_ORIGIN.matcher(line).find()) {
//            matcher = REGEXP_ORIGIN.matcher(line);
//            matcher.find();
//            // probably not correct
//            contact.setOrganization(matcher.group(1));
//        }
//        if (REGEXP_OWNER.matcher(line).find()) {
//            matcher = REGEXP_OWNER.matcher(line);
//            matcher.find();
//            contact.setFullname(matcher.group(1));
//        }


        return acquisition;
    }

    private BinaryDataArrayType readFid (AcquisitionReader acquisitionReader) throws IOException {
        BinaryDataArrayType binaryDataArrayType = objectFactory.createBinaryDataArrayType();
        FileInputStream fidInput = new FileInputStream(inputFile.getParentFile().getAbsolutePath().concat("/fid"));
        FileChannel inChannel = fidInput.getChannel();
        binaryDataArrayType.setByteLength(BigInteger.valueOf(inChannel.size() / acquisitionReader.getBiteSyze()));
        ByteBuffer buffer = ByteBuffer.allocate((int) inChannel.size());
        buffer.order(acquisitionReader.getByteOrder());
        inChannel.read(buffer);
        if(acquisitionReader.getBiteSyze()==4){ // values as 32 bit integer
            binaryDataArrayType.setByteFormat(Integer.class.toString());
        } else { // 64 bit integer
            binaryDataArrayType.setByteFormat(Long.class.toString());
        }
        binaryDataArrayType.setBinary(buffer.array());
        /* debuging */
//        FileOutputStream fos = new FileOutputStream(new File("/Users/ldpf/Downloads/fid-out"));
//        BufferedOutputStream bos = new BufferedOutputStream(fos);
//        bos.write(buffer.array());
//        bos.flush();
//        bos.close();
//        fos.close();

          return binaryDataArrayType;
    }


    //TODO move this method to another place
    private SourceFileListType loadSourceFileList(){
        SourceFileListType sourceFileListType = objectFactory.createSourceFileListType();
        sourceFileListType.setCount(BigInteger.valueOf(0));
        String foldername = inputFile.getParent().concat("/");
        for (String key : brukerMapper.getSection("FILES").keySet()){
            File file = new File(foldername+brukerMapper.getTerm("FILES",key));
            SourceFileType sourceFileType = objectFactory.createSourceFileType();
            if(file.exists()){
                sourceFileType.setId(key);
                sourceFileType.setLocation(file.toURI().toString());
                sourceFileType.setName(file.getName());
                sourceFileListType.setCount(sourceFileListType.getCount().add(BigInteger.ONE));
                sourceFileListType.getSourceFile().add(sourceFileType);
            }
        }
        return sourceFileListType;
    }

    protected class AcquisitionReader {



        private AcquisitionDimensionParameterSetType acquParameters;
        private Acquisition1DType.AcquisitionParameterSet parameterSet;
        private AcquisitionParameterSetType.PulseSequence pulseSequence;
        private ByteOrder byteOrder;
        private int biteSyze;

        private AcquisitionReader() throws IOException {
            this.parameterSet = new Acquisition1DType.AcquisitionParameterSet();
            readDimensionParameters();
            parameterSet.setDirectDimensionParameterSet(acquParameters);
            parameterSet.setPulseSequence(pulseSequence);

        }

        private void readDimensionParameters() throws IOException {
            double gyromagneticRatio= 42.577480;
            acquParameters= objectFactory.createAcquisitionDimensionParameterSetType();
            pulseSequence = objectFactory.createAcquisitionParameterSetTypePulseSequence();
            ValueWithUnitType value;
            Matcher matcher;
            String line = inputAcqReader.readLine();

//        BinaryDataArrayType binaryDataArray = objectFactory.createBinaryDataArrayType();
//        //binaryDataArray.setByteFormat(IntegerType.BIT32? "32bit":"64bit");
//        binaryDataArray.setByteLength();
        while (inputAcqReader.ready() && (line != null)) {
            /* sweep width in ppm*/
            if (REGEXP_SW.matcher(line).find()) {
                matcher = REGEXP_SW.matcher(line);
                matcher.find();
                value = objectFactory.createValueWithUnitType();
                value.setValue(matcher.group(1));
                try {
                    CVParamType cvParamType = cvLoader.fetchCVParam("UO","PPM");
                    value.setUnitCvRef(cvParamType.getCvRef());
                    value.setUnitName(cvParamType.getName());
                    value.setUnitAccession(cvParamType.getAccession());
                } catch (Exception e) {
                    e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
                }
                acquParameters.setSweepWidth(value);
            }
            /* sweep width in hertz */
            if (REGEXP_SW_H.matcher(line).find()) {
                matcher = REGEXP_SW_H.matcher(line);
                matcher.find();
                value = objectFactory.createValueWithUnitType();
                Double sweepWidth = Double.parseDouble(matcher.group(1));
                value.setValue(sweepWidth.toString());
                try {
                    CVParamType cvParamType = cvLoader.fetchCVParam("UO","HERTZ");
                    value.setUnitCvRef(cvParamType.getCvRef());
                    value.setUnitName(cvParamType.getName());
                    value.setUnitAccession(cvParamType.getAccession());
                } catch (Exception e) {
                    e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
                }
                acquParameters.setSweepWidth(value);
            }
            /* number of data points */
            if (REGEXP_TD.matcher(line).find()) {
                matcher = REGEXP_TD.matcher(line);
                matcher.find();
                acquParameters.setNumberOfDataPoints(BigInteger.valueOf(Long.parseLong(matcher.group(1))));
            }
            /* observed nucleus */
            //TODO at the moment this stores only the first nuclei assuming that this is only 1D spectra
            if (REGEXP_NUC.matcher(line).find() && acquParameters.getAcquisitionNucleus()==null) {
                matcher = REGEXP_NUC.matcher(line);
                matcher.find();
                String atom =matcher.group(1).replace("<","").replace(">","");
                //TODO this will be changed in the next CV
                if(atom.matches("H")){
                    //CVParamType cvParamType = cvLoader.fetchCVParam("CHEBI","H");
                    acquParameters.setAcquisitionNucleus("1H");
                } else if (atom.matches("13C")){
                    //CVParamType cvParamType = cvLoader.fetchCVParam("CHEBI","13C");
                    acquParameters.setAcquisitionNucleus("13C");
                } else {
                    acquParameters.setAcquisitionNucleus(atom);
                }
            }
            /* byte order */
            if(REGEXP_BYTORDA.matcher(line).find()){
                matcher = REGEXP_BYTORDA.matcher(line);
                matcher.find();
                switch (Integer.parseInt(matcher.group(1))) {
                    case 0:
                        byteOrder=ByteOrder.LITTLE_ENDIAN;
                        break;
                    case 1:
                        byteOrder=ByteOrder.BIG_ENDIAN;
                        break;
                    default:
                        byteOrder=ByteOrder.nativeOrder();
                        break;
                }
            }
            /* integer type */
            if(REGEXP_DTYPA.matcher(line).find()){
                matcher = REGEXP_DTYPA.matcher(line);
                matcher.find();
                switch (Integer.parseInt(matcher.group(1))){
                    case 0:
                        biteSyze=4;   // 32 bits integer - 4 octets
                        break;
                    case 1:
                        biteSyze=8;   // 64 bits integer - 8 octets
                        break;
                    default:
                        biteSyze=4;   // 32 bits integer
                        break;
                }
            }
            /* magnetic field ?? */
            if(REGEXP_SFO1.matcher(line).find()){
                matcher = REGEXP_SFO1.matcher(line);
                matcher.find();
                Double transmitterFrequency = Double.parseDouble(matcher.group(1))/gyromagneticRatio;
                // convert from hertz to Tesla
                value = objectFactory.createValueWithUnitType();
                value.setValue(new DecimalFormat("###.##").format(transmitterFrequency));
                try {
                    CVParamType cvParamType = cvLoader.fetchCVParam("UO","TESLA");
                    value.setUnitCvRef(cvParamType.getCvRef());
                    value.setUnitName(cvParamType.getName());
                    value.setUnitAccession(cvParamType.getAccession());
                } catch (Exception e) {
                    e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
                }
                acquParameters.setGammaB1PulseFieldStrength(value);
            }
            if(REGEXP_PULPROG.matcher(line).find()){
                matcher = REGEXP_PULPROG.matcher(line);
                matcher.find();
                // TODO probably replace with a CV term
                pulseSequence.setName(matcher.group(1).replaceAll("<", "").replaceAll(">", ""));
            }
            /* number of scans */
            if(REGEXP_NS.matcher(line).find()){
                matcher = REGEXP_NS.matcher(line);
                matcher.find();
                parameterSet.setNumberOfScans(BigInteger.valueOf(Long.parseLong(matcher.group(1))));
            }

            //TODO get this parameters working
//            acquParameters.setIrradiationFrequency();
//            parameterSet.setContactRefList(); // is this available in the acqu file?
//            parameterSet.setNumberOfSteadyStateScans();
//            parameterSet.setRelaxationDelay();
//            parameterSet.setSampleAcquisitionTemperature();
//            parameterSet.setSpinningRate();
//            parameterSet.setSampleContainer();

            line = inputAcqReader.readLine();

        }


    }

        public Acquisition1DType.AcquisitionParameterSet getParameterSet() {
            return parameterSet;
        }

        public ByteOrder getByteOrder() {
            return byteOrder;
        }

        public int getBiteSyze() {
            return biteSyze;
        }



    }

    private void loadSourceFileRefs() {
        for(SourceFileType sourceFileType : nmrMLType.getSourceFileList().getSourceFile()){
            if(sourceFileType.getId().matches("PULSEPROGRAM_FILE")){
                SourceFileRefType sourceFileRefType =objectFactory.createSourceFileRefType();
                sourceFileRefType.setRef(sourceFileType);
                nmrMLType.getAcquisition().getAcquisition1D().getAcquisitionParameterSet().getPulseSequence()
                        .setPulseSequenceFile(sourceFileRefType);
            }
            if(sourceFileType.getId().matches("ACQUISITION_FILE")){
                SourceFileRefType sourceFileRefType =objectFactory.createSourceFileRefType();
                sourceFileRefType.setRef(sourceFileType);
                nmrMLType.getAcquisition().getAcquisition1D().getAcquisitionParameterSet()
                        .setAcquisitionParameterFileRef(sourceFileRefType);
            }
            if(sourceFileType.getId().matches("FID_FILE")){
                SourceFileRefType sourceFileRefType =objectFactory.createSourceFileRefType();
                sourceFileRefType.setRef(sourceFileType);
                //TODO find out if there is a way to refence the fid file
            }
        }
    }


}
