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

package org.nmrml.model;

/**
 *
 * @author Luis F. de Figueiredo
 *
 * Created with IntelliJ IDEA.
 * User: ldpf
 * Date: 26/07/2013
 * Time: 09:10
 * To change this template use File | Settings | File Templates.
 */
public enum UnitsNames {

    PPM             ("ppm"),
    HZ              ("Hz"),
    MHZ             ("MHz"),
    DEGREECELSIUS   ("C");


    private final String unit;
    UnitsNames(String unit) {
        this.unit = unit;
    }

    private String unit() { return unit;}

}
