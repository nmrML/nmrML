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

package org.nmrml.converter;

import org.nmrml.converter.Acqu;

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
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

import java.net.*;
import java.io.*;
import java.util.*;
import java.lang.*;


public class BinaryData {

    private byte[] data;
    private BigInteger encodedLength ;
    private String byteFormat;
    private boolean exists = false;
    private String sha1;

    public BinaryData() {}

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

    public BinaryData (File inputFileData, Acqu acq) throws IOException {
        BinaryData binaryData = new BinaryData();
        if(inputFileData.isFile() && inputFileData.canRead()) {
           FileInputStream fidInput = new FileInputStream(inputFileData);
           FileChannel inChannel = fidInput.getChannel();
           BigInteger encodedLength = BigInteger.valueOf(inChannel.size() / acq.getBiteSyze());
           ByteBuffer buffer = ByteBuffer.allocate((int) inChannel.size());
           buffer.order(acq.getByteOrder());
           int bytesRead = inChannel.read(buffer);
           String byteFormat = Long.class.toString(); // 64 bit integer
           if (acq.getBiteSyze() == 4) { // values as 32 bit integer
               byteFormat = Integer.class.toString();
           }
           this.setData(buffer.array());
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
