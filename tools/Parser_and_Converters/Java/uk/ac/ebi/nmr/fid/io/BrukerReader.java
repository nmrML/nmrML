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

package uk.ac.ebi.nmr.fid.io;


import java.io.File;
import java.io.FileNotFoundException;

/**
 * General Bruker reader that uses the folder structure from Bruker software to read the spectrometer
 *
 * @author Luis F. de Figueiredo
 *
 * User: ldpf
 * Date: 21/09/2012
 * Time: 14:46
 *
 */
public class BrukerReader {

    private String fidFileName = null;
    private File acquFile = null;
    private File procFile = null;


    public BrukerReader() {
    }

    public BrukerReader(String filename) throws FileNotFoundException {

        this.fidFileName = filename;
        File fidFile = new File(this.fidFileName);
        String workingDIR = fidFile.getParent();
        this.acquFile = new File(workingDIR + "/acqu");
        // TODO make other PROC files available
        this.procFile = new File(workingDIR + "/pdata/1/proc");

    }




    /**
     * read proc file and extract the paramenters. Note that can be more than one processing.
     *
     * @param processingNb
     */
    private void readPROC(int processingNb) {

    }


}
