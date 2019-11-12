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

import org.nmrml.cv.BrukerMapper;
import org.nmrml.model.NmrMLType;
import org.nmrml.model.ObjectFactory;
import org.nmrml.model.SourceFileListType;
import org.nmrml.model.SourceFileType;

import java.io.File;

public class BrukerSourceFileListLoader {
    private NmrMLType nmrMLType;
    private File inputFile;
    private BrukerMapper brukerMapper;
    private ObjectFactory objectFactory;

    public BrukerSourceFileListLoader(NmrMLType nmrMLType, File inpuFile, BrukerMapper brukerMapper) {
        this.nmrMLType=nmrMLType;
        this.inputFile=inpuFile;
        this.brukerMapper=brukerMapper;
        this.objectFactory = new ObjectFactory();
    }
    //TODO make this class generic to work also with a VarianMapper
    public NmrMLType loadSourceFileList() {

        SourceFileListType sourceFileListType = objectFactory.createSourceFileListType();
        //get the name of the folder with the bruker data
        String foldername = inputFile.isFile()?inputFile.getParent():inputFile.getPath();
        //check if the filepath ends with /
        foldername= (foldername.lastIndexOf("/")== foldername.length())? foldername:foldername.concat("/");
        for (String key : brukerMapper.getSection("FILES").keySet()) {
            File file = new File(foldername + brukerMapper.getTerm("FILES", key));
            SourceFileType sourceFileType = objectFactory.createSourceFileType();
            if (file.exists()) {
                sourceFileType.setId(key);
                sourceFileType.setLocation(file.toURI().toString());
                sourceFileType.setName(file.getName());
                sourceFileListType.getSourceFile().add(sourceFileType);
            }
        }
        nmrMLType.setSourceFileList(sourceFileListType);
        return nmrMLType;
    }
}