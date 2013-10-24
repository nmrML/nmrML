
package org.nmrml.model;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlSeeAlso;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for AcquisitionParameterSet1DType complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="AcquisitionParameterSet1DType">
 *   &lt;complexContent>
 *     &lt;extension base="{http://nmrml.org/schema}AcquisitionParameterSetType">
 *     &lt;/extension>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "AcquisitionParameterSet1DType", namespace = "http://nmrml.org/schema")
@XmlSeeAlso({
    org.nmrml.model.Acquisition1DType.AcquisitionParameterSet.class
})
public class AcquisitionParameterSet1DType
    extends AcquisitionParameterSetType
{


}
