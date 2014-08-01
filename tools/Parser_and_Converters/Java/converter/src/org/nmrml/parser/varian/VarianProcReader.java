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

package org.nmrml.parser.varian;

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
 * Reader for Varian's propar files
 *
 * @author Daniel Jacob
 *
 * Date: 21/07/2014
 * Time: 15:00
 *
 */

public class VarianProcReader implements ProcReader {

    private BufferedReader procFile;
    private static Acqu acquisition;

    public VarianProcReader(File procFile, Acqu acquisition) throws FileNotFoundException {
        this.procFile = new BufferedReader(new FileReader(procFile));
        this.acquisition=acquisition;
    }

    public VarianProcReader(String filename) throws FileNotFoundException {
        this(new File(filename),acquisition);
    }

    public VarianProcReader(InputStream procFileInputStream, Acqu acquisition) throws FileNotFoundException {
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



            line = procFile.readLine();
        }
        procFile.close();
        return processing;
    }
}
