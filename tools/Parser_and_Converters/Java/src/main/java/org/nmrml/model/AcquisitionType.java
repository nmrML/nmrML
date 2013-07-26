
package org.nmrml.model;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for AcquisitionType complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="AcquisitionType">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;choice>
 *         &lt;element name="acquisition1D" type="{http://nmrml.org/schema}Acquisition1DType"/>
 *         &lt;element name="acquisition2D" type="{http://nmrml.org/schema}Acquisition2DType"/>
 *       &lt;/choice>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "AcquisitionType", namespace = "http://nmrml.org/schema", propOrder = {
    "acquisition1D",
    "acquisition2D"
})
public class AcquisitionType {

    @XmlElement(namespace = "http://nmrml.org/schema")
    protected Acquisition1DType acquisition1D;
    @XmlElement(namespace = "http://nmrml.org/schema")
    protected Acquisition2DType acquisition2D;

    /**
     * Gets the value of the acquisition1D property.
     * 
     * @return
     *     possible object is
     *     {@link Acquisition1DType }
     *     
     */
    public Acquisition1DType getAcquisition1D() {
        return acquisition1D;
    }

    /**
     * Sets the value of the acquisition1D property.
     * 
     * @param value
     *     allowed object is
     *     {@link Acquisition1DType }
     *     
     */
    public void setAcquisition1D(Acquisition1DType value) {
        this.acquisition1D = value;
    }

    /**
     * Gets the value of the acquisition2D property.
     * 
     * @return
     *     possible object is
     *     {@link Acquisition2DType }
     *     
     */
    public Acquisition2DType getAcquisition2D() {
        return acquisition2D;
    }

    /**
     * Sets the value of the acquisition2D property.
     * 
     * @param value
     *     allowed object is
     *     {@link Acquisition2DType }
     *     
     */
    public void setAcquisition2D(Acquisition2DType value) {
        this.acquisition2D = value;
    }

}
