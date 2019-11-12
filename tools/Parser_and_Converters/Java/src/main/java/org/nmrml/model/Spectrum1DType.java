
package org.nmrml.model;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for Spectrum1DType complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="Spectrum1DType">
 *   &lt;complexContent>
 *     &lt;extension base="{http://nmrml.org/schema}SpectrumType">
 *       &lt;sequence>
 *         &lt;element name="firstDimensionProcessingParameterSet" type="{http://nmrml.org/schema}FirstDimensionProcessingParameterSetType"/>
 *       &lt;/sequence>
 *     &lt;/extension>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "Spectrum1DType", namespace = "http://nmrml.org/schema", propOrder = {
    "firstDimensionProcessingParameterSet"
})
public class Spectrum1DType
    extends SpectrumType
{

    @XmlElement(namespace = "http://nmrml.org/schema", required = true)
    protected FirstDimensionProcessingParameterSetType firstDimensionProcessingParameterSet;

    /**
     * Gets the value of the firstDimensionProcessingParameterSet property.
     * 
     * @return
     *     possible object is
     *     {@link FirstDimensionProcessingParameterSetType }
     *     
     */
    public FirstDimensionProcessingParameterSetType getFirstDimensionProcessingParameterSet() {
        return firstDimensionProcessingParameterSet;
    }

    /**
     * Sets the value of the firstDimensionProcessingParameterSet property.
     * 
     * @param value
     *     allowed object is
     *     {@link FirstDimensionProcessingParameterSetType }
     *     
     */
    public void setFirstDimensionProcessingParameterSet(FirstDimensionProcessingParameterSetType value) {
        this.firstDimensionProcessingParameterSet = value;
    }

}
