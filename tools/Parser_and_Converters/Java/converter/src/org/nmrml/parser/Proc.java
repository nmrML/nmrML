/*
 * CC-BY 4.0
 */

package org.nmrml.parser;

import java.nio.ByteOrder;

/**
 * Data structure for the spectra processing parameters.
 *
 * @author  Luis F. de Figueiredo
 *
 * User: ldpf
 * Date: 14/01/2013
 * Time: 14:02
 *
 */
public class Proc {

    private int windowFunctionType;         //wdw               window function type
    private int phasingType;                //ph_mod            phasing type

    private int f1DetectionMode;            //mc2               F1 detection mode
    private double zeroFrequency;           //sf                frequency of 0 ppm
    private double lineBroadening;          //lb                line broadening (in Hz?)
    private double gbFactor;                //gb                GB-factor
    private double leftTrap;                //TM1               left trapezoid limit
    private double rightTrap;               //TM2               right trapezoid limit
    private double zeroOrderPhase;          //phc0              zero order phase
    private double firstOrderPhase;         //phc1              first order phase
    private double ssb;                     //ssb               sine bell shift
    private double ssbSine;                 //ssbSine           sine bell shift
    private double ssbSineSquared;          //ssbSineSquared    sine bell shift
    private ByteOrder byteOrder;            //bytordp           byte order (0 -> Little endian, 1 -> Big Endian)
    private int biteSyze;                   //dtypp             data type (0 -> 32 bit int, 1 -> 64 bit double)
    private boolean integerType;            //dtypp             data type (0 -> 32 bit int, 1 -> 64 bit double)

    // obtained after reading the FID but could it be obtained from the Bruker?
    private int transformSize;              //si                transform size (complex)
    private double dwellTime;               //dw                dwell time (in s)
    private double hertzPerPoint;           //hzperpt
    private double ppmPerPoint;             //ppmperpt
    private double spectraWidthHertz;       //sw_h

    private double maxPpm;                  //offset
    private double minPpm;                  //maxPpm - spectralWidthHz/spectralFrequency
    //TODO consider moving this to the Fourier Transformed class or processing class....
    // variables required later...
    private int tdEffective;                //td_eff        apodization::transform::do_fft
    private int leftShift=0;                //leftshift     ft_settings_dialog::ft_settings_dialog
    private int shift;                      //j             apodization::transform::do_fft
    private int increment;                  //i             apodization::transform::do_fft
    private double dspPhase;

    private String software;                //title         software contained in title
    private String softVersion;             //title         software version contained in title

    // *** Additionnal parameters ***
    private String solventSuppressionType;  //solvent_mod   solvent suppression type
    private String baselineCorrectionType;  //BLC_mod       baseline correction type
    private int groupDelay;                 //GRPDELAY      Group Delay
    private String user;                    //user          
    private String email;                   //email         
    private String ref_cmpd;                //REF_cmpd      Spectra referencing : Compound Name
    private double ref_ppm;                 //REF_ppm       Spectra referencing : ppm value

    public Proc() {}

    public Proc(Acqu acquisition) throws Exception{

        // set the size for the fourier Transform
        // perhaps I should check first if I can use the data from the Proc file..??
        if (acquisition.getAquiredPoints() < 1*1024) this.transformSize =1024;
        else if (acquisition.getAquiredPoints()<= 2 * 1024) this.transformSize=2*1024;
        else if (acquisition.getAquiredPoints() <= 4 * 1024) this.transformSize=4*1024;
        else if (acquisition.getAquiredPoints() <= 8 * 1024) this.transformSize=8*1024;
        else if (acquisition.getAquiredPoints() <= 16 * 1024) this.transformSize=16*1024;
        else if (acquisition.getAquiredPoints() <= 32 * 1024) this.transformSize=32*1024;
        else if (acquisition.getAquiredPoints() <= 64 * 1024) this.transformSize=64*1024;
        else if (acquisition.getAquiredPoints() <= 128* 1024) this.transformSize=128*1024;
        else if (acquisition.getAquiredPoints() <= 256* 1024) this.transformSize=256*1024;
        else this.transformSize=512 * 1024;
        //set the dwell time (in s) to display the timeline of the fid (dw is distance between points)
        if(acquisition.getSpectralWidth() == 0 | acquisition.getTransmiterFreq() == 0)
            throw new Exception ("Some acquisition parameters are null");
        this.dwellTime = 1.0/(2 * acquisition.getSpectralWidth() * acquisition.getTransmiterFreq());
        this.hertzPerPoint = acquisition.getSpectralWidth() * acquisition.getTransmiterFreq() / transformSize;
        this.ppmPerPoint = acquisition.getSpectralWidth() / transformSize;
        this.spectraWidthHertz = acquisition.getSpectralWidth() * acquisition.getTransmiterFreq();
        this.maxPpm = (acquisition.getTransmiterFreq()- zeroFrequency) * 1.0e06 +
                (acquisition.getSpectralWidth()* acquisition.getTransmiterFreq()) / 2.0;

        // set the position where the shift starts???
        switch (acquisition.getAcquisitionMode()) {
            case DISP:
            case SIMULTANIOUS:
                shift=2*leftShift;
                break;
            case SEQUENTIAL:
                shift=leftShift;
                break;
            default:
                break;
        }

        //set the number of acquired points we are going to work with
        tdEffective=(acquisition.getAquiredPoints()<=2*transformSize)?
                acquisition.getAquiredPoints():                     // normal case
                2*transformSize;                                  // fid data is truncated in the nonsense case

    }

    public int getTransformSize() {
        return transformSize;
    }

    public void setTransformSize(int transformSize) {
        this.transformSize = transformSize;
    }

    // Window Function Type
    public int getWindowFunctionType() {
        return windowFunctionType;
    }
    public void setWindowFunctionType(int windowFunctionType) {
        this.windowFunctionType = windowFunctionType;
    }

    // Phasing Type
    public int getPhasingType() {
        return phasingType;
    }
    public void setPhasingType(int phasingType) {
        this.phasingType = phasingType;
    }

    public int getF1DetectionMode() {
        return f1DetectionMode;
    }

    public void setF1DetectionMode(int f1DetectionMode) {
        this.f1DetectionMode = f1DetectionMode;
    }

    public double getZeroFrequency() {
        return zeroFrequency;
    }

    public void setZeroFrequency(double zeroFrequency) {
        this.zeroFrequency = zeroFrequency;
    }

    public double getLineBroadening() {
        return lineBroadening;
    }

    public void setLineBroadening(double lineBroadening) {
        this.lineBroadening = lineBroadening;
    }

    public double getGbFactor() {
        return gbFactor;
    }

    public void setGbFactor(double gbFactor) {
        this.gbFactor = gbFactor;
    }

    public double getLeftTrap() {
        return leftTrap;
    }

    public void setLeftTrap(double leftTrap) {
        this.leftTrap = leftTrap;
    }

    public double getRightTrap() {
        return rightTrap;
    }

    public void setRightTrap(double rightTrap) {
        this.rightTrap = rightTrap;
    }

    public double getZeroOrderPhase() {
        return zeroOrderPhase;
    }

    public void setZeroOrderPhase(double zeroOrderPhase) {
        this.zeroOrderPhase = zeroOrderPhase;
    }

    public double getFirstOrderPhase() {
        return firstOrderPhase;
    }

    public void setFirstOrderPhase(double firstOrderPhase) {
        this.firstOrderPhase = firstOrderPhase;
    }

    public double getMaxPpm() {
        return maxPpm;
    }

    public void setMaxPpm(double maxPpm) {
        this.maxPpm = maxPpm;
    }

    public double getMinPpm() {
        return minPpm;
    }

    public void setMinPpm(double minPpm) {
        this.minPpm = minPpm;
    }

    public double getSsb() {
        return ssb;
    }

    public void setSsb(double ssb) {
        this.ssb = ssb;
        // if ssb is given in degrees this converts it to the inverse of coefficient in front to the Pi
        // 360 = 2 Pi => angle/180 = coefficient (e.g. 360/180 = 2 Pi)
        // This variables are used in the apodizationTool method sine and Co.
        if (ssb >= 1)                //convert Bruker convention to degrees
            ssb = 180.0 / ssb;
        else
              ssb = 0.0;
        // I do not get this... (see source code)
        this.ssbSine = ssb;
        this.ssbSineSquared = ssb;
    }

    public double getSsbSine() {
        return ssbSine;
    }

    public double getSsbSineSquared() {
        return ssbSineSquared;
    }

    public int getTdEffective() {
        return tdEffective;
    }

    public void setTdEffective(int tdEffective) {
        this.tdEffective = tdEffective;
    }

    public int getLeftShift() {
        return leftShift;
    }

    public void setLeftShift(int leftShift) {
        this.leftShift = leftShift;
    }

    public int getShift() {
        return shift;
    }

    public void setShift(int shift) {
        this.shift = shift;
    }

    public int getIncrement() {
        return increment;
    }

    public void setIncrement(int increment) {
        this.increment = increment;
    }

    public double getDwellTime() {
        return dwellTime;
    }

    public double getDspPhase() {
        return dspPhase;
    }

    public void setDspPhase(double dspPhase) {
        this.dspPhase = dspPhase;
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

    public void setBiteSyze(int biteSyze) {
        this.biteSyze = biteSyze;
    }

    public boolean is32Bit() {
        return integerType;
    }

    public void set32Bit(boolean integerType) {
        this.integerType = integerType;
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

// *** Additionnal parameters ***

    // Solvent Suppression Type
    public String getSolventSuppressionType() {
        return solventSuppressionType;
    }
    public void setSolventSuppressionType(String solventSuppressionType) {
        this.solventSuppressionType = solventSuppressionType;
    }

    // BaselineCorrectionType
    public String getBaselineCorrectionType() {
        return baselineCorrectionType;
    }
    public void setBaselineCorrectionType(String baselineCorrectionType) {
        this.baselineCorrectionType = baselineCorrectionType;
    }

    // GroupDelay
    public int getGroupDelay() {
        return groupDelay;
    }
    public void setGroupDelay(int groupDelay) {
        this.groupDelay = groupDelay;
    }

    // User
    public String getUser() {
        return user;
    }
    public void setUser(String user) {
        this.user = user;
    }

    // Email
    public String getEmail() {
        return email;
    }
    public void setEmail(String email) {
        this.email = email;
    }

    // Ref_cmpd
    public String getRef_cmpd() {
        return ref_cmpd;
    }
    public void setRef_cmpd(String ref_cmpd) {
        this.ref_cmpd = ref_cmpd;
    }

    // Ref_ppm
    public double getRef_ppm() {
        return ref_ppm;
    }
    public void setRef_ppm(double ref_ppm) {
        this.ref_ppm = ref_ppm;
    }

}
