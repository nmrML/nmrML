package org.nmrml.cv;

import junit.framework.Assert;
import org.junit.Test;

import java.io.IOException;

/**
 * Created with IntelliJ IDEA.
 * User: ldpf
 * Date: 02/10/2013
 * Time: 15:23
 * To change this template use File | Settings | File Templates.
 */
public class BrukerMapperTest {
    /**
     * Simple getTerm test
     * @throws IOException
     */
    @Test
    public void testGetTerm() throws IOException {
        String brukerTag = "BYTORDA";
        String value = "0";
        String term = "LITTLE_ENDIAN";
        BrukerMapper brukerMapper = new BrukerMapper();

        Assert.assertNotNull(brukerMapper);

        Assert.assertEquals("Wrong value",term,brukerMapper.getTerm(brukerTag,value));

    }
}
