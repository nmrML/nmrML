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
import org.nmrml.parser.BinaryData;
import org.nmrml.parser.bruker.BrukerAcquReader;
import org.nmrml.parser.bruker.BrukerProcReader;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileInputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.math.BigInteger;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.channels.FileChannel;
import java.nio.file.Files;

import java.net.*;
import java.io.*;
import java.util.*;
import java.lang.*;


/**
 * General Bruker reader that uses the folder structure from Bruker software to read the spectrometer
 *
 * @author Luis F. de Figueiredo
 *
 * User: ldpf
 * Date: 21/09/2012
 * Time: 14:46
 *
 */
public class BrukerReader {

    private File acquFile = null;
    private File procFile = null;

    public Acqu acq = null;
    public Proc proc = null;

    public BrukerReader() {
    }

    public BrukerReader(String inputFolder) throws FileNotFoundException {

        try{
           File dataFolder = new File(inputFolder);

           this.acquFile = new File(dataFolder.getAbsolutePath()+"/acqus");
           if(acquFile.isFile() && acquFile.canRead()) {
               AcquReader acqObj = new BrukerAcquReader(acquFile);
               this.acq = acqObj.read();
           }
           this.procFile = new File(dataFolder.getAbsolutePath()+"/pdata/1/procs");
           if(procFile.isFile() && procFile.canRead()) {
               ProcReader procObj = new BrukerProcReader(procFile, acq);
               this.proc = procObj.read();
           }

        } catch( Exception e ) {
            e.printStackTrace();
        }

    }

}
