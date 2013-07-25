/*
 * Copyright (c) 2013 EMBL, European Bioinformatics Institute.
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

package uk.ac.ebi.nmr.fid.io;


import uk.ac.ebi.nmr.fid.Acqu;
import uk.ac.ebi.nmr.fid.Proc;
import uk.ac.ebi.nmr.fid.Spectrum;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.DoubleBuffer;
import java.nio.IntBuffer;
import java.nio.channels.FileChannel;

/**
 * Class that reads the real and imaginary part of Bruker Processed data
 *
 * @author Luis F. de Figueiredo
 *
 * User: ldpf
 * Date: 08/05/2013
 * Time: 10:12
 * To change this template use File | Settings | File Templates.
 */
public class SimplePdataReader implements FidReader {

    static private File pdataFolder;
    static private FileInputStream pdata1r;
    static private FileInputStream pdata1i;
    static private Proc processing;
    static private Acqu acquisition;

    public SimplePdataReader(File pdataFolder, Acqu acquisition, Proc processing) throws FileNotFoundException {
        this(new FileInputStream(pdataFolder.getPath()+"/1r"),
                new FileInputStream(pdataFolder.getPath()+"/1i"),acquisition,processing);
        this.pdataFolder=pdataFolder;
    }

    public SimplePdataReader(FileInputStream pdata1r, FileInputStream pdata1i,
                             Acqu acquisition, Proc processing) {
        this.pdata1r=pdata1r;
        this.pdata1i=pdata1i;
        this.acquisition=acquisition;
        this.processing=processing;
    }

    @Override
    public Spectrum read() throws Exception {
        double[] realDatapoints = getDatapoints(pdata1r);
        double[] imaginaryDatapoints = getDatapoints(pdata1i);
        double[] fid = null;

        // trying to get the FID from the file structure as this is a required object to build a Spectrum object
        if(pdataFolder != null){
            //TODO move to java.nio.file
            // check if one has a Unix or Windows based system
            String [] path = (System.getProperty("os.name").contains("Win")) ?
                    pdataFolder.getAbsolutePath().split("\\\\"): pdataFolder.getAbsolutePath().split("/");
            // put path back...
            StringBuffer fidPath = new StringBuffer();
            if (path.length > 0) {
                fidPath.append(path[0]);
                for (int i = 1; i < path.length-2; i++) {
                    fidPath.append((System.getProperty("os.name").contains("Win")) ? "\\\\" : "/");
                    fidPath.append(path[i]);
                }
            }
            fidPath.append((System.getProperty("os.name").contains("Win")) ? "\\\\" : "/");
            fidPath.append("fid");
            if(new File(fidPath.toString()).exists()){
                FidReader fidReader = new Simple1DFidReader(new FileInputStream(fidPath.toString()),acquisition);
                Spectrum spectrum = fidReader.read();
                fid= spectrum.getFid();
            }
        }

        Spectrum spectrum = new Spectrum(fid, acquisition,processing);
        spectrum.setImaginaryChannelData(imaginaryDatapoints);
        spectrum.setRealChannelData(realDatapoints);
        return spectrum;
    }

    protected double[] getDatapoints(FileInputStream inputStream) throws IOException {
        double[] datapoints=null;
        FileChannel inChannel = inputStream.getChannel();
        ByteBuffer buffer = inChannel.map(FileChannel.MapMode.READ_ONLY, 0, inChannel.size());
        if (processing.is32Bit()) {
            int[] result = new int[(int) inChannel.size()/4];
            System.out.println("Number of points in the processed spectra: " + inChannel.size()/4);
            // this has to do with the order of the bytes
            buffer.order(processing.getByteOrder());
            //read the integers
            IntBuffer intBuffer = buffer.asIntBuffer( );
            intBuffer.get(result);
            // the number of points in 1r is defined in the procs file
            datapoints = new double[processing.getTdEffective()];
            // Bruker only uses half of the points, so I will just pick the even positions
            for(int i =0; i<result.length;i+=2)
                datapoints[i/2]=(double) result[i];
        } else { // its a 64bit file encoding doubles
            double [] result = new double[(int) inChannel.size()/8];

            System.out.println("Number of points in the the processed spectra: " + inChannel.size()/8);
            // this has to do with the order of the bytes
            buffer.order(processing.getByteOrder());
            //read the integers
            DoubleBuffer doubleBuffer = buffer.asDoubleBuffer();
            doubleBuffer.get(result);
            // Bruker only uses half of the points, so I will just pick the even positions
            // making sure I have only the tdeff
            datapoints = new double[processing.getTdEffective()];
            for(int i =0; i<processing.getTdEffective();i++)
                datapoints[i]=(double) result[i*2];
//            System.arraycopy(result,0,datapoints,0,processing.getTdEffective());
        }
        return datapoints;
    }
}
