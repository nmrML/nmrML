
package org.nmrml.model;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlSchemaType;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for SpectralProjectionParameterSetType complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="SpectralProjectionParameterSetType">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="projectionMethod" type="{http://nmrml.org/schema}CVTermType"/>
 *       &lt;/sequence>
 *       &lt;attribute name="projectionAxis" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "SpectralProjectionParameterSetType", namespace = "http://nmrml.org/schema", propOrder = {
    "projectionMethod"
})
public class SpectralProjectionParameterSetType {

    @XmlElement(namespace = "http://nmrml.org/schema", required = true)
    protected CVTermType projectionMethod;
    @XmlAttribute(name = "projectionAxis")
    @XmlSchemaType(name = "anySimpleType")
    protected String projectionAxis;

    /**
     * Gets the value of the projectionMethod property.
     * 
     * @return
     *     possible object is
     *     {@link CVTermType }
     *     
     */
    public CVTermType getProjectionMethod() {
        return projectionMethod;
    }

    /**
     * Sets the value of the projectionMethod property.
     * 
     * @param value
     *     allowed object is
     *     {@link CVTermType }
     *     
     */
    public void setProjectionMethod(CVTermType value) {
        this.projectionMethod = value;
    }

    /**
     * Gets the value of the projectionAxis property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getProjectionAxis() {
        return projectionAxis;
    }

    /**
     * Sets the value of the projectionAxis property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setProjectionAxis(String value) {
        this.projectionAxis = value;
    }

}
