/*
 * CC-BY 4.0
 */

package org.nmrml.parser.jeol;

import org.nmrml.parser.Acqu;

/**
 * Acquisition parameter reader
 *
 *
 */
public interface AcquReader {
    Acqu read() throws Exception;
}