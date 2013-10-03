/*
 * Copyright (c) 2013 EMBL, European Bioinformatics Institute
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

import org.nmrml.model.NmrMLType;
import org.nmrml.model.ObjectFactory;

import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBElement;
import javax.xml.bind.JAXBException;
import javax.xml.bind.Marshaller;
import java.io.File;
import java.nio.file.Path;
import java.nio.file.Paths;

/**
 * Created with IntelliJ IDEA.
 * User: ldpf
 * Date: 26/07/2013
 * Time: 09:26
 * To change this template use File | Settings | File Templates.
 */
public class BrukerAcquReaderTest {



    @org.junit.Test
    public void testRead() throws Exception {
//        System.out.println(BrukerAcquReader.class.getClassLoader()
//                .getResource("org/nmrml/example/files/bruker/onedimensional/putrescine/proton/acqus").getPath());
        ObjectFactory objFactory = new ObjectFactory();
        Path path = Paths.get(BrukerAcquAbstractReader.class.getClassLoader()
                .getResource("org/nmrml/example/files/bruker/onedimensional/putrescine/proton/acqus").getPath());
        System.out.println(path.toString());
        System.out.println(path.getParent().toString()+"/acqu2");
        NmrMLType nmrMLElement = new BrukerAcquAbstractReader(new File(path.toString())).read();
//        System.out.println(acquisition.getAcquisition1D().getAcquisitionParameterSet().getDirectDimensionParameterSet().getSweepWidth());
//        NmrMLType nmrMLType = new NmrMLType();
//        nmrMLType.setAcquisition(acquisition);


        /* Generate XML */
        try{

            JAXBElement<NmrMLType> nmrML = (JAXBElement<NmrMLType>) objFactory.createNmrML(nmrMLElement);

            // create a JAXBContext capable of handling classes generated into the org.nmrml.schema package
            JAXBContext jc = JAXBContext.newInstance( "org.nmrml.model" );

            // create a Marshaller and marshal to a file
            Marshaller m = jc.createMarshaller();
            m.setProperty( Marshaller.JAXB_FORMATTED_OUTPUT, new Boolean(true) );
            m.setProperty(Marshaller.JAXB_SCHEMA_LOCATION, "http://nmrML.org/schema/nmrML.xsd");
            m.marshal( nmrML, System.out );

        } catch( JAXBException je ) {
            je.printStackTrace();
        }



//        AcquisitionType acquisition = new BrukerAcquAbstractReader(this.getClass().
//                getClassLoader().getResourceAsStream("bmrb/1H/acqus")).read();
//        BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(BrukerAcquReader.class.getClassLoader()
//                .getResourceAsStream("org/nmrml/example/files/bruker/onedimensional/putrescine/proton/acqus")));






//        FidReader fidReader = new Simple1DFidReader(new FileInputStream(this.getClass()
//                .getClassLoader().getResource("bmrb/1H/fid").getPath()),acquisition);
//        Spectrum spepSpectrum = fidReader.read();
//        Assert.assertNotNull("fid was not properly read", spepSpectrum);
//        Assert.assertArrayEquals("fid was not properly read", fid, spepSpectrum.getFid(),1E-12);


    }
}
