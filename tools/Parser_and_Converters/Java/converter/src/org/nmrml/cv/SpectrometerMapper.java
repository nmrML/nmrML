/*
 * Copyright (c) 2014 EMBL, European Bioinformatics Institute
 *
 * CC-BY 4.0
 */

package org.nmrml.cv;

import org.ini4j.Ini;
import org.ini4j.Wini;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.FileInputStream;

/**
 * Created with IntelliJ IDEA.
 *
 * @author Luis F. de Figueiredo
 *
 * User: ldpf
 * Date: 02/10/2013
 * Time: 15:15
 * To change this template use File | Settings | File Templates.
 */
public class SpectrometerMapper {

    Wini spectrometerIni;

    public SpectrometerMapper (String vendor_ini) throws IOException {
        this(new FileInputStream(vendor_ini));
    }

    public SpectrometerMapper (InputStream inputStream) throws IOException {
        spectrometerIni = new Wini(inputStream);
    }
    public String getTerm(String brukerTag, String value){
      return spectrometerIni.get(brukerTag,value);
    }
    public Ini.Section getSection (String section){
        return spectrometerIni.get(section);
    }
}
