package org.nmrml.converter;

import org.nmrml.model.NmrMLType;

import java.io.IOException;
import java.security.NoSuchAlgorithmException;

/**
 * Created with IntelliJ IDEA.
 * User: ldpf
 * Date: 09/10/2013
 * Time: 14:19
 * To change this template use File | Settings | File Templates.
 */
public interface AcquReader {

    NmrMLType read() throws IOException, NoSuchAlgorithmException;
}
