/*
 * CC-BY 4.0
 */

package org.nmrml.parser.bruker;

import org.nmrml.parser.Acqu;

/**
 * Acquisition parameter reader
 *
 * @author Luis F. de Figueiredo
 *
 * User: ldpf
 * Date: 02/04/2013
 * Time: 16:24
 *
 */
public interface AcquReader {
    Acqu read() throws Exception;
}