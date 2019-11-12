/*
 * CC-BY 4.0
 */

package org.nmrml.parser.bruker;

import org.nmrml.parser.Acqu;
import org.nmrml.parser.Proc;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.ByteOrder;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Reader for Bruker's proc and procs files
 *
 * @author Luis F. de Figueiredo
 *
 * User: ldpf
 * Date: 14/01/2013
 * Time: 14:12
 *
 */
public class BrukerProcReader implements ProcReader {

    private BufferedReader procFile;
    // parameters from proc
    private final static Pattern REGEXP_TITLE   = Pattern.compile("\\#\\#TITLE= (.+), (\\S+) ?\t?\t?(.+)"); // origin
    private final static Pattern REGEXP_OFFSET  = Pattern.compile("\\#\\#\\$OFFSET= (\\d+\\.\\d+)"); //OFFSET
    private final static Pattern REGEXP_SI      = Pattern.compile("\\#\\#\\$SI= (\\d+)"); //transform size (complex)
    private final static Pattern REGEXP_SF      = Pattern.compile("\\#\\#\\$SF= (\\d+\\.\\d+)"); //frequency of 0 ppm (???)
    private final static Pattern REGEXP_WDW     = Pattern.compile("\\#\\#\\$WDW= (\\d+)"); //window function type
    private final static Pattern REGEXP_LB      = Pattern.compile("\\#\\#\\$LB= (\\S+)"); //line broadening
    private final static Pattern REGEXP_GB      = Pattern.compile("\\#\\#\\$GB= (\\d+\\.\\d+)"); //GB-factor (Gain?)
    private final static Pattern REGEXP_SSB     = Pattern.compile("\\#\\#\\$SSB= (-?\\d+\\.\\d+)"); //sine bell shift
    private final static Pattern REGEXP_TM1     = Pattern.compile("\\#\\#\\$SSB= (-?\\d+\\.\\d+)"); //Left trapezoid
    private final static Pattern REGEXP_TM2     = Pattern.compile("\\#\\#\\$SSB= (-?\\d+\\.\\d+)"); //Right trapezoid
    private final static Pattern REGEXP_PH_MODE = Pattern.compile("\\#\\#\\$PH\\_mod= (\\d+)"); //phasing type
    private final static Pattern REGEXP_PHC0    = Pattern.compile("\\#\\#\\$PHC0= (-?\\d+\\.\\d+)"); //zero order phase
    private final static Pattern REGEXP_PHC1    = Pattern.compile("\\#\\#\\$PHC1= (-?\\d+\\.\\d+)"); //first order phase
    private final static Pattern REGEXP_MC2     = Pattern.compile("\\#\\#\\$MC2= (\\d+)"); //F1 detection mode
    private final static Pattern REGEXP_BYTORDP = Pattern.compile("\\#\\#\\$BYTORDP= (\\d+)"); //byte order
    private final static Pattern REGEXP_DTYPP   = Pattern.compile("\\#\\#\\$DTYPP= (\\d+)"); //data type (0 -> 32 bit int, 1 -> 64 bit double)
    private final static Pattern REGEXP_TDEFF   = Pattern.compile("\\#\\#\\$TDeff= (\\d+)"); // number of datapoints in the real and imaginary files

    // *** Additionnal parameters ***
    private final static Pattern REGEXP_BLC_MODE     = Pattern.compile("\\#\\#\\$BLC\\_mod= (.+)"); //baseline correction type
    private final static Pattern REGEXP_SOLVENT_MODE = Pattern.compile("\\#\\#\\$SOLVENT\\_mod= (\\S+)"); //solvent suppression type
    private final static Pattern REGEXP_GRPDELAY     = Pattern.compile("\\#\\#\\$GRPDELAY= (\\d+)"); // Group Delay (count unit)
    private final static Pattern REGEXP_USER         = Pattern.compile("\\#\\#\\$USER= (.+)"); // User
    private final static Pattern REGEXP_EMAIL        = Pattern.compile("\\#\\#\\$EMAIL= (.+)"); // Email
    private final static Pattern REGEXP_REF_CMPD     = Pattern.compile("\\#\\#\\$REF_cmpd= (.+)"); // Spectral referencing : Compound Name
    private final static Pattern REGEXP_REF_PPM      = Pattern.compile("\\#\\#\\$REF_ppm= (\\d+\\.\\d+)"); // Spectral referencing : ppm value

    public BrukerProcReader(File procFile) throws FileNotFoundException {
        this.procFile = new BufferedReader(new FileReader(procFile));
    }

    public BrukerProcReader(String filename) throws FileNotFoundException {
        this(new File(filename));
    }

    public BrukerProcReader(InputStream procFileInputStream) throws FileNotFoundException {
        this.procFile = new BufferedReader(new InputStreamReader(procFileInputStream));
    }

    @Override
    public Proc read() throws IOException{
        Proc processing = null;
        try {
            processing = new Proc();
        } catch (Exception e) {
            e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
        }
        Matcher matcher;
        String line = procFile.readLine();
        while (procFile.ready() && (line != null)) {
            /* extract software metadata */
            if(REGEXP_TITLE.matcher(line).find()){
                matcher = REGEXP_TITLE.matcher(line);
                matcher.find();
                processing.setSoftware(matcher.group(2).toUpperCase());
                processing.setSoftVersion(matcher.group(3));
            }
            //transform size (complex)
            if(REGEXP_SI.matcher(line).find()){
                matcher=REGEXP_SI.matcher(line);
                matcher.find();
                processing.setTransformSize(Integer.parseInt(matcher.group(1)));
            }
            //OFFSET
            if(REGEXP_OFFSET.matcher(line).find()){
                matcher=REGEXP_OFFSET.matcher(line);
                matcher.find();
                processing.setMaxPpm(Double.parseDouble(matcher.group(1)));
            }
            //window function type
            if(REGEXP_WDW.matcher(line).find()){
                matcher=REGEXP_WDW.matcher(line);
                matcher.find();
                processing.setWindowFunctionType(Integer.parseInt(matcher.group(1)));
            }
            //phasing type
            if(REGEXP_PH_MODE.matcher(line).find()){
                matcher=REGEXP_PH_MODE.matcher(line);
                matcher.find();
                processing.setPhasingType(Integer.parseInt(matcher.group(1)));
            }
            //F1 detection mode
            if(REGEXP_MC2.matcher(line).find()){
                matcher=REGEXP_MC2.matcher(line);
                matcher.find();
                processing.setF1DetectionMode(Integer.parseInt(matcher.group(1)));
            }
            //frequency of 0 ppm (???)
            if (REGEXP_SF.matcher(line).find()){
                matcher = REGEXP_SF.matcher(line);
                matcher.find();
                processing.setZeroFrequency(Double.parseDouble(matcher.group(1)));
            }
            //line broadening
            if(REGEXP_LB.matcher(line).find()){
                matcher=REGEXP_LB.matcher(line);
                matcher.find();
                processing.setLineBroadening(Double.parseDouble(matcher.group(1)));
            }
            //GB-factor (Gain?)
            if (REGEXP_GB.matcher(line).find()){
                matcher = REGEXP_GB.matcher(line);
                matcher.find();
                processing.setGbFactor(Double.parseDouble(matcher.group(1)));
            }
            //left trapezoid limit
            if (REGEXP_TM1.matcher(line).find()){
                matcher = REGEXP_TM1.matcher(line);
                matcher.find();
                processing.setLeftTrap(Double.parseDouble(matcher.group(1)));
            }
            //Right trapezoid limit
            if (REGEXP_TM2.matcher(line).find()){
                matcher = REGEXP_TM2.matcher(line);
                matcher.find();
                processing.setRightTrap(Double.parseDouble(matcher.group(1)));
            }
            //zero order phase
            if (REGEXP_PHC0.matcher(line).find()){
                matcher = REGEXP_PHC0.matcher(line);
                matcher.find();
                processing.setZeroOrderPhase(Double.parseDouble(matcher.group(1)));
            }
            //first order phase
            if (REGEXP_PHC1.matcher(line).find()){
                matcher = REGEXP_PHC1.matcher(line);
                matcher.find();
                processing.setFirstOrderPhase(Double.parseDouble(matcher.group(1)));
            }
            //sine bell shift
            if (REGEXP_SSB.matcher(line).find()){
                matcher = REGEXP_SSB.matcher(line);
                matcher.find();
                processing.setSsb(Double.parseDouble(matcher.group(1)));
            }
            // number of datapoints in the real and imaginary files
            if (REGEXP_TDEFF.matcher(line).find()){
                matcher = REGEXP_TDEFF.matcher(line);
                matcher.find();
                processing.setTdEffective(Integer.parseInt(matcher.group(1)));
            }
            /* byte order */
            if (REGEXP_BYTORDP.matcher(line).find()){
                matcher = REGEXP_BYTORDP.matcher(line);
                matcher.find();
                switch (Integer.parseInt(matcher.group(1))){
                    case 0 :
                        processing.setByteOrder(ByteOrder.LITTLE_ENDIAN);
                        break;
                    case 1 :
                        processing.setByteOrder(ByteOrder.BIG_ENDIAN);
                        break;
                    default:
                        break;
                }
            }
            /* integer type */
            if (REGEXP_DTYPP.matcher(line).find()) {
                matcher = REGEXP_DTYPP.matcher(line);
                matcher.find();
                processing.set32Bit((Pattern.compile("0").matcher(matcher.group(1)).find()));
                switch (Integer.parseInt(matcher.group(1))) {
                    case 0:
                        processing.setBiteSyze(4);   // 32 bits integer - 4 octets
                        break;
                    case 1:
                        processing.setBiteSyze(8);   // 64 bits integer - 8 octets
                        break;
                    default:
                        processing.setBiteSyze(4);   // 32 bits integer
                        break;
                }
            }
            //baseline correction type
            if(REGEXP_BLC_MODE.matcher(line).find()){
                matcher=REGEXP_BLC_MODE.matcher(line);
                matcher.find();
                processing.setBaselineCorrectionType(matcher.group(1));
            }
            //solvent suppression type
            if(REGEXP_SOLVENT_MODE.matcher(line).find()){
                matcher=REGEXP_SOLVENT_MODE.matcher(line);
                matcher.find();
                processing.setSolventSuppressionType(matcher.group(1));
            }
            // Group Delay
            if (REGEXP_GRPDELAY.matcher(line).find()){
                matcher = REGEXP_GRPDELAY.matcher(line);
                matcher.find();
                processing.setGroupDelay(Integer.parseInt(matcher.group(1)));
            }
            // User
            if (REGEXP_USER.matcher(line).find()){
                matcher = REGEXP_USER.matcher(line);
                matcher.find();
                processing.setUser(matcher.group(1));
            }
            // Email
            if (REGEXP_EMAIL.matcher(line).find()){
                matcher = REGEXP_EMAIL.matcher(line);
                matcher.find();
                processing.setEmail(matcher.group(1));
            }
            // Spectral referencing : Compound Name
            if (REGEXP_REF_CMPD.matcher(line).find()){
                matcher = REGEXP_REF_CMPD.matcher(line);
                matcher.find();
                processing.setRef_cmpd(matcher.group(1));
            }
            // Spectral referencing : ppm value
            if (REGEXP_REF_PPM.matcher(line).find()){
                matcher = REGEXP_REF_PPM.matcher(line);
                matcher.find();
                processing.setRef_ppm(Double.parseDouble(matcher.group(1)));
            }
            line = procFile.readLine();
        }
        procFile.close();
        return processing;
    }
}
