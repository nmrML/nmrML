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

package uk.ac.ebi.nmr.fid.io;

import uk.ac.ebi.nmr.fid.Acqu;
import uk.ac.ebi.nmr.fid.Proc;
import uk.ac.ebi.nmr.fid.Spectrum;

import java.io.FileInputStream;
import java.nio.ByteBuffer;
import java.nio.DoubleBuffer;
import java.nio.IntBuffer;
import java.nio.channels.FileChannel;

/**
 * Reader for Bruker's fid file.
 *
 * @author Luis F. de Figueiredo
 *
 */
public class Simple1DFidReader implements FidReader {

    private Acqu acquisition;
    private Proc processing;
    private FileInputStream fidInput;
    private double zeroFrequency = 0;


    public Simple1DFidReader(FileInputStream fidInputS, Acqu acquisition) {
        this.acquisition = acquisition;
        this.fidInput = fidInputS;
    }

    public Simple1DFidReader(FileInputStream fidInputS, Acqu acquisition, Proc processing) {
        this.acquisition = acquisition;
        this.fidInput = fidInputS;
        this.processing = processing;
    }

    public Spectrum read() throws Exception {
        double[] fid = null;
        FileChannel inChannel = fidInput.getChannel();
        ByteBuffer buffer = inChannel.map(FileChannel.MapMode.READ_ONLY, 0, inChannel.size());
        if (acquisition.is32Bit()) {
            int[] result = new int[(int) inChannel.size()/4];
            System.out.println("Number of points in the fid: " + inChannel.size()/4);
            // this has to do with the order of the bytes
            buffer.order(acquisition.getByteOrder());
            //read the integers
            IntBuffer intBuffer = buffer.asIntBuffer( );
            intBuffer.get(result);
            fid = new double[acquisition.getAquiredPoints()];
            for(int i =0; i<fid.length;i++)
                fid[i]=(double) result[i];

        } else { // its a 64bit file encoding doubles
                double [] result = new double[(int) inChannel.size()/8];
                System.out.println("Number of points in the fid: " + inChannel.size()/8);
                // this has to do with the order of the bytes
                buffer.order(acquisition.getByteOrder());
                //read the integers
                DoubleBuffer doubleBuffer = buffer.asDoubleBuffer();
                doubleBuffer.get(result);
                System.arraycopy(result,0,fid,0,acquisition.getAquiredPoints());
        }

        return new Spectrum(fid, acquisition);

    }
}
