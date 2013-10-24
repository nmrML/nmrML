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

import junit.framework.Assert;
import org.junit.Test;
import org.nmrml.cv.BrukerMapper;
import org.nmrml.model.NmrMLType;
import org.nmrml.model.ObjectFactory;

import java.io.File;
import java.nio.file.Path;
import java.nio.file.Paths;

/**
 * Created with IntelliJ IDEA.
 * User: ldpf
 * Date: 03/10/2013
 * Time: 18:31
 * To change this template use File | Settings | File Templates.
 */
public class BrukerSourceFileListLoaderTest {
    @Test
    public void testLoadSourceFileList() throws Exception {

        NmrMLType nmrMLType = new ObjectFactory().createNmrMLType();

        BrukerMapper brukerMapper = new BrukerMapper();
        Path path = Paths.get(BrukerAcquAbstractReader.class.getClassLoader()
                .getResource("org/nmrml/example/files/bruker/onedimensional/putrescine/proton/acqus").getPath());


        BrukerSourceFileListLoader brukerSourceFileListLoader =
                new BrukerSourceFileListLoader(nmrMLType,new File(path.toString()),brukerMapper);

        nmrMLType = brukerSourceFileListLoader.loadSourceFileList();

        Assert.assertNotNull(nmrMLType.getSourceFileList().getSourceFile());

        Assert.assertTrue(nmrMLType.getSourceFileList().getCount().intValue() > 0);

        //TODO find a better way to test these values
        Assert.assertEquals("FID_FILE",nmrMLType.getSourceFileList().getSourceFile().get(0).getId());

        Assert.assertEquals("fid",nmrMLType.getSourceFileList().getSourceFile().get(0).getName());


    }
}
