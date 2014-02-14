
package org.nmrml.schema;

import java.math.BigInteger;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;


/**
 * Descriptions of the acquisition parameters set prior to the start of data
 *         acquisition specific to each NMR analysis dimension.
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
 *         &lt;element name="decouplingMethod" type="{http://nmrml.org/schema}CVTermType" minOccurs="0"/>
 *         &lt;element name="acquisitionNucleus" type="{http://nmrml.org/schema}CVTermType"/>
 *         &lt;element name="gammaB1PulseFieldStrength" type="{http://nmrml.org/schema}ValueWithUnitType"/>
 *         &lt;element name="sweepWidth" type="{http://nmrml.org/schema}ValueWithUnitType"/>
 *         &lt;element name="irradiationFrequency" type="{http://nmrml.org/schema}ValueWithUnitType"/>
 *         &lt;element name="decouplingNucleus" type="{http://nmrml.org/schema}CVTermType"/>
 *         &lt;element name="samplingStrategy" type="{http://nmrml.org/schema}CVTermType"/>
 *         &lt;element name="samplingTimePoints" type="{http://nmrml.org/schema}BinaryDataArrayType" minOccurs="0"/>
 *       &lt;/sequence>
 *       &lt;attribute name="decoupled" use="required" type="{http://www.w3.org/2001/XMLSchema}boolean" />
 *       &lt;attribute name="numberOfDataPoints" use="required" type="{http://www.w3.org/2001/XMLSchema}integer" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "AcquisitionDimensionParameterSetType", propOrder = {
    "decouplingMethod",
    "acquisitionNucleus",
    "gammaB1PulseFieldStrength",
    "sweepWidth",
    "irradiationFrequency",
    "decouplingNucleus",
    "samplingStrategy",
    "samplingTimePoints"
})
public class AcquisitionDimensionParameterSetType {

    protected CVTermType decouplingMethod;
    @XmlElement(required = true)
    protected CVTermType acquisitionNucleus;
    @XmlElement(required = true)
    protected ValueWithUnitType gammaB1PulseFieldStrength;
    @XmlElement(required = true)
    protected ValueWithUnitType sweepWidth;
    @XmlElement(required = true)
    protected ValueWithUnitType irradiationFrequency;
    @XmlElement(required = true)
    protected CVTermType decouplingNucleus;
    @XmlElement(required = true)
    protected CVTermType samplingStrategy;
    protected BinaryDataArrayType samplingTimePoints;
    @XmlAttribute(name = "decoupled", required = true)
    protected boolean decoupled;
    @XmlAttribute(name = "numberOfDataPoints", required = true)
    protected BigInteger numberOfDataPoints;

    /**
     * Gets the value of the decouplingMethod property.
     * 
     * @return
     *     possible object is
     *     {@link CVTermType }
     *     
     */
    public CVTermType getDecouplingMethod() {
        return decouplingMethod;
    }

    /**
     * Sets the value of the decouplingMethod property.
     * 
     * @param value
     *     allowed object is
     *     {@link CVTermType }
     *     
     */
    public void setDecouplingMethod(CVTermType value) {
        this.decouplingMethod = value;
    }

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
     * Gets the value of the decouplingNucleus property.
     * 
     * @return
     *     possible object is
     *     {@link CVTermType }
     *     
     */
    public CVTermType getDecouplingNucleus() {
        return decouplingNucleus;
    }

    /**
     * Sets the value of the decouplingNucleus property.
     * 
     * @param value
     *     allowed object is
     *     {@link CVTermType }
     *     
     */
    public void setDecouplingNucleus(CVTermType value) {
        this.decouplingNucleus = value;
    }

    /**
     * Gets the value of the samplingStrategy property.
     * 
     * @return
     *     possible object is
     *     {@link CVTermType }
     *     
     */
    public CVTermType getSamplingStrategy() {
        return samplingStrategy;
    }

    /**
     * Sets the value of the samplingStrategy property.
     * 
     * @param value
     *     allowed object is
     *     {@link CVTermType }
     *     
     */
    public void setSamplingStrategy(CVTermType value) {
        this.samplingStrategy = value;
    }

    /**
     * Gets the value of the samplingTimePoints property.
     * 
     * @return
     *     possible object is
     *     {@link BinaryDataArrayType }
     *     
     */
    public BinaryDataArrayType getSamplingTimePoints() {
        return samplingTimePoints;
    }

    /**
     * Sets the value of the samplingTimePoints property.
     * 
     * @param value
     *     allowed object is
     *     {@link BinaryDataArrayType }
     *     
     */
    public void setSamplingTimePoints(BinaryDataArrayType value) {
        this.samplingTimePoints = value;
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
