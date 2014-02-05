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
import org.nmrml.model.AcquisitionParameterSet1DType;
import org.nmrml.model.AcquisitionType;
import org.nmrml.model.BinaryDataArrayType;
import org.nmrml.model.CVListType;
import org.nmrml.model.CVParamType;
import org.nmrml.model.CVTermType;
import org.nmrml.model.ContactListType;
import org.nmrml.model.ContactType;
import org.nmrml.model.InstrumentConfigurationListType;
import org.nmrml.model.InstrumentConfigurationType;
import org.nmrml.model.NmrMLType;
import org.nmrml.model.ObjectFactory;
import org.nmrml.model.PulseSequenceType;
import org.nmrml.model.SoftwareListType;
import org.nmrml.model.SoftwareType;
import org.nmrml.model.SourceFileListType;
import org.nmrml.model.SourceFileRefListType;
import org.nmrml.model.SourceFileRefType;
import org.nmrml.model.SourceFileType;
import org.nmrml.model.TemperatureType;
import org.nmrml.model.UserParamType;
import org.nmrml.model.ValueWithUnitType;

import javax.xml.bind.DatatypeConverter;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.math.BigInteger;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.channels.FileChannel;
import java.nio.file.Files;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.text.DecimalFormat;
import java.util.HashMap;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Reader for Bruker's acqu and acqus files
 *
 * @author Luis F. de Figueiredo
 *         <p/>
 *         User: ldpf
 *         Date: 27/07/2013
 */
public class BrukerAcquAbstractReader implements AcquReader {


    public enum BitOrder {
        LITTLE_ENDIAN(0),
        BIG_ENDIAN(1);
        private final int type;

        private BitOrder(int type) {
            this.type = type;
        }

        private int getType() {
            return type;
        }
    }

    public enum IntegerLength {
        BIT32(4),  // integer
        BIT64(8); //double
        private final int length;


        private IntegerLength(int length) {
            this.length = length;
        }

        private int getLength() {
            return length;
        }

    }

    public enum AcquisitionMode {
        SEQUENTIAL(1),
        SIMULTANIOUS(2),
        DISP(3),
        CUSTOM_DISP(4);

        private final int type;

        private AcquisitionMode(int type) {
            this.type = type;
        }

        private double getType() {
            return type;
        }

        ;
    }

    public enum FidData {
        INT32(1),
        DOUBLE(2),
        FLOAT(3),
        INT16(4);

        private final int type;

        private FidData(int type) {
            this.type = type;
        }

        private double getType() {
            return type;
        }

        ;
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
    private final static Pattern REGEXP_NUMBEROFSCANS = Pattern.compile("\\#\\#\\$NS= (\\d+)"); //number of scans
    private final static Pattern REGEXP_DUMMYSCANS = Pattern.compile("\\#\\#\\$DS= (\\d+)"); //number of dummy (steady state) scans
    private final static Pattern REGEXP_RELAXATIONDELAY = Pattern.compile("\\#\\#\\$RD= (\\d+\\.?\\d?)"); // relaxation delay
    private final static Pattern REGEXP_SPINNINGRATE = Pattern.compile("\\#\\#\\$MASR= (\\d+)"); // spinning rate
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
    private final static Pattern REGEXP_SOLVENT = Pattern.compile("\\#\\#\\$SOLVENT= (.+)"); // solvent name
    //TODO review REGEXP_PROBHD
    // examples of REGEXP_PROBHD : <32> <>; basically <digit?>
    private final static Pattern REGEXP_PROBHD = Pattern.compile("\\#\\#\\$PROBHD= (.+)"); // probehead
    // examples of REGEXP_ORIGIN : Bruker Analytik GmbH; basically a name
    private final static Pattern REGEXP_TITLE = Pattern.compile("\\#\\#TITLE= (.+), (.+)\t\t(.+)"); // origin
    //TODO review REGEXP_ORIGIN
    // examples of REGEXP_ORIGIN : Bruker Analytik GmbH; basically a name
    private final static Pattern REGEXP_ORIGIN = Pattern.compile("\\#\\#ORIGIN= (.+)"); // origin
    //TODO review REGEXP_OWNER
    // examples of REGEXP_OWNER : guest; basically the used ID
    private final static Pattern REGEXP_OWNER = Pattern.compile("\\#\\#OWNER= (.+)"); // owner
    private final static Pattern REGEXP_METAINFO = Pattern.compile("\\$\\$ (.+)"); // owner

    private final static Pattern REGEXP_TEMPERATURE = Pattern.compile("\\#\\#\\$TE= (\\d+\\.?\\d?)"); // temperature in Kelvin


    private static enum CvParam {
        FILE_FORMAT
    }

    private HashMap<CvParam, CVParamType> cvParamType;

//    public BrukerAcquAbstractReader() {
//        objectFactory = new ObjectFactory();
//        nmrMLType = objectFactory.createNmrMLType();
//    }

    public BrukerAcquAbstractReader(File acquFile) throws IOException {
        this(acquFile, new ObjectFactory().createNmrMLType(), new BrukerMapper(), new CVLoader());
    }

    public BrukerAcquAbstractReader(File acquFile,
                                    NmrMLType nmrMLType,
                                    BrukerMapper brukerMapper,
                                    CVLoader cvLoader) throws IOException {
//        Path path = Paths.get(acquFile.getPath());
//        is2D = REGEXP_ACQU2.matcher(path.toString()).find() || new File(path.getParent().toString()+"/acqu2").exists();
        objectFactory = new ObjectFactory();
        this.brukerMapper = brukerMapper;
        this.cvLoader = cvLoader;
        this.nmrMLType = nmrMLType;
        this.inputFile = acquFile;
        this.inputAcqReader = new BufferedReader(new FileReader(acquFile));
    }

    public BrukerAcquAbstractReader(String filename) throws IOException {
        this(new File(filename), new ObjectFactory().createNmrMLType(), new BrukerMapper(), new CVLoader());
    }

    public BrukerAcquAbstractReader(String filename, NmrMLType nmrMLType) throws IOException {
        this(new File(filename), nmrMLType, new BrukerMapper(), new CVLoader());
        // required parameters so far...
        // AquiredPoints: FidReader
        // SpectraWidth: FidReader
        // transmiterFreq: FidReader
        //
    }

    @Override
    public NmrMLType read() throws Exception {
        AcquisitionType acquisition = objectFactory.createAcquisitionType();
        /* load source files */
        nmrMLType.setSourceFileList(loadSourceFileList());
        /* load ontologies */
        readAcqufile();
        CVListType cvListType = objectFactory.createCVListType();
        for (String keys : cvLoader.getCvTypeHashMap().keySet()) {
            cvListType.getCv().add(cvLoader.getCvTypeHashMap().get(keys));
        }
        nmrMLType.setCvList(cvListType);
        loadSourceFileRefs();
        return nmrMLType;
    }


    private void readAcqufile() throws Exception {


        //TODO check if I can usd this instanciation

        AcquisitionReader acquisitionReader = new AcquisitionReader(nmrMLType);
        nmrMLType = acquisitionReader.read();
        cvParamType = acquisitionReader.getCvParamType();
        /* read fid */
        nmrMLType.getAcquisition().getAcquisition1D().setFidData(readFid(acquisitionReader));


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

    }

    private BinaryDataArrayType readFid(AcquisitionReader acquisitionReader) throws IOException {
        BinaryDataArrayType binaryDataArrayType = objectFactory.createBinaryDataArrayType();
        FileInputStream fidInput = new FileInputStream(inputFile.getParentFile().getAbsolutePath().concat("/fid"));
        FileChannel inChannel = fidInput.getChannel();
        binaryDataArrayType.setEncodedLength(BigInteger.valueOf(inChannel.size() / acquisitionReader.getBiteSyze()));
        ByteBuffer buffer = ByteBuffer.allocate((int) inChannel.size());
        buffer.order(acquisitionReader.getByteOrder());
        inChannel.read(buffer);
        if (acquisitionReader.getBiteSyze() == 4) { // values as 32 bit integer
            binaryDataArrayType.setByteFormat(Integer.class.toString());
        } else { // 64 bit integer
            binaryDataArrayType.setByteFormat(Long.class.toString());
        }
        binaryDataArrayType.setValue(buffer.array());
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
    private SourceFileListType loadSourceFileList() throws NoSuchAlgorithmException, IOException {

        SourceFileListType sourceFileListType = objectFactory.createSourceFileListType();
//        sourceFileListType.setCount(BigInteger.valueOf(0));
        String foldername = inputFile.getParent().concat("/");
        for (String key : brukerMapper.getSection("FILES").keySet()) {
            File file = new File(foldername + brukerMapper.getTerm("FILES", key));
            SourceFileType sourceFileType = objectFactory.createSourceFileType();
            if (file.exists()) {
                sourceFileType.setId(key);
                /* insert a relative path */
                sourceFileType.setLocation(inputFile.getParentFile().getParentFile().toURI()
                        .relativize(file.toURI()).toString());
                /* get the sha1 of the file */
                MessageDigest messageDigest = MessageDigest.getInstance("SHA-1");
                InputStream inputStream = Files.newInputStream(file.toPath());
                byte[] dataBytes = new byte[1024];
                int nread = 0;
                while ((nread = inputStream.read(dataBytes)) != -1) {
                    messageDigest.update(dataBytes, 0, nread);
                }
                sourceFileType.setSha1(DatatypeConverter.printHexBinary(messageDigest.digest()));
                try {
                    sourceFileType.getCvParam().add(cvLoader.fetchCVParam("NMRCV", key));
                } catch (Exception e) {
                    e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
                }
                sourceFileType.setName(file.getName());
//                sourceFileListType.setCount(sourceFileListType.getCount().add(BigInteger.ONE));
                sourceFileListType.getSourceFile().add(sourceFileType);
            }
        }
        return sourceFileListType;
    }

    protected class AcquisitionReader {

        static final double gyromagneticRatio = 42.577480;

        private ByteOrder byteOrder;
        private int biteSyze;
        private HashMap<CvParam, CVParamType> cvParamType;
        private NmrMLType nmrMLType;


        private AcquisitionReader(NmrMLType nmrMLType) throws IOException {
            this.nmrMLType = (nmrMLType == null)? objectFactory.createNmrMLType():nmrMLType;
            this.cvParamType = new HashMap<CvParam, CVParamType>();
        }

        public HashMap<CvParam, CVParamType> getCvParamType() {
            return cvParamType;
        }

        private NmrMLType read() throws Exception {
            AcquisitionDimensionParameterSetType acquParameters=
                    objectFactory.createAcquisitionDimensionParameterSetType();

            AcquisitionParameterSet1DType parameterSet = objectFactory.createAcquisitionParameterSet1DType();

            PulseSequenceType pulseSequence =objectFactory.createPulseSequenceType();
            SoftwareListType softwareListType = objectFactory.createSoftwareListType();
            TemperatureType temperatureType = objectFactory.createTemperatureType();
            ContactType contactType = objectFactory.createContactType();

            InstrumentConfigurationType instrumentConfigurationType = objectFactory.createInstrumentConfigurationType();
            instrumentConfigurationType.getCvParam().add(cvLoader.fetchCVParam("NMRCV","BRUKER"));

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
                        CVParamType cvParamType = cvLoader.fetchCVParam("UO", "PPM");
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
                        CVParamType cvParamType = cvLoader.fetchCVParam("UO", "HERTZ");
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
                if (REGEXP_NUC.matcher(line).find() && acquParameters.getAcquisitionNucleus() == null) {
                    matcher = REGEXP_NUC.matcher(line);
                    matcher.find();
                    String atom = matcher.group(1).replace("<", "").replace(">", "");
                    //TODO check if there the atom could also be defined simply as H
                    if (atom.matches("1H")) {
                        try {
                            // TODO check why one uses cvTermType instead of cvParamType
                            CVParamType cvParamType = cvLoader.fetchCVParam("CHEBI", "H");
                            CVTermType cvTermType = objectFactory.createCVTermType();
                            cvTermType.setAccession(cvParamType.getAccession());
                            cvTermType.setCvRef(cvParamType.getCvRef());
                            cvTermType.setName(cvParamType.getName());
                            acquParameters.setAcquisitionNucleus(cvTermType);
                        } catch (Exception e) {
                            e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
                        }
                    } else if (atom.matches("13C")) {
                        CVParamType cvParamType = null;
                        try {
                            cvParamType = cvLoader.fetchCVParam("CHEBI", "13C");
                            CVTermType cvTermType = objectFactory.createCVTermType();
                            cvTermType.setAccession(cvParamType.getAccession());
                            cvTermType.setCvRef(cvParamType.getCvRef());
                            cvTermType.setName(cvParamType.getName());

                            acquParameters.setAcquisitionNucleus(cvTermType);
                        } catch (Exception e) {
                            e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
                        }
                    } else {
                        CVTermType cvTermType = objectFactory.createCVTermType();
                        cvTermType.setName(atom);
                        acquParameters.setAcquisitionNucleus(cvTermType);
                    }
                }
            /* byte order */
                if (REGEXP_BYTORDA.matcher(line).find()) {
                    matcher = REGEXP_BYTORDA.matcher(line);
                    matcher.find();
                    switch (Integer.parseInt(matcher.group(1))) {
                        case 0:
                            byteOrder = ByteOrder.LITTLE_ENDIAN;
                            break;
                        case 1:
                            byteOrder = ByteOrder.BIG_ENDIAN;
                            break;
                        default:
                            byteOrder = ByteOrder.nativeOrder();
                            break;
                    }
                }
            /* integer type */
                if (REGEXP_DTYPA.matcher(line).find()) {
                    matcher = REGEXP_DTYPA.matcher(line);
                    matcher.find();
                    switch (Integer.parseInt(matcher.group(1))) {
                        case 0:
                            biteSyze = 4;   // 32 bits integer - 4 octets
                            break;
                        case 1:
                            biteSyze = 8;   // 64 bits integer - 8 octets
                            break;
                        default:
                            biteSyze = 4;   // 32 bits integer
                            break;
                    }
                }
            /* magnetic field ?? */
                if (REGEXP_SFO1.matcher(line).find()) {
                    matcher = REGEXP_SFO1.matcher(line);
                    matcher.find();
                    Double transmitterFrequency = Double.parseDouble(matcher.group(1)) / gyromagneticRatio;
                    // convert from hertz to Tesla
                    value = objectFactory.createValueWithUnitType();
                    value.setValue(new DecimalFormat("###.##").format(transmitterFrequency));
                    try {
                        CVParamType cvParamType = cvLoader.fetchCVParam("UO", "TESLA");
                        value.setUnitCvRef(cvParamType.getCvRef());
                        value.setUnitName(cvParamType.getName());
                        value.setUnitAccession(cvParamType.getAccession());
                    } catch (Exception e) {
                        e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
                    }
                    acquParameters.setEffectiveExcitationField(value);
                }
                if (REGEXP_PULPROG.matcher(line).find()) {
                    matcher = REGEXP_PULPROG.matcher(line);
                    matcher.find();
                    // TODO probably replace with a CV term
                    // set a cvTerm
//                pulseSequence.setName(matcher.group(1).replaceAll("<", "").replaceAll(">", ""));
                }
            /* number of scans */
                if (REGEXP_NUMBEROFSCANS.matcher(line).find()) {
                    matcher = REGEXP_NUMBEROFSCANS.matcher(line);
                    matcher.find();
                    parameterSet.setNumberOfScans(BigInteger.valueOf(Long.parseLong(matcher.group(1))));
                    //debug
//                    System.out.println("Number of scans: "+matcher.group(1));
                }
                /* number of dummy (steady state) scans */
                if (REGEXP_DUMMYSCANS.matcher(line).find()) {
                    matcher = REGEXP_DUMMYSCANS.matcher(line);
                    matcher.find();
                    parameterSet.setNumberOfSteadyStateScans(BigInteger.valueOf(Long.parseLong(matcher.group(1))));
                    //debug
//                    System.out.println("Number of dummy scans: "+matcher.group(1));
                }
                /* relaxation delay */
                if(REGEXP_RELAXATIONDELAY.matcher(line).find()){
                    matcher = REGEXP_RELAXATIONDELAY.matcher(line);
                    matcher.find();
                    value = objectFactory.createValueWithUnitType();
                    value.setValue(matcher.group(1));
                    // TODO move CVParam definition to a separate method...
                    try {
                        CVParamType cvParamType = cvLoader.fetchCVParam("UO", "SECOND");
                        value.setUnitCvRef(cvParamType.getCvRef());
                        value.setUnitName(cvParamType.getName());
                        value.setUnitAccession(cvParamType.getAccession());
                    } catch (Exception e) {
                        e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
                    }
                    parameterSet.setRelaxationDelay(value);

                }
                /* spinning rate */
                if(REGEXP_SPINNINGRATE.matcher(line).find()){
                    matcher = REGEXP_SPINNINGRATE.matcher(line);
                    matcher.find();
                    value = objectFactory.createValueWithUnitType();
                    Double spiningRate = Double.parseDouble(matcher.group(1));
                    value.setValue(spiningRate.toString());
                    try {
                        CVParamType cvParamType = cvLoader.fetchCVParam("UO", "HERTZ");
                        value.setUnitCvRef(cvParamType.getCvRef());
                        value.setUnitName(cvParamType.getName());
                        value.setUnitAccession(cvParamType.getAccession());
                    } catch (Exception e) {
                        e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
                    }
                    parameterSet.setSpinningRate(value);
                }

                if (REGEXP_BF1.matcher(line).find()) {
                    matcher = REGEXP_BF1.matcher(line);
                    matcher.find();
                    value = objectFactory.createValueWithUnitType();
                    Double irradiationFrequency = Double.parseDouble(matcher.group(1)) * 1e6;
                    value.setValue(irradiationFrequency.toString());
                    try {
                        CVParamType cvParamType = cvLoader.fetchCVParam("UO", "HERTZ");
                        value.setUnitCvRef(cvParamType.getCvRef());
                        value.setUnitName(cvParamType.getName());
                        value.setUnitAccession(cvParamType.getAccession());
                    } catch (Exception e) {
                        e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
                    }
                    acquParameters.setIrradiationFrequency(value);
                }
                /* temperature of the experiment */
                if(REGEXP_TEMPERATURE.matcher(line).find()) {
                    matcher = REGEXP_TEMPERATURE.matcher(line);
                    matcher.find();
                    value = objectFactory.createValueWithUnitType();
                    Double temperature = Double.parseDouble(matcher.group(1));
                    value.setValue(temperature.toString());
                    //TODO temperature should be a CV parameter...
                    try {
                        CVParamType cvParamType = cvLoader.fetchCVParam("UO", "KELVIN");
                        value.setUnitCvRef(cvParamType.getCvRef());
                        value.setUnitName(cvParamType.getName());
                        value.setUnitAccession(cvParamType.getAccession());
                    } catch (Exception e) {
                        e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
                    }
                    parameterSet.setSampleAcquisitionTemperature(value);
                    //debug
//                    System.out.println("Temperature: "+matcher.group(1));
                }

                /* add the file format to the source files*/
                if (REGEXP_ORIGIN.matcher(line).find()) {
                    matcher = REGEXP_ORIGIN.matcher(line);
                    matcher.find();
                    for (SourceFileType sourceFileType : nmrMLType.getSourceFileList().getSourceFile()){
                        try {
                            if (matcher.group(1).contains("UXNMR"))
                                sourceFileType.getCvParam().add(cvLoader.fetchCVParam("NMRCV", "UXNMR"));
                        } catch (Exception e) {
                            e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
                        }
                    }
                }
                /* extract software metadata */
                if(REGEXP_TITLE.matcher(line).find()){
                    matcher = REGEXP_TITLE.matcher(line);
                    matcher.find();
                    SoftwareType softwareType = objectFactory.createSoftwareType();
                    softwareType.setName(matcher.group(2));
                    softwareType.setVersion(matcher.group(3));
                    softwareListType.getSoftware().add(softwareType);
                }
                /* extract instrument metadata */
                if(REGEXP_PROBHD.matcher(line).find()){
                    matcher = REGEXP_PROBHD.matcher(line);
                    matcher.find();
                    UserParamType userParamType = objectFactory.createUserParamType();
                    userParamType.setName("Probehead");
                    userParamType.setValue(matcher.group(1));
                    instrumentConfigurationType.getUserParam().add(userParamType);
                }
                /* extract contact */
                if(REGEXP_OWNER.matcher(line).find()){
                    matcher=REGEXP_OWNER.matcher(line);
                    matcher.find();
                    contactType.setFullname(matcher.group(1));
                }
                /* extract email from "metadata" */
                if(REGEXP_METAINFO.matcher(line).find()){
                    matcher=REGEXP_METAINFO.matcher(line);
                    matcher.find();
                    for(String token : matcher.group(1).split(" ")){
                        if(token.contains("@")){
                            contactType.setEmail(token);
                            break;
                        }
                    }
                }


                line = inputAcqReader.readLine();

            }

            /* default values */
            // check if this information is in the acqus (doubt)
            CVTermType cvTerm = objectFactory.createCVTermType();
            cvTerm.setCvRef(cvLoader.fetchCVParam("NMRCV", "TUBE").getCvRef());
            cvTerm.setName(cvLoader.fetchCVParam("NMRCV", "TUBE").getName());
            cvTerm.setAccession(cvLoader.fetchCVParam("NMRCV", "TUBE").getAccession());
            parameterSet.setSampleContainer(cvTerm);

            cvTerm = objectFactory.createCVTermType();
            cvTerm.setCvRef(cvLoader.fetchCVParam("NMRCV", "UNIFORM").getCvRef());
            cvTerm.setName(cvLoader.fetchCVParam("NMRCV", "UNIFORM").getName());
            cvTerm.setAccession(cvLoader.fetchCVParam("NMRCV", "UNIFORM").getAccession());
            acquParameters.setSamplingStrategy(cvTerm);

            //////////////////////

            /* fill in the data */
            /* set acquisition parameters */
            parameterSet.setDirectDimensionParameterSet(acquParameters);
            Acquisition1DType acquisition1DType = objectFactory.createAcquisition1DType();
            acquisition1DType.setAcquisitionParameterSet(parameterSet);
            AcquisitionType acquisitionType = objectFactory.createAcquisitionType();
            acquisitionType.setAcquisition1D(acquisition1DType);
            parameterSet.setPulseSequence(pulseSequence);


            /* set contact information */
            ContactListType contactListType = objectFactory.createContactListType();
            contactListType.getContact().add(contactType);
            nmrMLType.setContactList(contactListType);

            /* set other parameters */
            nmrMLType.setSoftwareList(softwareListType);

            InstrumentConfigurationListType instrumentConfigurationListType =
                    (nmrMLType.getInstrumentConfigurationList()==null)?
                    objectFactory.createInstrumentConfigurationListType():nmrMLType.getInstrumentConfigurationList();
            instrumentConfigurationListType.getInstrumentConfiguration().add(instrumentConfigurationType);
            nmrMLType.setInstrumentConfigurationList(instrumentConfigurationListType);

            nmrMLType.setAcquisition(acquisitionType);

            return nmrMLType;
        }

        public ByteOrder getByteOrder() {
            return byteOrder;
        }

        public int getBiteSyze() {
            return biteSyze;
        }


    }

    private void loadSourceFileRefs() {
        for (SourceFileType sourceFileType : nmrMLType.getSourceFileList().getSourceFile()) {
            if (sourceFileType.getId().matches("PULSEPROGRAM_FILE")) {
                SourceFileRefType sourceFileRefType = objectFactory.createSourceFileRefType();
                sourceFileRefType.setRef(sourceFileType);

                PulseSequenceType.PulseSequenceFileRefList pulseSequenceFileRefList =
                        objectFactory.createPulseSequenceTypePulseSequenceFileRefList();
                pulseSequenceFileRefList.getSourceFileRef().add(sourceFileRefType);

                nmrMLType.getAcquisition().getAcquisition1D().getAcquisitionParameterSet().getPulseSequence()
                        .setPulseSequenceFileRefList(pulseSequenceFileRefList);

            }
            if (sourceFileType.getId().matches("ACQUISITION_FILE")) {
                SourceFileRefType sourceFileRefType = objectFactory.createSourceFileRefType();
                sourceFileRefType.setRef(sourceFileType);

                SourceFileRefListType sourceFileRefListType = objectFactory.createSourceFileRefListType();
                sourceFileRefListType.getSourceFileRef().add(sourceFileRefType);

                nmrMLType.getAcquisition().getAcquisition1D().getAcquisitionParameterSet()
                        .setAcquisitionParameterFileRefList(sourceFileRefListType);

            }
            if (sourceFileType.getId().matches("FID_FILE")) {
                SourceFileRefType sourceFileRefType = objectFactory.createSourceFileRefType();
                sourceFileRefType.setRef(sourceFileType);
            }
        }
    }


}
