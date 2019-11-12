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

package org.nmrml.converter;

import org.nmrml.model.NmrMLType;

/**
 * Created with IntelliJ IDEA.
 *
 * @author Luis F. de Figueiredo
 *
 * User: ldpf
 * Date: 09/10/2013
 * Time: 14:19
 * To change this template use File | Settings | File Templates.
 */
public interface AcquReader {

    NmrMLType read() throws Exception;
}
