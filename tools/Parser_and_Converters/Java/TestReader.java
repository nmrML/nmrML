
import uk.ac.ebi.nmr.fid.*;
import uk.ac.ebi.nmr.fid.io.*;

import java.io.File;
import java.net.*;
import java.io.*;
import java.util.*;
import java.lang.*;
/*
 * $Id: TestReader.java,v 0.1 2013-07-23 15:00:00 DJ $
 */


public class TestReader {

    public static void main( String[] args ) {

        if (args.length == 0) {
            System.err.println("Argument" + " must be a path directory");
            System.exit(1);
        }

        String sep = (System.getProperty("os.name").contains("Win")) ? "\\\\" : "/";
        
        try {

           /* Acquisition Parameter File */
           File dataFolder = new File(args[0]);
           File acquFile = new File(dataFolder.getAbsolutePath()+sep+"acqus");
           AcquReader acqObj = new BrukerAcquReader(acquFile);
           Acqu acq = acqObj.read();
           
           /* do someting with this Acqu instance */

/* print some values for testing */
System.out.println( String.format( "SF01 = %f", acq.getTransmiterFreq() ) );
System.out.println( String.format( "01 = %f", acq.getFreqOffset() ) );
System.out.println( String.format( "BF1 = %f", acq.getSpectralFrequency() ) );
System.out.println( String.format( "SW = %f", acq.getSpectralWidth() ) );
System.out.println( String.format( "TD = %d", acq.getAquiredPoints() ) );
System.out.println( String.format( "NS = %d", acq.getNumberOfScans() ) );
System.out.println( String.format( "DECIM = %d", acq.getDspDecimation() ) );
System.out.println( String.format( "PULPROG = %s", acq.getPulseProgram() ) );
System.out.println( String.format( "NUC1 = %s", acq.getObservedNucleus() ) );
System.out.println( String.format( "SOLVENT = %s", acq.getSolvent() ) );

           /* FID File */
           File fileFID = new File(dataFolder.getAbsolutePath()+sep+"fid");
           FileInputStream ffid = new FileInputStream(fileFID);
           FidReader fidObj = new Simple1DFidReader(ffid, acq);
           Spectrum fid = fidObj.read();

           /* do someting with this Spectrum instance */
           /* Get FID values : fid.fid[i] , 0 <= i < acq.getAquiredPoints() */

           /* Processing Parameter File */
           File procFile = new File(dataFolder.getAbsolutePath()+sep+"pdata"+sep+"1"+sep+"procs");
           ProcReader procObj = new BrukerProcReader(procFile, acq);
           Proc proc = procObj.read();
           
           /* do someting with this Proc instance */

/* print some values for testing */
System.out.println( String.format( "PH_mod = %d", proc.getPhasingType() ) );
System.out.println( String.format( "PHC0 = %f", proc.getZeroOrderPhase() ) );
System.out.println( String.format( "PHC1 = %f", proc.getFirstOrderPhase() ) );
System.out.println( String.format( "SI = %d", proc.getTransformSize() ) );

           /* 1r & 1i Spectrum Files */
           File file1r = new File(dataFolder.getAbsolutePath()+sep+"pdata"+sep+"1"+sep+"1r");
           File file1i = new File(dataFolder.getAbsolutePath()+sep+"pdata"+sep+"1"+sep+"1i");
           FileInputStream f1r = new FileInputStream(file1r);
           FileInputStream f1i = new FileInputStream(file1i);
           FidReader spectObj = new SimplePdataReader(f1r, f1i, acq, proc);
           Spectrum spectrum = spectObj.read();

           /* do someting with this Spectrum instance */
           /* Get Real part  values : spectrum.realChannelData[i] , 0 <= i < proc.getTdEffective() */
           /* Get Imaginary part  values : spectrum.imaginaryChannelData[i] , 0 <= i < proc.getTdEffective() */

        } catch( Exception e ) {
            e.printStackTrace();
        }
    }

}