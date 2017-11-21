/*
 * Copyright (c) 2014 EMBL, European Bioinformatics Institute
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

package org.nmrml.cv;

import org.ini4j.Ini;
import org.ini4j.Wini;
import org.nmrml.model.CVParamType;
import org.nmrml.model.CVType;
import org.nmrml.model.ObjectFactory;

import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;

/**
 * Created with IntelliJ IDEA.
 *
 * @author Luis F. de Figueiredo
 *
 * User: ldpf
 * Date: 02/10/2013
 * Time: 11:49
 * To change this template use File | Settings | File Templates.
 */
public class CVLoader {

    private HashMap<String,CVType> cvTypeHashMap;
    private Wini ontologyIni;

    public CVLoader() throws IOException {
        this(ClassLoader.getSystemResourceAsStream("org/nmrml/ontologies/onto.ini"));
    }

    public CVLoader(InputStream inputStream) throws IOException {
        this.ontologyIni = new Wini(inputStream);
        this.cvTypeHashMap = new HashMap<String, CVType>();
    }

    public CVParamType fetchCVParam(String ontology, String term) throws Exception {
        // automatically add the ontology to the cv list
        if(!cvTypeHashMap.containsKey(ontology)){
            CVType cvType = new ObjectFactory().createCVType();
            Ini.Section ontologies = ontologyIni.get("ontologies");

            if(!ontologies.containsKey(ontology))
                throw new Exception("ontology ["+ ontology +"] not found");

            cvType.setId(ontology);
            String [] ontologyData = ontologies.get(ontology).split(";");
            cvType.setFullName(ontologyData[0]);
            cvType.setVersion(ontologyData[1]);
            cvType.setURI(ontologyData[2]);
            cvTypeHashMap.put(ontology,cvType);
        }

        Ini.Section ontologyTerms = ontologyIni.get(ontology);
        String cvTerm = ontologyTerms.fetch(term);
        if(cvTerm == null)
            throw new Exception("Term ["+term + "] not found in "+ontology);
        CVParamType cvParamType = new ObjectFactory().createCVParamType();
        cvParamType.setCvRef(cvTypeHashMap.get(ontology));
        cvParamType.setAccession(cvTerm.split(";")[0]);
        cvParamType.setName(cvTerm.split(";")[1]);
        return cvParamType;
    }

    public HashMap<String, CVType> getCvTypeHashMap() {
        return cvTypeHashMap;
    }
}
