
package org.nmrml.model;

import java.math.BigInteger;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlSchemaType;
import javax.xml.bind.annotation.XmlType;


/**
 * Descriptions of the acquisition parameters set prior to the start of data acquisition specific to each NMR analysis dimension.
 * 
 * <p>Java class for AcquisitionDimensionParameterSetType complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="AcquisitionDimensionParameterSetType">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="gammaB1PulseFieldStrength" type="{http://nmrml.org/schema}ValueWithUnitType"/>
 *         &lt;element name="sweepWidth" type="{http://nmrml.org/schema}ValueWithUnitType"/>
 *         &lt;element name="timeDomain" type="{http://nmrml.org/schema}BinaryDataArrayType"/>
 *         &lt;element name="irradiationFrequency" type="{http://nmrml.org/schema}ValueWithUnitType"/>
 *       &lt;/sequence>
 *       &lt;attribute name="decoupled" use="required" type="{http://www.w3.org/2001/XMLSchema}boolean" />
 *       &lt;attribute name="acquisitionParamsFileRef" use="required" type="{http://www.w3.org/2001/XMLSchema}anyURI" />
 *       &lt;attribute name="numberOfDataPoints" use="required" type="{http://www.w3.org/2001/XMLSchema}integer" />
 *       &lt;attribute name="acquisitionNucleus" use="required" type="{http://www.w3.org/2001/XMLSchema}string" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "AcquisitionDimensionParameterSetType", namespace = "http://nmrml.org/schema", propOrder = {
    "gammaB1PulseFieldStrength",
    "sweepWidth",
    "timeDomain",
    "irradiationFrequency"
})
public class AcquisitionDimensionParameterSetType {

    @XmlElement(namespace = "http://nmrml.org/schema", required = true)
    protected ValueWithUnitType gammaB1PulseFieldStrength;
    @XmlElement(namespace = "http://nmrml.org/schema", required = true)
    protected ValueWithUnitType sweepWidth;
    @XmlElement(namespace = "http://nmrml.org/schema", required = true)
    protected BinaryDataArrayType timeDomain;
    @XmlElement(namespace = "http://nmrml.org/schema", required = true)
    protected ValueWithUnitType irradiationFrequency;
    @XmlAttribute(name = "decoupled", required = true)
    protected boolean decoupled;
    @XmlAttribute(name = "acquisitionParamsFileRef", required = true)
    @XmlSchemaType(name = "anyURI")
    protected String acquisitionParamsFileRef;
    @XmlAttribute(name = "numberOfDataPoints", required = true)
    protected BigInteger numberOfDataPoints;
    @XmlAttribute(name = "acquisitionNucleus", required = true)
    protected String acquisitionNucleus;

    /**
     * Gets the value of the gammaB1PulseFieldStrength property.
     * 
     * @return
     *     possible object is
     *     {@link ValueWithUnitType }
     *     
     */
    public ValueWithUnitType getGammaB1PulseFieldStrength() {
        return gammaB1PulseFieldStrength;
    }

    /**
     * Sets the value of the gammaB1PulseFieldStrength property.
     * 
     * @param value
     *     allowed object is
     *     {@link ValueWithUnitType }
     *     
     */
    public void setGammaB1PulseFieldStrength(ValueWithUnitType value) {
        this.gammaB1PulseFieldStrength = value;
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

    /**
     * Gets the value of the acquisitionNucleus property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getAcquisitionNucleus() {
        return acquisitionNucleus;
    }

    /**
     * Sets the value of the acquisitionNucleus property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setAcquisitionNucleus(String value) {
        this.acquisitionNucleus = value;
    }

}
