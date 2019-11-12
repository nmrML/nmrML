/*
 * CC-BY 4.0
 */

package org.nmrml.parser;

import org.nmrml.parser.Acqu;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.RandomAccessFile;
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
    private boolean crossvalues = true;
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

    public int[] getEncodedSize () {
       return this.hByteFormat.get(this.getByteFormat());
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

    public void setCrossVallues(boolean crossvalues) {
        this.crossvalues=crossvalues;
    }
    public boolean isCrossVallues() {
        return crossvalues;
    }

    public double[] getDataAsDouble(ByteOrder... byteOrder) {
        int[] encoded = this.getEncodedSize();
        int encodedSize = encoded[0];
        double[] doubles = new double[this.data.length / encodedSize];
        int ndatalen = doubles.length / 2;
        for(int i=0;i<doubles.length;i++){
           ByteBuffer buffer = buffer = ByteBuffer.wrap(this.data, i*encodedSize, encodedSize);
           int j = i;
           if (! this.isCrossVallues()) {
              if (i<ndatalen) { j=2*i; }
              else            { j=2*(i-ndatalen)+1; }
           }
           buffer.order( byteOrder.length > 0 ? byteOrder[0] : ByteOrder.LITTLE_ENDIAN );
           switch (encoded[2]) {
                  case tInteger: doubles[j] = (double)buffer.getInt();
                      break;
                  case tLong: doubles[j] = (double)buffer.getLong();
                      break;
                  case tFloat: doubles[j] = (double)buffer.getFloat();
                      break;
                  case tDouble: doubles[j] = (double)buffer.getDouble();
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
           RandomAccessFile fidInput = new RandomAccessFile(inputFileData,"r");
           FileChannel inChannel = fidInput.getChannel();
           int bytes2read = 0;
           boolean floattype=false;
           boolean crossvalues=true;
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
              case JEOL :
                   inChannel.position(acq.getDataOffset());
                   bytes2read = (int) acq.getDataLength();
                   if (isComplex) crossvalues=false;
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
           this.setCrossVallues(crossvalues);

           double [] dataValues = this.getDataAsDouble(acq.getByteOrder());

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
