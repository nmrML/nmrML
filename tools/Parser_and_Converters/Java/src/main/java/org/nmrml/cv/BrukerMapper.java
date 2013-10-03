package org.nmrml.cv;

import org.ini4j.Wini;

import java.io.IOException;
import java.io.InputStream;

/**
 * Created with IntelliJ IDEA.
 * User: ldpf
 * Date: 02/10/2013
 * Time: 15:15
 * To change this template use File | Settings | File Templates.
 */
public class BrukerMapper {

    Wini brukerIni;

    public BrukerMapper() throws IOException {
        this(ClassLoader.getSystemResourceAsStream("org/nmrml/ontologies/bruker.ini"));
    }

    public BrukerMapper (InputStream inputStream) throws IOException {
        brukerIni = new Wini(inputStream);
    }

    public String getTerm(String brukerTag, String value){
      return brukerIni.get(brukerTag,value);
    }
}
