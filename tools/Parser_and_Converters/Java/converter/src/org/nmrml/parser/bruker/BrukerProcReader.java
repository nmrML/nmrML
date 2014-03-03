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
    private static Acqu acquisition;
    // parameters from proc
    private final static Pattern REGEXP_OFFSET = Pattern.compile("\\#\\#\\$OFFSET= (\\d+\\.\\d+)"); //OFFSET
    private final static Pattern REGEXP_SI = Pattern.compile("\\#\\#\\$SI= (\\d+)"); //transform size (complex)
    private final static Pattern REGEXP_SF = Pattern.compile("\\#\\#\\$SF= (\\d+\\.\\d+)"); //frequency of 0 ppm (???)
    private final static Pattern REGEXP_GB = Pattern.compile("\\#\\#\\$GB= (\\d+\\.\\d+)"); //GB-factor (Gain?)
    private final static Pattern REGEXP_LB = Pattern.compile("\\#\\#\\$LB= (\\S+)"); //line broadening
    private final static Pattern REGEXP_WDW = Pattern.compile("\\#\\#\\$WDW= (\\d+)"); //window function type
    private final static Pattern REGEXP_PH_MODE = Pattern.compile("\\#\\#\\$PH\\_mod= (\\d+)"); //phasing type
    private final static Pattern REGEXP_PHC0 = Pattern.compile("\\#\\#\\$PHC0= (-?\\d+\\.\\d+)"); //zero order phase
    private final static Pattern REGEXP_PHC1 = Pattern.compile("\\#\\#\\$PHC1= (-?\\d+\\.\\d+)"); //first order phase
    private final static Pattern REGEXP_SSB = Pattern.compile("\\#\\#\\$SSB= (-?\\d+\\.\\d+)"); //sine bell shift
    private final static Pattern REGEXP_MC2 = Pattern.compile("\\#\\#\\$MC2= (\\d+)"); //F1 detection mode
    private final static Pattern REGEXP_BYTORDA = Pattern.compile("\\#\\#\\$BYTORDP= (\\d+)"); //byte order
    private final static Pattern REGEXP_DTYPP = Pattern.compile("\\#\\#\\$DTYPP= (\\d+)"); //data type (0 -> 32 bit int, 1 -> 64 bit double)
    private final static Pattern REGEXP_TDEFF = Pattern.compile("\\#\\#\\$TDeff= (\\d+)"); // number of datapoints in the real and imaginary files

    public BrukerProcReader(File procFile, Acqu acquisition) throws FileNotFoundException {
        this.procFile = new BufferedReader(new FileReader(procFile));
        this.acquisition=acquisition;
    }

    public BrukerProcReader(String filename) throws FileNotFoundException {
        this(new File(filename),acquisition);
    }

    public BrukerProcReader(InputStream procFileInputStream, Acqu acquisition) throws FileNotFoundException {
        this.procFile = new BufferedReader(new InputStreamReader(procFileInputStream));
        this.acquisition=acquisition;
    }

    @Override
    public Proc read() throws IOException{
        Proc processing = null;
        try {
            processing = new Proc(acquisition);
        } catch (Exception e) {
            e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
        }
        Matcher matcher;
//        Acqu acquisition = new Acqu(Acqu.Spectrometer.BRUKER);
        String line = procFile.readLine();
        while (procFile.ready() && (line != null)) {
            if(REGEXP_SI.matcher(line).find()){
                matcher=REGEXP_SI.matcher(line);
                matcher.find();
                processing.setTransformSize(Integer.parseInt(matcher.group(1)));
            }
            if(REGEXP_OFFSET.matcher(line).find()){
                matcher=REGEXP_OFFSET.matcher(line);
                matcher.find();
                processing.setOffset(Double.parseDouble(matcher.group(1)));
            }
            if(REGEXP_WDW.matcher(line).find()){
                matcher=REGEXP_WDW.matcher(line);
                matcher.find();
                processing.setWindowFunctionType(Integer.parseInt(matcher.group(1)));
            }
            if(REGEXP_PH_MODE.matcher(line).find()){
                matcher=REGEXP_PH_MODE.matcher(line);
                matcher.find();
                processing.setPhasingType(Integer.parseInt(matcher.group(1)));
            }
            if(REGEXP_MC2.matcher(line).find()){
                matcher=REGEXP_MC2.matcher(line);
                matcher.find();
                processing.setF1DetectionMode(Integer.parseInt(matcher.group(1)));
            }
            if (REGEXP_SF.matcher(line).find()){
                matcher = REGEXP_SF.matcher(line);
                matcher.find();
                processing.setZeroFrequency(Double.parseDouble(matcher.group(1)));
            }
            if(REGEXP_LB.matcher(line).find()){
                matcher=REGEXP_LB.matcher(line);
                matcher.find();
                processing.setLineBroadening(Double.parseDouble(matcher.group(1)));
            }
            if (REGEXP_GB.matcher(line).find()){
                matcher = REGEXP_GB.matcher(line);
                matcher.find();
                processing.setGbFactor(Double.parseDouble(matcher.group(1)));
            }
            if (REGEXP_PHC0.matcher(line).find()){
                matcher = REGEXP_PHC0.matcher(line);
                matcher.find();
                processing.setZeroOrderPhase(Double.parseDouble(matcher.group(1)));
            }
            if (REGEXP_PHC1.matcher(line).find()){
                matcher = REGEXP_PHC1.matcher(line);
                matcher.find();
                processing.setFirstOrderPhase(Double.parseDouble(matcher.group(1)));
            }
            if (REGEXP_SSB.matcher(line).find()){
                matcher = REGEXP_SSB.matcher(line);
                matcher.find();
                processing.setSsb(Double.parseDouble(matcher.group(1)));
            }
            if (REGEXP_TDEFF.matcher(line).find()){
                matcher = REGEXP_TDEFF.matcher(line);
                matcher.find();
                processing.setTdEffective(Integer.parseInt(matcher.group(1)));
            }
            if (REGEXP_BYTORDA.matcher(line).find()){
                matcher = REGEXP_BYTORDA.matcher(line);
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
            if (REGEXP_DTYPP.matcher(line).find()) {
                matcher = REGEXP_DTYPP.matcher(line);
                matcher.find();
                processing.set32Bit((Pattern.compile("0").matcher(matcher.group(1)).find()));
            }
            line = procFile.readLine();
        }
        procFile.close();
        return processing;
    }
}
