/*
 * $Id: Converter.java,v 1.0.alpha Feb 2014 (C) INRA - DJ $
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

import java.math.BigDecimal;
import java.math.BigInteger;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.channels.FileChannel;
import java.nio.file.Files;
import java.util.GregorianCalendar;

import java.util.*;
import java.lang.*;

import org.nmrml.parser.*;
import org.nmrml.parser.bruker.*;

import org.nmrml.schema.*;
import org.nmrml.cv.*;

import javax.xml.datatype.DatatypeConfigurationException;
import javax.xml.datatype.DatatypeFactory;
import javax.xml.datatype.XMLGregorianCalendar;

import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBElement;
import javax.xml.bind.JAXBException;
import javax.xml.bind.Marshaller;

public class Convert2nmrML {

    private static final String Version = "1.0b";

    private static final String nmrMLVersion = "1.0.rc1";

    public static int ID_count;

    public static String getNewIdentifier ( ) { return String.format("ID%05d",++ID_count); }

    public static BigInteger getBigInteger (Integer entier) { return new BigInteger(entier.toString()); }

    private enum Vendor_Type { bruker, varian; }

    public Convert2nmrML(  ) {    }

}
