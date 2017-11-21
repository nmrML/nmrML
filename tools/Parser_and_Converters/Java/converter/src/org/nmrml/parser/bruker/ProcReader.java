/*
 * CC-BY 4.0
 */

package org.nmrml.parser.bruker;

import org.nmrml.parser.Proc;

import java.io.IOException;

/**
 * Reader for the processing parameters
 *
 * @author Luis F. de Figueiredo
 *
 * User: ldpf
 * Date: 02/04/2013
 * Time: 16:18
 * To change this template use File | Settings | File Templates.
 */
public interface ProcReader {

    Proc read() throws IOException;

}
