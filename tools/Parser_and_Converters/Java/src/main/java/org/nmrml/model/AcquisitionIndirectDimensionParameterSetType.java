
package org.nmrml.model;

import java.math.BigInteger;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlSchemaType;
import javax.xml.bind.annotation.XmlType;


/**
 * Descriptions of the acquisition parameters set prior to the start of data
 *         acquisition specific to each NMR analysis dimension.
 * 
 * <p>Java class for AcquisitionIndirectDimensionParameterSetType complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="AcquisitionIndirectDimensionParameterSetType">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="acquisitionNucleus" type="{http://nmrml.org/schema}CVTermType"/>
 *         &lt;element name="effectiveExcitationField" type="{http://nmrml.org/schema}ValueWithUnitType"/>
 *         &lt;element name="sweepWidth" type="{http://nmrml.org/schema}ValueWithUnitType"/>
 *         &lt;element name="timeDomain" type="{http://nmrml.org/schema}BinaryDataArrayType"/>
 *         &lt;element name="encodingMethod" type="{http://nmrml.org/schema}CVTermType"/>
 *         &lt;element name="irradiationFrequency" type="{http://nmrml.org/schema}ValueWithUnitType"/>
 *       &lt;/sequence>
 *       &lt;attribute name="decoupled" use="required" type="{http://www.w3.org/2001/XMLSchema}boolean" />
 *       &lt;attribute name="acquisitionParamsFileRef" use="required" type="{http://www.w3.org/2001/XMLSchema}anyURI" />
 *       &lt;attribute name="numberOfDataPoints" use="required" type="{http://www.w3.org/2001/XMLSchema}integer" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "AcquisitionIndirectDimensionParameterSetType", namespace = "http://nmrml.org/schema", propOrder = {
    "acquisitionNucleus",
    "effectiveExcitationField",
    "sweepWidth",
    "timeDomain",
    "encodingMethod",
    "irradiationFrequency"
})
public class AcquisitionIndirectDimensionParameterSetType {

    @XmlElement(namespace = "http://nmrml.org/schema", required = true)
    protected CVTermType acquisitionNucleus;
    @XmlElement(namespace = "http://nmrml.org/schema", required = true)
    protected ValueWithUnitType effectiveExcitationField;
    @XmlElement(namespace = "http://nmrml.org/schema", required = true)
    protected ValueWithUnitType sweepWidth;
    @XmlElement(namespace = "http://nmrml.org/schema", required = true)
    protected BinaryDataArrayType timeDomain;
    @XmlElement(namespace = "http://nmrml.org/schema", required = true)
    protected CVTermType encodingMethod;
    @XmlElement(namespace = "http://nmrml.org/schema", required = true)
    protected ValueWithUnitType irradiationFrequency;
    @XmlAttribute(name = "decoupled", required = true)
    protected boolean decoupled;
    @XmlAttribute(name = "acquisitionParamsFileRef", required = true)
    @XmlSchemaType(name = "anyURI")
    protected String acquisitionParamsFileRef;
    @XmlAttribute(name = "numberOfDataPoints", required = true)
    protected BigInteger numberOfDataPoints;

    /**
     * Gets the value of the acquisitionNucleus property.
     * 
     * @return
     *     possible object is
     *     {@link CVTermType }
     *     
     */
    public CVTermType getAcquisitionNucleus() {
        return acquisitionNucleus;
    }

    /**
     * Sets the value of the acquisitionNucleus property.
     * 
     * @param value
     *     allowed object is
     *     {@link CVTermType }
     *     
     */
    public void setAcquisitionNucleus(CVTermType value) {
        this.acquisitionNucleus = value;
    }

    /**
     * Gets the value of the effectiveExcitationField property.
     * 
     * @return
     *     possible object is
     *     {@link ValueWithUnitType }
     *     
     */
    public ValueWithUnitType getEffectiveExcitationField() {
        return effectiveExcitationField;
    }

    /**
     * Sets the value of the effectiveExcitationField property.
     * 
     * @param value
     *     allowed object is
     *     {@link ValueWithUnitType }
     *     
     */
    public void setEffectiveExcitationField(ValueWithUnitType value) {
        this.effectiveExcitationField = value;
    }

    /**
     * Gets the value of the sweepWidth property.
     * 
     * @return
     *     possible object is
     *     {@link ValueWithUnitType }
     *     
     */
    public ValueWithUnitType getSweepWidth() {
        return sweepWidth;
    }

    /**
     * Sets the value of the sweepWidth property.
     * 
     * @param value
     *     allowed object is
     *     {@link ValueWithUnitType }
     *     
     */
    public void setSweepWidth(ValueWithUnitType value) {
        this.sweepWidth = value;
    }

    /**
     * Gets the value of the timeDomain property.
     * 
     * @return
     *     possible object is
     *     {@link BinaryDataArrayType }
     *     
     */
    public BinaryDataArrayType getTimeDomain() {
        return timeDomain;
    }

    /**
     * Sets the value of the timeDomain property.
     * 
     * @param value
     *     allowed object is
     *     {@link BinaryDataArrayType }
     *     
     */
    public void setTimeDomain(BinaryDataArrayType value) {
        this.timeDomain = value;
    }

    /**
     * Gets the value of the encodingMethod property.
     * 
     * @return
     *     possible object is
     *     {@link CVTermType }
     *     
     */
    public CVTermType getEncodingMethod() {
        return encodingMethod;
    }

    /**
     * Sets the value of the encodingMethod property.
     * 
     * @param value
     *     allowed object is
     *     {@link CVTermType }
     *     
     */
    public void setEncodingMethod(CVTermType value) {
        this.encodingMethod = value;
    }

    /**
     * Gets the value of the irradiationFrequency property.
     * 
     * @return
     *     possible object is
     *     {@link ValueWithUnitType }
     *     
     */
    public ValueWithUnitType getIrradiationFrequency() {
        return irradiationFrequency;
    }

    /**
     * Sets the value of the irradiationFrequency property.
     * 
     * @param value
     *     allowed object is
     *     {@link ValueWithUnitType }
     *     
     */
    public void setIrradiationFrequency(ValueWithUnitType value) {
        this.irradiationFrequency = value;
    }

    /**
     * Gets the value of the decoupled property.
     * 
     */
    public boolean isDecoupled() {
        return decoupled;
    }

    /**
     * Sets the value of the decoupled property.
     * 
     */
    public void setDecoupled(boolean value) {
        this.decoupled = value;
    }

    /**
     * Gets the value of the acquisitionParamsFileRef property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getAcquisitionParamsFileRef() {
        return acquisitionParamsFileRef;
    }

    /**
     * Sets the value of the acquisitionParamsFileRef property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setAcquisitionParamsFileRef(String value) {
        this.acquisitionParamsFileRef = value;
    }

    /**
     * Gets the value of the numberOfDataPoints property.
     * 
     * @return
     *     possible object is
     *     {@link BigInteger }
     *     
     */
    public BigInteger getNumberOfDataPoints() {
        return numberOfDataPoints;
    }

    /**
     * Sets the value of the numberOfDataPoints property.
     * 
     * @param value
     *     allowed object is
     *     {@link BigInteger }
     *     
     */
    public void setNumberOfDataPoints(BigInteger value) {
        this.numberOfDataPoints = value;
    }

}
