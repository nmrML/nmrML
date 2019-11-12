
package org.nmrml.model;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for Projected3DProcessingParamaterSetType complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="Projected3DProcessingParamaterSetType">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;attribute name="projectionAngle" type="{http://www.w3.org/2001/XMLSchema}double" />
 *       &lt;attribute name="positiveProjectionMethod" type="{http://www.w3.org/2001/XMLSchema}boolean" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "Projected3DProcessingParamaterSetType", namespace = "http://nmrml.org/schema")
public class Projected3DProcessingParamaterSetType {

    @XmlAttribute(name = "projectionAngle")
    protected Double projectionAngle;
    @XmlAttribute(name = "positiveProjectionMethod")
    protected Boolean positiveProjectionMethod;

    /**
     * Gets the value of the projectionAngle property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public Double getProjectionAngle() {
        return projectionAngle;
    }

    /**
     * Sets the value of the projectionAngle property.
     * 
     * @param value
     *     allowed object is
     *     {@link Double }
     *     
     */
    public void setProjectionAngle(Double value) {
        this.projectionAngle = value;
    }

    /**
     * Gets the value of the positiveProjectionMethod property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isPositiveProjectionMethod() {
        return positiveProjectionMethod;
    }

    /**
     * Sets the value of the positiveProjectionMethod property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setPositiveProjectionMethod(Boolean value) {
        this.positiveProjectionMethod = value;
    }

}
