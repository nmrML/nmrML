/*
 * CC-BY 4.0
 */

package org.nmrml.parser;

import java.nio.ByteOrder;
import java.math.BigInteger;


/**
 * Data structure for the acquisition parameters
 *
 * @author  Luis F. de Figueiredo
 *
 * User: ldpf
 * Date: 14/01/2013
 * Time: 14:01
 *
 */
public class Acqu {

    //TODO use an enum for parameters that have a limited set of options such as aquisition mode
    private double transmiterFreq;               //sfo1
    private double decoupler1Freq;               //sfo2
    private double decoupler2Feq;                //sfo3
    private double freqOffset;                   //o1 (Hz)
    private double spectralFrequency;            //BF1 (Hz)
    private double spectralWidth;                //sw            sweep width (ppm)
    private double spectralWidthHz;              //sw_h          sweep width (Hz)
    private int aquiredPoints;                   //td            acquired points (real + imaginary)
    private int dspDecimation;                   //decim         DSP decimation factor
    private int dspFirmware;                     //dspfvs        DSP firmware version
    private double dspGroupDelay;                //grpdly        DSP group delay
    private int filterType;                      //digmod        filter type
    private double relaxationDelay;              //d[1]          relaxation delay D1
    private double pulseWidth;                   //p[1]          pulse width P1
    private int spiningRate;                     //masr          spinning rate
    private double temperature;                  //te            temperature of the experiment
    private BigInteger numberOfScans;            //ns            number of scans
    private BigInteger numberOfSteadyStateScans; //ds            number of dummy (steady state) scans
    private boolean integerType;                 //dtypa         data type (0 -> 32 bit int, 1 -> 64 bit double)
    private String pulseProgram;                 //pulprog       pulse program
    private String observedNucleus;              //nuc1          observed nucleus
    private String decoupledNucleus;             //nuc2          decoupled nucleus
    private String instrumentName;               //instrum       instrument name
    private String solvent;                      //solvent       solvent
    private String probehead;                    //probehead     probehead
    private String dataFormat;                   //              Data Format
    private String software;                     //title         software contained in title
    private String softVersion;                  //title         software version contained in title
    private String origin;                       //origin        origin
    private String owner;                        //owner         owner
    private String email;                        //email         email
    private AcquisitionMode acquisitionMode;     //aq_mod        acquisition mode
    private FidData fidType;                     //fid_type      define in class data_par
    private ByteOrder byteOrder;                 //bytorda       byte order (0 -> Little endian, 1 -> Big Endian)
    private int biteSyze;                        //dtypa         data type (0 -> 32 bit int, 1 -> 64 bit double)
    private long dataOffset;                     //Data_Start    JEOL only: Pointer (offset) into the JDF file where data start  (in octets)
    private long dataLength;                     //Data_Lenght   JEOL only: Data length into the JDF file from data start  (in octets)

    private Spectrometer spectrometer;

    public enum Spectrometer {BRUKER, VARIAN, JEOL}

    public Acqu() { }

    public Acqu(Spectrometer spectrometer) {
        this.spectrometer=spectrometer;
    }

    public double getTransmiterFreq() {
        return transmiterFreq;
    }

    public void setTransmiterFreq(double transmiterFreq) {
        this.transmiterFreq = transmiterFreq;
    }

    public double getDecoupler1Freq() {
        return decoupler1Freq;
    }

    public void setDecoupler1Freq(double decoupler1Freq) {
        this.decoupler1Freq = decoupler1Freq;
    }

    public double getDecoupler2Feq() {
        return decoupler2Feq;
    }

    public void setDecoupler2Feq(double decoupler2Feq) {
        this.decoupler2Feq = decoupler2Feq;
    }

    public double getFreqOffset() {
        return freqOffset;
    }

    public void setFreqOffset(double freqOffset) {
        this.freqOffset = freqOffset;
    }

    public double getSpectralWidth() {
        return spectralWidth;
    }

    public void setSpectralWidth(double spectralWidth) {
        this.spectralWidth = spectralWidth;
    }

    public double getSpectralWidthHz() {
        return spectralWidthHz;
    }

    public void setSpectralWidthHz(double spectralWidthHz) {
        this.spectralWidthHz = spectralWidthHz;
    }

    public int getAquiredPoints() {
        return aquiredPoints;
    }

    public void setAquiredPoints(int aquiredPoints) {
        this.aquiredPoints = aquiredPoints;
    }

    public int getDspDecimation() {
        return dspDecimation;
    }

    public void setDspDecimation(int dspDecimation) {
        this.dspDecimation = dspDecimation;
    }

    public int getDspFirmware() {
        return dspFirmware;
    }

    public void setDspFirmware(int dspFirmware) {
        this.dspFirmware = dspFirmware;
    }

    public double getDspGroupDelay() {
        return dspGroupDelay;
    }

    public void setDspGroupDelay(double dspGroupDelay) {
        this.dspGroupDelay = dspGroupDelay;
    }

    public ByteOrder getByteOrder() {
        return byteOrder;
    }

    public void setByteOrder(ByteOrder byteOrder) {
        this.byteOrder = byteOrder;
    }

    public int getBiteSyze() {
        return biteSyze;
    }

    public void setDataOffset(long offset) {
        this.dataOffset = offset;
    }

    public long getDataOffset() {
        return dataOffset;
    }

    public void setDataLength(long length) {
        this.dataLength = length;
    }

    public long getDataLength() {
        return dataLength;
    }

    public void setBiteSyze(int biteSyze) {
        this.biteSyze = biteSyze;
    }

    public AcquisitionMode getAcquisitionMode() {
        return acquisitionMode;
    }

    public void setAcquisitionMode(int acquisitionMode) {
        for (AcquisitionMode mode : AcquisitionMode.values())
            if (mode.type == acquisitionMode)
                this.acquisitionMode = mode;
    }
    public void setAcquisitionMode(AcquisitionMode mode) {
        this.acquisitionMode=mode;

    }

    public int getFilterType() {
        return filterType;
    }

    public void setFilterType(int filterType) {
        this.filterType = filterType;
    }

    public double getRelaxationDelay() {
        return relaxationDelay;
    }

    public void setRelaxationDelay(double relaxationDelay) {
        this.relaxationDelay = relaxationDelay;
    }

    public double getPulseWidth() {
        return pulseWidth;
    }

    public void setPulseWidth(double pulseWidth) {
        this.pulseWidth = pulseWidth;
    }

    public int getSpiningRate() {
        return spiningRate;
    }

    public void setSpiningRate(int spiningRate) {
        this.spiningRate = spiningRate;
    }

    public double getTemperature() {
        return temperature;
    }

    public void setTemperature(double temperature) {
        this.temperature = temperature;
    }

    public BigInteger getNumberOfScans() {
        return numberOfScans;
    }

    public void setNumberOfScans(BigInteger numberOfScans) {
        this.numberOfScans = numberOfScans;
    }

    public BigInteger getNumberOfSteadyStateScans() {
        return numberOfSteadyStateScans;
    }

    public void setNumberOfSteadyStateScans(BigInteger numberOfSteadyStateScans) {
        this.numberOfSteadyStateScans = numberOfSteadyStateScans;
    }

    public String getPulseProgram() {
        return pulseProgram;
    }

    public void setPulseProgram(String pulseProgram) {
        this.pulseProgram = pulseProgram;
    }

    public String getObservedNucleus() {
        return observedNucleus;
    }

    public void setObservedNucleus(String observedNucleus) {
        this.observedNucleus = observedNucleus;
    }

    public String getDecoupledNucleus() {
        return decoupledNucleus;
    }

    public void setDecoupledNucleus(String decoupledNucleus) {
        this.decoupledNucleus = decoupledNucleus;
    }

    public String getInstrumentName() {
        return instrumentName;
    }

    public void setInstrumentName(String instrumentName) {
        this.instrumentName = instrumentName;
    }

    public boolean is32Bit() {
        return integerType;
    }

    public void set32Bit(boolean is32Bit) {
        fidType=(is32Bit)?FidData.INT32:FidData.DOUBLE;
        this.integerType = is32Bit;
    }

    public String getSolvent() {
        return solvent;
    }

    public void setSolvent(String solvent) {
        this.solvent = solvent;
    }

    public String getProbehead() {
        return probehead;
    }

    public void setProbehead(String probehead) {
        this.probehead = probehead;
    }

    public String getSoftware() {
        return software;
    }

    public void setSoftware(String software) {
        this.software = software;
    }

    public String getSoftVersion() {
        return softVersion;
    }

    public void setSoftVersion(String softVersion) {
        this.softVersion = softVersion;
    }

    public String getOrigin() {
        return origin;
    }

    public void setOrigin(String origin) {
        this.origin = origin;
    }

    public String getOwner() {
        return owner;
    }

    public void setOwner(String owner) {
        this.owner = owner;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public FidData getFidType() {
        return fidType;
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

    public double getSpectralFrequency() {
        return spectralFrequency;
    }

    public void setSpectralFrequency(double spectralFrequency) {
        this.spectralFrequency = spectralFrequency;
    }

    public Spectrometer getSpectrometer() {
        return spectrometer;
    }
}
