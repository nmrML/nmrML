
package org.nmrml.model;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for Acquisition2DType complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="Acquisition2DType">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="acquisitionParameterSet" type="{http://nmrml.org/schema}AcquisitionParameterSet2DType"/>
 *         &lt;element name="fid" type="{http://nmrml.org/schema}BinaryDataArrayType"/>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "Acquisition2DType", propOrder = {
    "acquisitionParameterSet",
    "fid"
})
public class Acquisition2DType {

    @XmlElement(required = true)
    protected AcquisitionParameterSet2DType acquisitionParameterSet;
    @XmlElement(required = true)
    protected BinaryDataArrayType fid;

    /**
     * Gets the value of the acquisitionParameterSet property.
     * 
     * @return
     *     possible object is
     *     {@link AcquisitionParameterSet2DType }
     *     
     */
    public AcquisitionParameterSet2DType getAcquisitionParameterSet() {
        return acquisitionParameterSet;
    }

    /**
     * Sets the value of the acquisitionParameterSet property.
     * 
     * @param value
     *     allowed object is
     *     {@link AcquisitionParameterSet2DType }
     *     
     */
    public void setAcquisitionParameterSet(AcquisitionParameterSet2DType value) {
        this.acquisitionParameterSet = value;
    }

    /**
     * Gets the value of the fid property.
     * 
     * @return
     *     possible object is
     *     {@link BinaryDataArrayType }
     *     
     */
    public BinaryDataArrayType getFid() {
        return fid;
    }

    /**
     * Sets the value of the fid property.
     * 
     * @param value
     *     allowed object is
     *     {@link BinaryDataArrayType }
     *     
     */
    public void setFid(BinaryDataArrayType value) {
        this.fid = value;
    }

}
