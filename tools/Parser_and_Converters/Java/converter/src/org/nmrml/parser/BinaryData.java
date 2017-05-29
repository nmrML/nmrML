/*
 * CC-BY 4.0
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
import java.util.*;
import java.lang.*;

import javax.xml.bind.DatatypeConverter;


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
        hByteFormat.put("complex64", new int[] {4, 2, tFloat });
        hByteFormat.put("complex128", new int[] {8, 2, tDouble });
    }

    private static final Map<Integer, double[]> hGRPDLY_matrix;
    static
    {
        hGRPDLY_matrix = new HashMap<Integer, double[]>();
        hGRPDLY_matrix.put(   2, new double[] {44.7500, 46.0000, 46.3110, 2.750});
        hGRPDLY_matrix.put(   3, new double[] {33.5000, 36.5000, 36.5300, 2.833});
        hGRPDLY_matrix.put(   4, new double[] {66.6250, 48.0000, 47.8700, 2.875});
        hGRPDLY_matrix.put(   6, new double[] {59.0833, 50.1667, 50.2290, 2.917});
        hGRPDLY_matrix.put(   8, new double[] {68.5625, 53.2500, 53.2890, 2.938});
        hGRPDLY_matrix.put(  12, new double[] {60.3750, 69.5000, 69.5510, 2.958});
        hGRPDLY_matrix.put(  16, new double[] {69.5313, 72.2500, 71.6000, 2.969});
        hGRPDLY_matrix.put(  24, new double[] {61.0208, 70.1667, 70.1840, 2.979});
        hGRPDLY_matrix.put(  32, new double[] {70.0156, 72.7500, 72.1380, 2.984});
        hGRPDLY_matrix.put(  48, new double[] {61.3438, 70.5000, 70.5280, 2.989});
        hGRPDLY_matrix.put(  64, new double[] {70.2578, 73.0000, 72.3480, 2.992});
        hGRPDLY_matrix.put(  96, new double[] {61.5052, 70.6667, 70.7000, 2.995});
        hGRPDLY_matrix.put( 128, new double[] {70.3789, 72.5000, 72.5240, 0.000});
        hGRPDLY_matrix.put( 192, new double[] {61.5859, 71.3333, 71.3333, 0.000});
        hGRPDLY_matrix.put( 256, new double[] {70.4395, 72.2500, 72.2500, 0.000});
        hGRPDLY_matrix.put( 384, new double[] {61.6263, 71.6667, 71.6667, 0.000});
        hGRPDLY_matrix.put( 512, new double[] {70.4697, 72.1250, 72.1250, 0.000});
        hGRPDLY_matrix.put( 768, new double[] {61.6465, 71.8333, 71.8333, 0.000});
        hGRPDLY_matrix.put(1024, new double[] {70.4849, 72.0625, 72.0625, 0.000});
        hGRPDLY_matrix.put(1536, new double[] {61.6566, 71.9167, 71.9167, 0.000});
        hGRPDLY_matrix.put(2048, new double[] {70.4924, 72.0313, 72.0313, 0.000});
    }

    public int[] getEncodedSize () {
       return this.hByteFormat.get(this.getByteFormat());
    }

    public double getGroupDelay (int DECIM, int DSPFVS) {
       double[] vec = this.hGRPDLY_matrix.get(DECIM);
       return( vec[DSPFVS - 10] );
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

    public double[] getDataAsDouble(ByteOrder... byteOrder) {
        int[] encoded = this.getEncodedSize();
        int encodedSize = encoded[0];
        double[] doubles = new double[this.data.length / encodedSize];
        for(int i=0;i<doubles.length;i++){
           ByteBuffer buffer = ByteBuffer.wrap(this.data, i*encodedSize, encodedSize);
           buffer.order( byteOrder.length > 0 ? byteOrder[0] : ByteOrder.LITTLE_ENDIAN );
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

    public byte[] DoublesToByteArray(double values[]) {
       byte[] buf = new byte[8*values.length];
       int offset = 0;
       for(int i = 0; i < values.length; i++) {
            ByteBuffer buffer = ByteBuffer.allocate(8);
            buffer.order(ByteOrder.LITTLE_ENDIAN);
            byte [] bytes = buffer.putDouble(values[i]).array();
            for (int j=0; j<8; j++) buf[offset+j] = bytes[j];
            offset += 8;
       }
       return buf;
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

           // First step: convert bytes to doubles
           String byteFormat = "";
           switch (acq.getBiteSyze()) {
              case 4: 
                 if (floattype) {
                     byteFormat = "float32";
                 } else {
                     byteFormat = "integer32";
                 }
                 break;
              case 8: 
                 byteFormat = "float64";
                 break;
           }
           this.setData(buffer.array());
           this.setEncodedLength(BigInteger.valueOf(this.getData().length));
           this.setByteFormat(byteFormat);

           double [] dataValues = this.getDataAsDouble(acq.getByteOrder());

           // If Bruker FID , then apply the group delay correction 
            if ( acq.getSpectrometer().equals(Acqu.Spectrometer.BRUKER) && isComplex ) {
 
               double GRPDLY = acq.getDspGroupDelay();
 
               if (Double.isNaN(GRPDLY) || GRPDLY<=0 ) {
                   GRPDLY = this.getGroupDelay (acq.getDspDecimation(), acq.getDspFirmware());
               }
 
               double [] Spectrum1 = FFTBase.fft2(dataValues, false);
               double [] Spectrum2 = new double[Spectrum1.length];
               int n = Spectrum1.length/2;
               double ndbl = n;
               double phi = (GRPDLY*2*Math.PI)/ndbl;
               int p = n/2;
               for (int i=0; i<p; i++) {
                      Spectrum2[2*i]   = Spectrum1[n+2*i]; Spectrum2[2*i+1]   = Spectrum1[n+2*i+1];
                      Spectrum2[n+2*i] = Spectrum1[2*i];   Spectrum2[n+2*i+1] = Spectrum1[2*i+1];
               }
               for (int i=0; i<n; i++) {
                      double idbl = (double) i;
                      double theta = phi*idbl;
                      Spectrum1[2*i]   = Spectrum2[2*i]*Math.cos(theta)  - Spectrum2[2*i+1]*Math.sin(theta);
                      Spectrum1[2*i+1] = Spectrum2[2*i]*Math.sin(theta)  + Spectrum2[2*i+1]*Math.cos(theta);
               }
               for (int i=0; i<p; i++) {
                      Spectrum2[2*i]   = Spectrum1[n+2*i]; Spectrum2[2*i+1]   = Spectrum1[n+2*i+1];
                      Spectrum2[n+2*i] = Spectrum1[2*i];   Spectrum2[n+2*i+1] = Spectrum1[2*i+1];
               }
               dataValues = FFTBase.fft2(Spectrum2, true);
            }

           // Second step: convert doubles to 64bits, LITTLE ENDIAN
           byte[] buf = DoublesToByteArray(dataValues);

           if (isComplex) {
               byteFormat="Complex128";
           }
           else {
               byteFormat="float64";
           }
           acq.setBiteSyze(8);
           acq.setByteOrder(ByteOrder.LITTLE_ENDIAN);

           if (isCompressed) {
              this.setData(compress(buf));
           } else {
              this.setData(buf);
           }

           this.compressed=isCompressed;
           // Here the Base64 encoding is just for knowing the encoded length
           String base64String = DatatypeConverter.printBase64Binary(this.getData());
           this.setEncodedLength(BigInteger.valueOf(base64String.length()));
           this.setByteFormat(byteFormat);
           this.exists = true;
           MessageDigest md = null;
           try {
               md = MessageDigest.getInstance("SHA-1");
           }
           catch(NoSuchAlgorithmException e) {
               e.printStackTrace();
           }
           md.update(this.getData());
           this.setSha1(convertToHex(md.digest()));

        }
    }
}
