
package org.nmrml.model;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for AcquisitionMultiDType complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="AcquisitionMultiDType">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="acquisitionParameterSet" type="{http://nmrml.org/schema}AcquisitionParameterSetMultiDType"/>
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
@XmlType(name = "AcquisitionMultiDType", namespace = "http://nmrml.org/schema", propOrder = {
    "acquisitionParameterSet",
    "fidData"
})
public class AcquisitionMultiDType {

    @XmlElement(namespace = "http://nmrml.org/schema", required = true)
    protected AcquisitionParameterSetMultiDType acquisitionParameterSet;
    @XmlElement(namespace = "http://nmrml.org/schema", required = true)
    protected BinaryDataArrayType fidData;

    /**
     * Gets the value of the acquisitionParameterSet property.
     * 
     * @return
     *     possible object is
     *     {@link AcquisitionParameterSetMultiDType }
     *     
     */
    public AcquisitionParameterSetMultiDType getAcquisitionParameterSet() {
        return acquisitionParameterSet;
    }

    /**
     * Sets the value of the acquisitionParameterSet property.
     * 
     * @param value
     *     allowed object is
     *     {@link AcquisitionParameterSetMultiDType }
     *     
     */
    public void setAcquisitionParameterSet(AcquisitionParameterSetMultiDType value) {
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
