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
import java.util.Map;
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

    private static final int tInteger = 1;
    private static final int tLong = 2;
    private static final int tFloat = 3;
    private static final int tDouble = 4;

    private static final Map<String, int[]> hByteFormat;
    static
    {
        hByteFormat = new HashMap<String, int[]>();
        hByteFormat.put("integer32", new int[] {4, 1, tInteger });
        hByteFormat.put("integer64", new int[] {8, 1, tLong });
        hByteFormat.put("float32", new int[] {4, 1, tFloat });
        hByteFormat.put("float64", new int[] {8, 1, tDouble });
        hByteFormat.put("complex64int", new int[] {4, 2, tInteger });
        hByteFormat.put("complex128int", new int[] {8, 2, tLong });
        hByteFormat.put("complex64", new int[] {4, 2, tFloat });
        hByteFormat.put("complex128", new int[] {8, 2, tDouble });
    }

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

    public int[] getEncodedSize () {
       return this.hByteFormat.get(this.getByteFormat());
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
        int[] encoded = this.getEncodedSize();
        int encodedSize = encoded[0];
        double[] doubles = new double[this.data.length / encodedSize];
        for(int i=0;i<doubles.length;i++){
           ByteBuffer buffer = ByteBuffer.wrap(this.data, i*encodedSize, encodedSize);
           buffer.order(ByteOrder.LITTLE_ENDIAN);
           switch (encoded[2]) {
                  case tInteger: doubles[i] = (double)buffer.getInt();
                      break;
                  case tLong: doubles[i] = (double)buffer.getLong();
                      break;
                  case tFloat: doubles[i] = (double)buffer.getFloat();
                      break;
                  case tDouble: doubles[i] = (double)buffer.getDouble();
                      break;
           }
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
    public int[] toInt(byte buf[], ByteOrder byteOrder) {
       int intArr[] = new int[buf.length / 4];
       int offset = 0;
       for(int i = 0; i < intArr.length; i++) {
          if (byteOrder.equals(ByteOrder.BIG_ENDIAN)) {
               intArr[i] = (buf[3 + offset] & 0xFF) | ((buf[2 + offset] & 0xFF) << 8) |
                           ((buf[1 + offset] & 0xFF) << 16) | ((buf[0 + offset] & 0xFF) << 24);
          }
          else {
               intArr[i] = (buf[0 + offset] & 0xFF) | ((buf[1 + offset] & 0xFF) << 8) |
                           ((buf[2 + offset] & 0xFF) << 16) | ((buf[3 + offset] & 0xFF) << 24);
          }
          offset += 4;
       }
       return intArr;
    }

    public byte[] BigToLittle(byte buf[]) {
       byte[] newbuf = new byte[buf.length];
       int  bytesize = buf.length / 4;
       int offset = 0;
       for(int i = 0; i < bytesize; i++) {
          newbuf[0 + offset] = buf[3 + offset];
          newbuf[1 + offset] = buf[2 + offset];
          newbuf[2 + offset] = buf[1 + offset];
          newbuf[3 + offset] = buf[0 + offset];
          offset += 4;
       }
       return newbuf;
    }

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

    public BinaryData (File inputFileData, Acqu acq, boolean isComplex) throws IOException {
        this(inputFileData,acq,isComplex,false);
    }

    public BinaryData (File inputFileData, Acqu acq, boolean isComplex, boolean isCompressed) throws IOException {
        BinaryData binaryData = new BinaryData();
        if(inputFileData.isFile() && inputFileData.canRead()) {
           FileInputStream fidInput = new FileInputStream(inputFileData);
           FileChannel inChannel = fidInput.getChannel();

           int bytes2read = 0;
           boolean floattype=false;
           switch (acq.getSpectrometer()){
              case VARIAN :
                  // Read File Header (8*4 bytes + Block Header (7*4 bytes) = 60 bytes
                  // see http://qa.nmrwiki.org/question/74/varian-data-storage-float-vs-int
                  //     http://cbi.nyu.edu/svn/mrTools/trunk/mrUtilities/File/Varian/vnmrdata.h
                  ByteBuffer bHeader = ByteBuffer.allocate(60);
                  bHeader.order(acq.getByteOrder());
                  int bytesHeader = inChannel.read(bHeader);
                  int[] dataHeader = toInt(bHeader.array(),acq.getByteOrder());
                  if ( (dataHeader[6] & 0x08) !=0 ) floattype=true;
                  acq.setBiteSyze(dataHeader[3]);
                  bytes2read = dataHeader[4];
                  break;
              case BRUKER :
                  bytes2read = (int) inChannel.size();
                  break;
              default:
                  break;
           }
           ByteBuffer buffer = ByteBuffer.allocate(bytes2read);
           buffer.order(acq.getByteOrder());
           int bytesRead = inChannel.read(buffer);

           String byteFormat = "";
           switch (acq.getBiteSyze()) {
              case 4: 
                 if (floattype) {
                     if (isComplex) byteFormat = "complex64"; else byteFormat = "float32";
                 } else {
                     if (isComplex) byteFormat = "complex64int"; else byteFormat = "integer32";
                 }
                 break;
              case 8: 
                 if (isComplex) byteFormat = "complex128"; else byteFormat = "float64";
                 break;
           }

           byte[] buf = buffer.array();
           if (acq.getByteOrder().equals(ByteOrder.BIG_ENDIAN)) {
               buf = BigToLittle(buffer.array());
           }
           if (isCompressed) {
              this.setData(compress(buf));
           } else {
              this.setData(buf);
           }
           this.compressed=isCompressed;
           this.setEncodedLength(BigInteger.valueOf(this.getData().length));
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
