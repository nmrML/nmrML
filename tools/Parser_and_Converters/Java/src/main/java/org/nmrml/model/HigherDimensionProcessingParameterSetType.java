
package org.nmrml.model;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlType;


/**
 * Parameters recorded when raw data set is processed to create a spectra that
 *         are specific to the second dimension.
 * 
 * <p>Java class for HigherDimensionProcessingParameterSetType complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="HigherDimensionProcessingParameterSetType">
 *   &lt;complexContent>
 *     &lt;extension base="{http://nmrml.org/schema}FirstDimensionProcessingParameterSetType">
 *     &lt;/extension>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "HigherDimensionProcessingParameterSetType", namespace = "http://nmrml.org/schema")
public class HigherDimensionProcessingParameterSetType
    extends FirstDimensionProcessingParameterSetType
{


}
