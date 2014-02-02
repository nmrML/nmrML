package org.nmrml.execs;

import org.apache.commons.cli.BasicParser;
import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Option;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;
import org.nmrml.converter.BrukerAcquAbstractReader;
import org.nmrml.model.NmrMLType;
import org.nmrml.model.ObjectFactory;

import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBElement;
import javax.xml.bind.JAXBException;
import javax.xml.bind.Marshaller;
import java.io.File;
import java.nio.file.Path;
import java.nio.file.Paths;

/**
 * Created with IntelliJ IDEA.
 * User: ldpf
 * Date: 29/01/2014
 * Time: 17:17
 * To change this template use File | Settings | File Templates.
 */
public class Converter {
    static Options options;
    public static void main(String[] args) {
        options = new Options();
        Option help = new Option( "help", "print this message" );
        options.addOption(help);
        options.addOption("w", false, "overwrite output file");
        options.addOption("s", false, "print xml in the stdout");

        CommandLineParser parser = new BasicParser();
        CommandLine cmd = null;
        try {
            cmd = parser.parse( options, args);
        } catch (ParseException e) {
            // oops, something went wrong
            System.err.println( "Parsing failed.  Reason: " + e.getMessage() );
        }
        System.out.println(args.length +" " +cmd.getArgs().length+" "+ cmd.getOptions().length);
        if((args.length  - cmd.getOptions().length) < 1 || cmd.hasOption("help")){
            callHelp(options);
        } else {convert(args, cmd);}

    }

    private static void callHelp(Options options) {
        HelpFormatter formatter = new HelpFormatter();
        formatter.printHelp( "converter [options] EXPERIMENT_FOLDER [NMRML_FILE]\n" +
                "Converts the spectrum in EXPERIMENT_FOLDER to nmrML file format.", options );
    }

    private static void convert(String[] args, CommandLine cmd) {
        System.out.println(args.length +" " +cmd.getArgs().length+" "+ cmd.getOptions().length);
        int filenameIndex=(cmd.getOptions().length>0)? args.length  - cmd.getArgs().length : 0;

        String fileInPath = (new File(args[filenameIndex]).isFile())?
                new File(args[filenameIndex]).getParent():args[filenameIndex];
        File inputFolder = new File(fileInPath);

        String fileOutPath;
        if((args.length-cmd.getOptions().length)<2){
            String relativeName =
                    inputFolder.getParentFile().toURI()
                            .relativize(inputFolder.toURI()).toString();
            fileOutPath =inputFolder.getAbsolutePath()+"/"+
                    relativeName.substring(0,relativeName.lastIndexOf("/"))+".nmrML";
        } else {
            fileOutPath =args[filenameIndex+1];
        }


        ObjectFactory objFactory = new ObjectFactory();

        Path path = Paths.get(inputFolder.getAbsolutePath() + "/acqus");

        NmrMLType nmrMLElement = null;
        try {
            nmrMLElement = new BrukerAcquAbstractReader(new File(path.toString())).read();
        } catch (Exception e) {
            e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
        }

        /* Generate XML */
        try{

            JAXBElement<NmrMLType> nmrML = (JAXBElement<NmrMLType>) objFactory.createNmrML(nmrMLElement);

            // create a JAXBContext capable of handling classes generated into the org.nmrml.schema package
            JAXBContext jc = JAXBContext.newInstance( "org.nmrml.model" );

            // create a Marshaller and marshal to a file
            Marshaller m = jc.createMarshaller();
            m.setProperty( Marshaller.JAXB_FORMATTED_OUTPUT, new Boolean(true) );
            m.setProperty(Marshaller.JAXB_SCHEMA_LOCATION, "http://nmrML.org/schema/nmrML.xsd");
            if(cmd.hasOption("s")){
                m.marshal( nmrML, System.out );
            }
            if(!cmd.hasOption("w") && new File(fileOutPath).exists()){
                System.err.println("File already exists! Please use option to overwrite.");
                callHelp(options);
            } else {
                m.marshal( nmrML, new File(fileOutPath));
            }


        } catch( JAXBException je ) {
            je.printStackTrace();
        }
    }
}
