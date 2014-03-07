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

package org.nmrml.parser;

import org.nmrml.parser.Acqu;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileInputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.FileOutputStream;

import java.math.BigInteger;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.channels.FileChannel;
import java.nio.file.Files;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

//import java.util.List;
//import java.util.Map;
import java.util.zip.DataFormatException;
import java.util.zip.Deflater;
import java.util.zip.Inflater;
//import java.util.zip.GZIPInputStream;
//import java.util.zip.GZIPOutputStream;

import java.util.*;
import java.lang.*;


public class BinaryData {

    private byte[] data;
    private BigInteger encodedLength ;
    private String byteFormat;
    private boolean exists = false;
    private boolean compressed = false;
    private String sha1;

    private String convertToHex(byte[] data) {
       StringBuffer buffer = new StringBuffer();
       for (int i=0; i<data.length; i++)
       {
          if (i % 4 == 0 && i != 0)
              buffer.append("");
          int x = (int) data[i];
          if (x<0)
              x+=256;
          if (x<16)
              buffer.append("0");
          buffer.append(Integer.toString(x,16));
       }
       return buffer.toString();
    }

    public BigInteger getEncodedLength() {
        return encodedLength;
    }
    public void setEncodedLength(BigInteger encodedLength) {
        this.encodedLength = encodedLength;
    }
    public String getByteFormat() {
        return byteFormat;
    }
    public void setByteFormat(String byteFormat) {
        this.byteFormat = byteFormat;
    }
    public String getSha1() {
        return sha1;
    }
    public void setSha1(String sha1) {
        this.sha1 = sha1;
    }
    public byte[] getData() {
        return data;
    }
    public void setData(byte[] data) {
        this.data = data;
    }
    public boolean isExists() {
        return exists;
    }
    public void setCompressed(boolean compressed) {
        this.compressed=compressed;
    }
    public boolean isCompressed() {
        return compressed;
    }

    public double[] getDataAsDouble() {
        int encodedSize = (int)( this.data.length / this.encodedLength.intValue() );
        double[] doubles = new double[this.data.length / encodedSize];
System.out.println(" - DATA Length = " + this.data.length);
System.out.println(" - EncodedLength = " + this.encodedLength.intValue());
System.out.println(" - EncodedSize = " + encodedSize);
        for(int i=0;i<doubles.length;i++){
           ByteBuffer buffer = ByteBuffer.wrap(this.data, i*encodedSize, encodedSize);
           buffer.order(ByteOrder.LITTLE_ENDIAN);
           //buffer.order(ByteOrder.BIG_ENDIAN);
           if (encodedSize == 4)
              doubles[i] = (double)buffer.getInt();
           else
              doubles[i] = (double)buffer.getLong();
        }
        return doubles;
    }

/*
    public static byte[] compress(byte[] data) throws IOException {
        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
        GZIPOutputStream gzipOutputStream = new GZIPOutputStream(byteArrayOutputStream);
        gzipOutputStream.write(data);
        gzipOutputStream.close();
        return byteArrayOutputStream.toByteArray();
    }
    public static byte[] decompress(byte[] data) throws IOException {
        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
        ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(data);
        GZIPInputStream gZIPInputStream = new GZIPInputStream(byteArrayInputStream);
        byte[] tmpBuffer = new byte[256];
        int n;
        while ((n = gZIPInputStream.read(tmpBuffer)) >= 0)
            byteArrayOutputStream.write(tmpBuffer, 0, n);
        gZIPInputStream.close();
        return byteArrayOutputStream.toByteArray();
    }
*/

    public static byte[] compress(byte[] data) throws IOException {
        Deflater deflater = new Deflater();
        deflater.setInput(data);

        ByteArrayOutputStream outputStream = new ByteArrayOutputStream(data.length);

        deflater.finish();
        byte[] buffer = new byte[1024];
        while (!deflater.finished()) {
            int count = deflater.deflate(buffer); // returns the generated code... index
            outputStream.write(buffer, 0, count);
        }
        outputStream.close();
        byte[] output = outputStream.toByteArray();
       return output;
    }

    public static byte[] decompress(byte[] data) throws IOException, DataFormatException {
        Inflater inflater = new Inflater();
        inflater.setInput(data);

        ByteArrayOutputStream outputStream = new ByteArrayOutputStream(data.length);
        byte[] buffer = new byte[1024];
        while (!inflater.finished()) {
            int count = inflater.inflate(buffer);
            outputStream.write(buffer, 0, count);
        }
        outputStream.close();
        byte[] output = outputStream.toByteArray();
        return output;
    }

    public BinaryData() {}

    public BinaryData (File inputFileData, Acqu acq) throws IOException {
        this(inputFileData,acq,false);
    }

    public BinaryData (File inputFileData, Acqu acq, boolean isCompressed) throws IOException {
        BinaryData binaryData = new BinaryData();
        if(inputFileData.isFile() && inputFileData.canRead()) {
           FileInputStream fidInput = new FileInputStream(inputFileData);
           FileChannel inChannel = fidInput.getChannel();
           BigInteger encodedLength = BigInteger.valueOf(inChannel.size() / acq.getBiteSyze());
           ByteBuffer buffer = ByteBuffer.allocate((int) inChannel.size());
           buffer.order(acq.getByteOrder());
           int bytesRead = inChannel.read(buffer);
           String byteFormat = "Integer64"; // 64 bit integer
           if (acq.getBiteSyze() == 4) { // values as 32 bit integer
               byteFormat = "Integer32";
           }
           if (isCompressed) {
              this.setData(compress(buffer.array()));
           } else {
              this.setData(buffer.array());
           }
           this.compressed=isCompressed;
           this.setEncodedLength(encodedLength);
           this.setByteFormat(byteFormat);
           this.exists = true;
           MessageDigest md = null;
           try {
               md = MessageDigest.getInstance("SHA-1");
           }
           catch(NoSuchAlgorithmException e) {
               e.printStackTrace();
           }
           md.update(buffer.array(), 0, bytesRead);
           this.setSha1(convertToHex(md.digest()));
        }
    }
}
