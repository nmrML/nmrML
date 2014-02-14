
package org.nmrml.schema;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for Acquisition1DType complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="Acquisition1DType">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="acquisitionParameterSet" type="{http://nmrml.org/schema}AcquisitionParameterSet1DType"/>
 *         &lt;element name="fidData" type="{http://nmrml.org/schema}BinaryDataArrayType"/>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "Acquisition1DType", propOrder = {
    "acquisitionParameterSet",
    "fidData"
})
public class Acquisition1DType {

    @XmlElement(required = true)
    protected AcquisitionParameterSet1DType acquisitionParameterSet;
    @XmlElement(required = true)
    protected BinaryDataArrayType fidData;

    /**
     * Gets the value of the acquisitionParameterSet property.
     * 
     * @return
     *     possible object is
     *     {@link AcquisitionParameterSet1DType }
     *     
     */
    public AcquisitionParameterSet1DType getAcquisitionParameterSet() {
        return acquisitionParameterSet;
    }

    /**
     * Sets the value of the acquisitionParameterSet property.
     * 
     * @param value
     *     allowed object is
     *     {@link AcquisitionParameterSet1DType }
     *     
     */
    public void setAcquisitionParameterSet(AcquisitionParameterSet1DType value) {
        this.acquisitionParameterSet = value;
    }

    /**
     * Gets the value of the fidData property.
     * 
     * @return
     *     possible object is
     *     {@link BinaryDataArrayType }
     *     
     */
    public BinaryDataArrayType getFidData() {
        return fidData;
    }

    /**
     * Sets the value of the fidData property.
     * 
     * @param value
     *     allowed object is
     *     {@link BinaryDataArrayType }
     *     
     */
    public void setFidData(BinaryDataArrayType value) {
        this.fidData = value;
    }

}
