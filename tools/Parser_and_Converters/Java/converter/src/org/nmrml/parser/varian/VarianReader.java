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
import org.nmrml.parser.varian.VarianAcquReader;
import org.nmrml.parser.varian.VarianProcReader;
import org.nmrml.cv.SpectrometerMapper;

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
 * General Varian reader that uses the folder structure from Bruker software to read the spectrometer
 *
 * @author Daniel Jacob
 *
 * Date: 21/07/2014
 * Time: 15:00
 *
 */
public class VarianReader {

    private File acquFile = null;
    private File procFile = null;

    public Acqu acq = null;
    public Proc proc = null;

    public VarianReader() {
    }

    public VarianReader(String inputFolder, SpectrometerMapper vendorMapper) throws FileNotFoundException {

        try{

           File dataFolder = new File(inputFolder);
           String acqFstr = dataFolder.getAbsolutePath() + "/" + vendorMapper.getTerm("FILES", "ACQUISITION_FILE");
           this.acquFile = new File(acqFstr);
           if(acquFile.isFile() && acquFile.canRead()) {
               AcquReader acqObj = new VarianAcquReader(acquFile);
               this.acq = acqObj.read();
               acq.setSoftware(vendorMapper.getTerm("SOFTWARE", "SOFTWARE"));
               acq.setSoftVersion(vendorMapper.getTerm("SOFTWARE", "VERSION"));
               switch (Integer.parseInt(vendorMapper.getTerm("BYTORDA", "ENDIAN"))){
                    case 0 :
                        acq.setByteOrder(ByteOrder.LITTLE_ENDIAN);
                        break;
                    case 1 :
                        acq.setByteOrder(ByteOrder.BIG_ENDIAN);
                        break;
                    default:
                        break;
               }
               acq.setDecoupledNucleus("off");
           }
           else {
               System.err.println("ACQUISITION_FILE not available or readable: " + acqFstr);
               System.exit(1);
           }
           // String procFstr = dataFolder.getAbsolutePath() + "/" + vendorMapper.getTerm("FILES", "PROCESSING_FILE");
           // this.procFile = new File(procFstr);
           // if(procFile.isFile() && procFile.canRead()) {
           //     ProcReader procObj = new VarianProcReader(procFile, acq);
           //     this.proc = procObj.read();
           // }
           // else {
           //     System.err.println("PROCESSING_FILE not available or readable: " + procFstr);
           //     System.exit(1);
           // }

        } catch( Exception e ) {
            e.printStackTrace();
        }

    }

}
