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



import org.nmrml.model.Acquisition1DType;
import org.nmrml.model.AcquisitionDimensionParameterSetType;
import org.nmrml.model.AcquisitionType;
import org.nmrml.model.ContactType;
import org.nmrml.model.UnitsNames;
import org.nmrml.model.ValueWithUnitType;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.math.BigInteger;
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

    private BufferedReader inputAcqReader;
    private boolean is2D = false;

    // files for 2D nnmr
    private final static Pattern REGEXP_ACQU2 = Pattern.compile("acqu2"); //file name
    // parameters from acqu
    private final static Pattern REGEXP_SFO1 = Pattern.compile("\\#\\#\\$SFO1= (-?\\d+\\.\\d+)"); //transmitter frequency
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

    public BrukerAcquAbstractReader() {
    }
    
    public BrukerAcquAbstractReader(File acquFile) throws IOException {
//        Path path = Paths.get(acquFile.getPath());
//        is2D = REGEXP_ACQU2.matcher(path.toString()).find() || new File(path.getParent().toString()+"/acqu2").exists();
        inputAcqReader = new BufferedReader(new FileReader(acquFile));        
    }

    public BrukerAcquAbstractReader(String filename) throws IOException {
        this(new File(filename));
        // required parameters so far...
        // AquiredPoints: FidReader
        // SpectraWidth: FidReader
        // transmiterFreq: FidReader
        //
    }

    @Override
    public AcquisitionType read() throws IOException {
        AcquisitionType acquisition = new AcquisitionType();
        acquisition.setAcquisition1D(readDirectDimension());
        return acquisition;
    }


    private Acquisition1DType readDirectDimension() throws IOException{

        Acquisition1DType acquisition = new Acquisition1DType();
        Acquisition1DType.AcquisitionParameterSet parameterSet = new Acquisition1DType.AcquisitionParameterSet();
        parameterSet.setDirectDimensionParameterSet(readDimensionParameters());
        acquisition.setAcquisitionParameterSet(parameterSet);


        // just for the record to use in 2D nmr
//        AcquisitionParameterSet2DType parameterSet2DType = new AcquisitionParameterSet2DType();
//        parameterSet2DType.setDirectDimensionParameterSet(parameter);


        Matcher matcher;

        //TODO read contact details
        //contact parameters
        String line = inputAcqReader.readLine();
        ContactType contact = new ContactType();
        if (REGEXP_ORIGIN.matcher(line).find()) {
            matcher = REGEXP_ORIGIN.matcher(line);
            matcher.find();
            // probably not correct
            contact.setOrganization(matcher.group(1));
        }
        if (REGEXP_OWNER.matcher(line).find()) {
            matcher = REGEXP_OWNER.matcher(line);
            matcher.find();
            contact.setFullname(matcher.group(1));
        }


        return acquisition;
    }

    private AcquisitionDimensionParameterSetType readDimensionParameters() throws IOException {
        AcquisitionDimensionParameterSetType parameterSet= new AcquisitionDimensionParameterSetType();
        ValueWithUnitType value;
        Matcher matcher;
        String line = inputAcqReader.readLine();
        while (inputAcqReader.ready() && (line != null)) {
            if (REGEXP_SW.matcher(line).find()) {
                matcher = REGEXP_SW.matcher(line);
                matcher.find();
                value = new ValueWithUnitType();
                value.setValue(matcher.group(1));
                value.setUnitName(UnitsNames.PPM.name());
                parameterSet.setSweepWidth(value);
            }
            if (REGEXP_SW_H.matcher(line).find()) {
                matcher = REGEXP_SW_H.matcher(line);
                matcher.find();
                value = new ValueWithUnitType();
                value.setValue(matcher.group(1));
                value.setUnitName(UnitsNames.HZ.name());
                parameterSet.setSweepWidth(value);
            }
            if (REGEXP_TD.matcher(line).find()) {
                matcher = REGEXP_TD.matcher(line);
                matcher.find();
                value = new ValueWithUnitType();
                value.setValue(matcher.group(1));
                value.setUnitName(UnitsNames.HZ.name());
                parameterSet.setNumberOfDataPoints(BigInteger.valueOf(Long.parseLong(matcher.group(1))));
            }
            if (REGEXP_TD.matcher(line).find()) {
                matcher = REGEXP_TD.matcher(line);
                matcher.find();
                parameterSet.setNumberOfDataPoints(BigInteger.valueOf(Long.parseLong(matcher.group(1))));
            }
            //TODO check if this only records the last nucleos
            if (REGEXP_NUC.matcher(line).find()) {
                matcher = REGEXP_NUC.matcher(line);
                matcher.find();
                parameterSet.setAcquisitionNucleus(matcher.group(1));
            }
        }
        return parameterSet;
    }


}
