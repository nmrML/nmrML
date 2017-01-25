package org.nmrml.cv;

import junit.framework.Assert;
import org.junit.Test;
import org.nmrml.schema.CVParamType;

/**
 * Created with IntelliJ IDEA.
 * User: ldpf
 * Date: 02/10/2013
 * Time: 14:50
 * To change this template use File | Settings | File Templates.
 */
public class CVLoaderTest {
    @Test
    public void testFetchCVParam() throws Exception {
        String ontology = "UO";

        CVLoader cvLoader = new CVLoader();
        
        CVParamType cvParamType = cvLoader.fetchCVParam(ontology, "PPM");

        Assert.assertNotNull(cvParamType);

        Assert.assertEquals("Wrong Mapping","parts per million",cvParamType.getName());

        Assert.assertNotNull(cvLoader.getCvTypeHashMap());

        Assert.assertTrue("It did not load the CVType ", cvLoader.getCvTypeHashMap().containsKey(ontology));
    }

    @Test
    public void testBrukerMapping() throws Exception {
        String brukerTag = "WDW";
        String ontology = "NMRCV";
        String value = "1";
        String cvTerm = "NMR:1400069";

        BrukerMapper brukerMapper = new BrukerMapper();

        Assert.assertNotNull(brukerMapper);

        CVLoader cvLoader = new CVLoader();
        // test already the Bruker mapping and the use of the ontology term
        CVParamType cvParamType = cvLoader.fetchCVParam(ontology,brukerMapper.getTerm(brukerTag,value));

        Assert.assertNotNull(cvParamType);

        Assert.assertEquals("Wrong accession value",cvTerm,cvParamType.getAccession());

    }
}
