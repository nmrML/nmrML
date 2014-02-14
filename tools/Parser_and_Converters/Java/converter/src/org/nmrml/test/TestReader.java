/*
 * $Id: TestReader.java,v 0.1 Feb. 2014 (C) INRA - DJ $
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

package org.nmrml.test;

import org.nmrml.parser.*;
import org.nmrml.parser.bruker.*;

import org.nmrml.schema.*;
import org.nmrml.cv.*;

import javax.xml.datatype.DatatypeConfigurationException;
import javax.xml.datatype.DatatypeFactory;
import javax.xml.datatype.XMLGregorianCalendar;

import javax.xml.bind.*;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

import java.math.BigDecimal;
import java.math.BigInteger;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.channels.FileChannel;
import java.nio.file.Files;
import java.util.GregorianCalendar;
import java.util.HashMap;

import java.net.*;
import java.io.*;
import java.util.*;
import java.lang.*;

public class TestReader {

    private enum Vendor_Type {
        bruker, varian, joel;
    }

    public static void main( String[] args ) {

        Acqu acq = null;
        Proc proc = null;
        String Vendor_Label = "";

        if (args.length == 0) {
            System.err.println("Argument" + " must be a path directory");
            System.exit(1);
        }

        String inputFolder = args[0];
        inputFolder = (inputFolder.lastIndexOf("/")== inputFolder.length())? inputFolder : inputFolder.concat("/");

        try {        
            /* Properties object */
            Properties prop = new Properties();
            prop.load(TestReader.class.getClassLoader().getResourceAsStream("resources/config.properties"));
            String onto_ini = prop.getProperty("onto_ini_file");
            Vendor_Type vendor_type = Vendor_Type.valueOf(prop.getProperty("vendor_type"));
            String vendor_ini = prop.getProperty("vendor_ini_file");

            /* CVLoader object */
            CVLoader cvLoader = (new File(onto_ini)).isFile() ? 
                                 new CVLoader(TestReader.class.getClassLoader().getResourceAsStream(onto_ini)) : new CVLoader();

            /* Get all data */
            switch (vendor_type) {
                  case bruker:
                       Vendor_Label = "BRUKER";
                       /* Acquisition & Processing Parameters Files */
                       BrukerReader brukerValues = new BrukerReader(inputFolder);
                       acq = brukerValues.acq;
                       proc = brukerValues.proc;
                       break;
                  case varian:
                       break;
                  case joel:
                       break;
            }

            /* Vendor terms file */
            SpectrometerMapper vendorMapper = (new File(vendor_ini)).isFile() ? 
                      new SpectrometerMapper(TestReader.class.getClassLoader().getResourceAsStream(vendor_ini)) : new SpectrometerMapper();

           /* TODO: Populate a NmrMLType object, then JAXB marshaller */

//----------------------------------------------------------------------------------------------------
URL main = TestReader.class.getResource("TestReader.class");
if (!"file".equalsIgnoreCase(main.getProtocol()))
  throw new IllegalStateException("Main class is not stored in a file.");
System.out.println("My Main Class Path is: "+main.getPath());
System.out.println("My Main Class Path is: "+TestReader.class.getProtectionDomain().getCodeSource().getLocation().getPath());


System.out.println();
String current = new java.io.File( "." ).getCanonicalPath();
       System.out.println("Current dir:"+current);
String currentDir = System.getProperty("user.dir");
       System.out.println("Current dir using System:" +currentDir);

/* Properties object */
System.out.println("Contact Name is " + prop.getProperty("contact_name"));
System.out.println("Contact email is " + prop.getProperty("contact_email"));

System.out.println("Ontology File is " + onto_ini);
System.out.println("Ontology File exist ? "+(new File(onto_ini)).isFile());
System.out.println("Ontology Path File is "+(new File(onto_ini)).getAbsolutePath());
System.out.println();
System.out.println("Bruker Ini File is " + vendor_ini);
System.out.println("Bruker Ini File exist ? "+(new File(vendor_ini)).isFile());
System.out.println("Bruker Ini Path File is "+(new File(vendor_ini)).getAbsolutePath());
System.out.println();
System.out.println("InputFolder " + inputFolder);
//System.out.println("InputFolder exist ? "+(new File(inputFolder)).isFile());
System.out.println("InputFolder Path is "+(new File(inputFolder)).getAbsolutePath());
System.out.println();

/* CVLoader object */
System.out.println("Ontology Count = "+cvLoader.getCVOntologySet().size());
for (String key : cvLoader.getCVOntologySet()) {
    CVType cv = cvLoader.fetchCVType(key);
    System.out.println(key+": Fullname is " + cv.getFullName());
    System.out.println(key+": Version is " + cv.getVersion());
    System.out.println(key+": RI is " + cv.getURI());
}
System.out.println();

/* Constructor terms file */
HashMap<String,String> hsrcFile = new HashMap<String,String>();
for (String key : vendorMapper.getSection("FILES").keySet()) {
    File file = new File(inputFolder + vendorMapper.getTerm("FILES", key));
    if (file.isFile() & file.canRead()) {
        CVParamType cvparam = cvLoader.fetchCVParam("NMRCV",key);
        hsrcFile.put(key, inputFolder + vendorMapper.getTerm("FILES", key));
        System.out.println("FILE " + key + " is " + file.toURI().toString() + ", " + file.getName() + 
                           ": " + cvparam.getAccession() + ", " + cvparam.getName());
    }
}
System.out.println();


/* Acqu object */
CVParamType cvspect = cvLoader.fetchCVParam("NMRCV",Vendor_Label);
System.out.println( String.format( "Acqu: SPECTROMETER = %s", acq.getSpectrometer() ) );
System.out.println( String.format( "Acqu: INSTRUM = %s", acq.getInstrumentName() ) + ", " + cvspect.getName() );
System.out.println( String.format( "Acqu: PROBE = %s", acq.getProbehead() ) );
System.out.println( String.format( "Acqu: PULPROG = %s", acq.getPulseProgram() ) );
System.out.println( String.format( "Acqu: NUC1 = %s", acq.getObservedNucleus() ) );
System.out.println( String.format( "Acqu: SOLVENT = %s", acq.getSolvent() ) );
System.out.println( String.format( "Acqu: SOFTWARE = %s", acq.getSoftware() ) );
System.out.println( String.format( "Acqu: SOFT. Version = %s", acq.getSoftVersion() ) );
System.out.println( String.format( "Acqu: ORIGIN = %s", acq.getOrigin() ) );
System.out.println( String.format( "Acqu: OWNER = %s", acq.getOwner() ) );
System.out.println( String.format( "Acqu: EMAIL = %s", acq.getEmail() ) );
System.out.println( String.format( "Acqu: SF01 = %f", acq.getTransmiterFreq() ) );
System.out.println( String.format( "Acqu: 01 = %f", acq.getFreqOffset() ) );
System.out.println( String.format( "Acqu: BF1 = %f", acq.getSpectralFrequency() ) );
System.out.println( String.format( "Acqu: SW = %f", acq.getSpectralWidth() ) );
System.out.println( String.format( "Acqu: SW_h = %f", acq.getSpectralWidthHz() ) );
System.out.println( String.format( "Acqu: TD = %d", acq.getAquiredPoints() ) );
System.out.println( String.format( "Acqu: NS = %d", acq.getNumberOfScans() ) );
System.out.println( String.format( "Acqu: DS = %d", acq.getNumberOfSteadyStateScans() ) );
System.out.println( String.format( "Acqu: DECIM = %d", acq.getDspDecimation() ) );
System.out.println( String.format( "Acqu: Relax. Delay  = %f", acq.getRelaxationDelay() ) );
System.out.println( String.format( "Acqu: Spin. Rate  = %d", acq.getSpiningRate() ) );
System.out.println( String.format( "Acqu: Temperature  = %f", acq.getTemperature() ) );
System.out.println( String.format( "Acqu: ByteOrder  = %s", acq.getByteOrder().toString() ) );
System.out.println( String.format( "Acqu: BiteSyze  = %d", acq.getBiteSyze() ) );

System.out.println();


/* Proc object */
System.out.println( String.format( "Proc: PH_mod = %d", proc.getPhasingType() ) );
System.out.println( String.format( "Proc: PHC0 = %f", proc.getZeroOrderPhase() ) );
System.out.println( String.format( "Proc: PHC1 = %f", proc.getFirstOrderPhase() ) );
System.out.println( String.format( "Proc: SI = %d", proc.getTransformSize() ) );
System.out.println( String.format( "Proc: OFFSET = %f", proc.getOffset() ) );
System.out.println( String.format( "Proc: Dwell Time = %f", proc.getDwellTime() ) );

CVTermType cvWDW = cvLoader.fetchCVTerm("NMRCV",vendorMapper.getTerm("WDW", String.format("%d",proc.getWindowFunctionType())));
System.out.println("Window Type = " + cvWDW.getName() + ", " + cvWDW.getAccession());
System.out.println();

/* FID File */
BinaryData fidbinaryData = new BinaryData(new File(hsrcFile.get("FID_FILE")), acq);
if (fidbinaryData.isExists()) {
   System.out.println( String.format( "FID: encodedLength = %d", fidbinaryData.getEncodedLength() ) );
   System.out.println( String.format( "FID: byteFormat = %s", fidbinaryData.getByteFormat() ) );
   byte[] data = fidbinaryData.getData();
   String FidData = new String(data, 0, data.length, "ASCII");
   System.out.println("FID: SHA-1 = " + fidbinaryData.getSha1());
//System.out.println( String.format( "FID Data = \n%s\n", FidData ) );
//System.out.println( "\n" );
}
System.out.println();

/* 1r & 1i Spectrum Files */
BinaryData binaryData1r = new BinaryData(new File(hsrcFile.get("REAL_DATA_FILE")), acq);
if (binaryData1r.isExists()) {
   System.out.println( String.format( "1r: encodedLength = %d", binaryData1r.getEncodedLength() ) );
   System.out.println( String.format( "1r: byteFormat = %s", binaryData1r.getByteFormat() ) );
   System.out.println("1r: SHA-1 = " + binaryData1r.getSha1());
}
System.out.println();

BinaryData binaryDataPulse = new BinaryData(new File(hsrcFile.get("PULSEPROGRAM_FILE")), acq);
if (binaryDataPulse.isExists()) {
   System.out.println("Pulse: SHA-1 = " + binaryDataPulse.getSha1());
}
System.out.println();

//----------------------------------------------------------------------------------------------------

        } catch( Exception e ) {
            e.printStackTrace();
        }
    }

}