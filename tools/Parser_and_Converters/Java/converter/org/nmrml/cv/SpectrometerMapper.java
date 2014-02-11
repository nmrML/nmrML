/*
 * Copyright (c) 2014 EMBL, European Bioinformatics Institute
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

package org.nmrml.cv;

import org.ini4j.Ini;
import org.ini4j.Wini;

import java.io.IOException;
import java.io.InputStream;

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

    public SpectrometerMapper() throws IOException {
        this(ClassLoader.getSystemResourceAsStream("resources/ontologies/spectrometer.ini"));
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
