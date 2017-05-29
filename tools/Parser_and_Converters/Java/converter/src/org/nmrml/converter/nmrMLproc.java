/*
 * $Id: Converter.java,v 1.0.alpha Feb 2014 (C) INRA - DJ $
 *
 * CC-BY 4.0
*/

package org.nmrml.converter;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.GnuParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.MissingArgumentException;
import org.apache.commons.cli.MissingOptionException;
import org.apache.commons.cli.OptionBuilder;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;
import org.apache.commons.cli.PosixParser;

import java.util.*;
import java.lang.*;

import org.nmrml.schema.*;
import org.nmrml.parser.*;
import org.nmrml.parser.bruker.*;

import org.nmrml.cv.*;
import org.nmrml.converter.*;

// From a nmrML file, add processing data
public class nmrMLproc {

    private static final String nmrMLVersion = nmrMLversion.value;
    private static final String Version = "1.2";

    private enum Vendor_Type { bruker; }

    public nmrMLproc( ) { }

    public void launch( String[] args ) {

        Proc2nmrML nmrmlObj = new Proc2nmrML();

        /* Containers of Acquisition/Processing Parameters  */
        String Vendor = "bruker";

        Options options = new Options();
        options.addOption("h", "help", false, "prints the help content");
        options.addOption("v", "version", false, "prints the version");
        options.addOption("b","binary-data",false,"include spectrum binary data");
        options.addOption("z","compress",false,"compress binary data");
        options.addOption(OptionBuilder
           .withDescription("prints the nmrML XSD version")
           .withLongOpt("xsd-version")
           .create());
        options.addOption(OptionBuilder
           .withArgName("config.properties")
           .hasArg()
           .withDescription("properties configuration file")
           .withLongOpt("prop")
           .create());
        options.addOption(OptionBuilder
           .withArgName("nmrML file")
           .hasArg()
           .withDescription("nmrML file")
           .withLongOpt("nmrml")
           .create("i"));
        options.addOption(OptionBuilder
           .withArgName("vendor")
           .hasArg()
           .withDescription("type")
           .withLongOpt("vendortype")
           .create("t"));
        options.addOption(OptionBuilder
           .withArgName("directory")
           .hasArg()
           .isRequired()
           .withDescription("proc data directory")
           .withLongOpt("procdir")
           .create("d"));
        options.addOption(OptionBuilder
           .withArgName("file")
           .hasArg()
           .withDescription("output nmrML file")
           .withLongOpt("nmrmlout")
           .create("o"));

        try {

           Locale.setDefault(new Locale("en", "US"));

           String current_dir = new java.io.File( "." ).getCanonicalPath();

           CommandLineParser parser = new GnuParser();
           CommandLine cmd = parser.parse(options, args);

           String inputFile = cmd.getOptionValue("i");
           nmrmlObj.setInputFile(inputFile);

           String procFolder = cmd.getOptionValue("d");
           procFolder = ( procFolder.lastIndexOf("/") == procFolder.length() ) ? procFolder : procFolder.concat("/");
           nmrmlObj.setProcFolder(procFolder);

        /* Properties object */
           Properties prop = new Properties();
           if (cmd.hasOption("prop")) {
               String conffile = cmd.getOptionValue("prop");
               prop.load(new FileInputStream(conffile));
           } else {
               prop.load(nmrMLpipe.class.getClassLoader().getResourceAsStream("resources/config.properties"));
           }
           String onto_ini = prop.getProperty("onto_ini_file");
           nmrmlObj.setSchemaLocation( prop.getProperty("schemaLocation") );

        /* CVLoader object */
           CVLoader cvLoader = (new File(onto_ini)).isFile() ?
                          new CVLoader(new FileInputStream(onto_ini)) : 
                          new CVLoader(nmrMLpipe.class.getClassLoader().getResourceAsStream("resources/onto.ini"));
           nmrmlObj.setCVLoader(cvLoader);

           if(cmd.hasOption("t")) {
                 Vendor = cmd.getOptionValue("t").toLowerCase();
           }
           String vendor_ini = prop.getProperty(Vendor);
           Vendor_Type vendor_type = Vendor_Type.valueOf(Vendor);

       /* Vendor terms file */
           SpectrometerMapper vendorMapper = (new File(vendor_ini)).isFile() ? 
                         new SpectrometerMapper(vendor_ini) : vendor_type == Vendor_Type.bruker ? 
                         new SpectrometerMapper(nmrMLpipe.class.getClassLoader().getResourceAsStream("resources/bruker.ini")) :
                         new SpectrometerMapper(nmrMLpipe.class.getClassLoader().getResourceAsStream("resources/varian.ini")) ;
           nmrmlObj.setVendorMapper(vendorMapper);

       /* Get Processing Parameters depending on the vendor type */
           File dataFolder = new File(procFolder);
           String procFstr = dataFolder.getAbsolutePath() + "/" + vendorMapper.getTerm("FILES", "PROCESSING_FILE");
           File procFile = new File(procFstr);
           if(procFile.isFile() && procFile.canRead()) {
               switch (vendor_type) {
                  case bruker:
                       BrukerProcReader brukerProcObj = new BrukerProcReader(procFile);
                       Proc proc = brukerProcObj.read();
                       if ( proc.getSoftware() == null) {
                           proc.setSoftware("PREPROC");
                           proc.setSoftVersion("-");
                       }
                       nmrmlObj.setProc(proc);
                       break;
               }
           }
           else {
               System.err.println("nmrMLproc: PROCESSING_FILE not available or readable: " + procFstr);
               System.exit(1);
           }

           nmrmlObj.setVendorLabel(Vendor.toUpperCase());
           nmrmlObj.setIfbinarydata(cmd.hasOption("b"));
           nmrmlObj.setCompressed(cmd.hasOption("z"));

           if(cmd.hasOption("o")) {
                nmrmlObj.Add2nmrML( cmd.getOptionValue("o","output.nmrML") );
           } else {
                nmrmlObj.Add2nmrML( null );
           }

        } catch(MissingOptionException e){
            boolean help = false;
            boolean version = false;
            boolean xsdversion = false;
            try{
              Options helpOptions = new Options();
              helpOptions.addOption("h", "help", false, "prints the help content");
              helpOptions.addOption("v", "version", false, "prints the version");
              helpOptions.addOption(OptionBuilder.withDescription("prints the nmrML XSD version").withLongOpt("xsd-version").create());
              CommandLineParser parser = new PosixParser();
              CommandLine line = parser.parse(helpOptions, args);
              if(line.hasOption("h")) help = true;
              if(line.hasOption("v")) version = true;
              if(line.hasOption("xsd-version")) xsdversion = true;
            } catch(Exception ex){ }
            if(!help && !version && !xsdversion) System.err.println(e.getMessage());
            if (help) {
                HelpFormatter formatter = new HelpFormatter();
                formatter.printHelp( "nmrMLcreate" , options );
            }
            if (version) {
                System.out.println("nmrML Proc version = " + Version);
            }
            if (xsdversion) {
                System.out.println("nmrML XSD version = " + nmrMLVersion);
            }
            System.exit(1);
        } catch(MissingArgumentException e){
            System.err.println(e.getMessage());
            HelpFormatter formatter = new HelpFormatter();
            formatter.printHelp( "nmrMLproc" , options );
            System.exit(1);
        } catch(ParseException e){
            System.err.println("nmrMLproc: Error while parsing the command line: "+e.getMessage());
            System.exit(1);
        } catch( Exception e ) {
            e.printStackTrace();
        }

    }
}
