
package org.nmrml.model;

import java.math.BigInteger;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlSeeAlso;
import javax.xml.bind.annotation.XmlType;


/**
 * Base type for the list with the descriptions of the acquisition settings
 *         applied prior to the start of data acquisition.
 * 
 * <p>Java class for AcquisitionParameterSetType complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="AcquisitionParameterSetType">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="contactRefList" type="{http://nmrml.org/schema}ContactRefListType" minOccurs="0"/>
 *         &lt;element name="acquisitionParameterFileRefList" type="{http://nmrml.org/schema}SourceFileRefListType"/>
 *         &lt;element name="softwareRef" type="{http://nmrml.org/schema}SoftwareRefType" minOccurs="0"/>
 *         &lt;element name="sampleContainer" type="{http://nmrml.org/schema}CVTermType"/>
 *         &lt;element name="sampleAcquisitionTemperature" type="{http://nmrml.org/schema}ValueWithUnitType"/>
 *         &lt;element name="solventSuppressionMethod" type="{http://nmrml.org/schema}CVParamType" minOccurs="0"/>
 *         &lt;element name="spinningRate" type="{http://nmrml.org/schema}ValueWithUnitType"/>
 *         &lt;element name="relaxationDelay" type="{http://nmrml.org/schema}ValueWithUnitType"/>
 *         &lt;element name="pulseSequence" type="{http://nmrml.org/schema}PulseSequenceType"/>
 *         &lt;element name="shapedPulseFile" type="{http://nmrml.org/schema}SourceFileRefType" minOccurs="0"/>
 *       &lt;/sequence>
 *       &lt;attribute name="numberOfSteadyStateScans" use="required" type="{http://www.w3.org/2001/XMLSchema}integer" />
 *       &lt;attribute name="numberOfScans" use="required" type="{http://www.w3.org/2001/XMLSchema}integer" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "AcquisitionParameterSetType", namespace = "http://nmrml.org/schema", propOrder = {
    "contactRefList",
    "acquisitionParameterFileRefList",
    "softwareRef",
    "sampleContainer",
    "sampleAcquisitionTemperature",
    "solventSuppressionMethod",
    "spinningRate",
    "relaxationDelay",
    "pulseSequence",
    "shapedPulseFile"
})
@XmlSeeAlso({
    AcquisitionParameterSet1DType.class,
    AcquisitionParameterSetMultiDType.class
})
public class AcquisitionParameterSetType {

    @XmlElement(namespace = "http://nmrml.org/schema")
    protected ContactRefListType contactRefList;
    @XmlElement(namespace = "http://nmrml.org/schema", required = true)
    protected SourceFileRefListType acquisitionParameterFileRefList;
    @XmlElement(namespace = "http://nmrml.org/schema")
    protected SoftwareRefType softwareRef;
    @XmlElement(namespace = "http://nmrml.org/schema", required = true)
    protected CVTermType sampleContainer;
    @XmlElement(namespace = "http://nmrml.org/schema", required = true)
    protected ValueWithUnitType sampleAcquisitionTemperature;
    @XmlElement(namespace = "http://nmrml.org/schema")
    protected CVParamType solventSuppressionMethod;
    @XmlElement(namespace = "http://nmrml.org/schema", required = true)
    protected ValueWithUnitType spinningRate;
    @XmlElement(namespace = "http://nmrml.org/schema", required = true)
    protected ValueWithUnitType relaxationDelay;
    @XmlElement(namespace = "http://nmrml.org/schema", required = true)
    protected PulseSequenceType pulseSequence;
    @XmlElement(namespace = "http://nmrml.org/schema")
    protected SourceFileRefType shapedPulseFile;
    @XmlAttribute(name = "numberOfSteadyStateScans", required = true)
    protected BigInteger numberOfSteadyStateScans;
    @XmlAttribute(name = "numberOfScans", required = true)
    protected BigInteger numberOfScans;

    /**
     * Gets the value of the contactRefList property.
     * 
     * @return
     *     possible object is
     *     {@link ContactRefListType }
     *     
     */
    public ContactRefListType getContactRefList() {
        return contactRefList;
    }

    /**
     * Sets the value of the contactRefList property.
     * 
     * @param value
     *     allowed object is
     *     {@link ContactRefListType }
     *     
     */
    public void setContactRefList(ContactRefListType value) {
        this.contactRefList = value;
    }

    /**
     * Gets the value of the acquisitionParameterFileRefList property.
     * 
     * @return
     *     possible object is
     *     {@link SourceFileRefListType }
     *     
     */
    public SourceFileRefListType getAcquisitionParameterFileRefList() {
        return acquisitionParameterFileRefList;
    }

    /**
     * Sets the value of the acquisitionParameterFileRefList property.
     * 
     * @param value
     *     allowed object is
     *     {@link SourceFileRefListType }
     *     
     */
    public void setAcquisitionParameterFileRefList(SourceFileRefListType value) {
        this.acquisitionParameterFileRefList = value;
    }

    /**
     * Gets the value of the softwareRef property.
     * 
     * @return
     *     possible object is
     *     {@link SoftwareRefType }
     *     
     */
    public SoftwareRefType getSoftwareRef() {
        return softwareRef;
    }

    /**
     * Sets the value of the softwareRef property.
     * 
     * @param value
     *     allowed object is
     *     {@link SoftwareRefType }
     *     
     */
    public void setSoftwareRef(SoftwareRefType value) {
        this.softwareRef = value;
    }

    /**
     * Gets the value of the sampleContainer property.
     * 
     * @return
     *     possible object is
     *     {@link CVTermType }
     *     
     */
    public CVTermType getSampleContainer() {
        return sampleContainer;
    }

    /**
     * Sets the value of the sampleContainer property.
     * 
     * @param value
     *     allowed object is
     *     {@link CVTermType }
     *     
     */
    public void setSampleContainer(CVTermType value) {
        this.sampleContainer = value;
    }

    /**
     * Gets the value of the sampleAcquisitionTemperature property.
     * 
     * @return
     *     possible object is
     *     {@link ValueWithUnitType }
     *     
     */
    public ValueWithUnitType getSampleAcquisitionTemperature() {
        return sampleAcquisitionTemperature;
    }

    /**
     * Sets the value of the sampleAcquisitionTemperature property.
     * 
     * @param value
     *     allowed object is
     *     {@link ValueWithUnitType }
     *     
     */
    public void setSampleAcquisitionTemperature(ValueWithUnitType value) {
        this.sampleAcquisitionTemperature = value;
    }

    /**
     * Gets the value of the solventSuppressionMethod property.
     * 
     * @return
     *     possible object is
     *     {@link CVParamType }
     *     
     */
    public CVParamType getSolventSuppressionMethod() {
        return solventSuppressionMethod;
    }

    /**
     * Sets the value of the solventSuppressionMethod property.
     * 
     * @param value
     *     allowed object is
     *     {@link CVParamType }
     *     
     */
    public void setSolventSuppressionMethod(CVParamType value) {
        this.solventSuppressionMethod = value;
    }

    /**
     * Gets the value of the spinningRate property.
     * 
     * @return
     *     possible object is
     *     {@link ValueWithUnitType }
     *     
     */
    public ValueWithUnitType getSpinningRate() {
        return spinningRate;
    }

    /**
     * Sets the value of the spinningRate property.
     * 
     * @param value
     *     allowed object is
     *     {@link ValueWithUnitType }
     *     
     */
    public void setSpinningRate(ValueWithUnitType value) {
        this.spinningRate = value;
    }

    /**
     * Gets the value of the relaxationDelay property.
     * 
     * @return
     *     possible object is
     *     {@link ValueWithUnitType }
     *     
     */
    public ValueWithUnitType getRelaxationDelay() {
        return relaxationDelay;
    }

    /**
     * Sets the value of the relaxationDelay property.
     * 
     * @param value
     *     allowed object is
     *     {@link ValueWithUnitType }
     *     
     */
    public void setRelaxationDelay(ValueWithUnitType value) {
        this.relaxationDelay = value;
    }

    /**
     * Gets the value of the pulseSequence property.
     * 
     * @return
     *     possible object is
     *     {@link PulseSequenceType }
     *     
     */
    public PulseSequenceType getPulseSequence() {
        return pulseSequence;
    }

    /**
     * Sets the value of the pulseSequence property.
     * 
     * @param value
     *     allowed object is
     *     {@link PulseSequenceType }
     *     
     */
    public void setPulseSequence(PulseSequenceType value) {
        this.pulseSequence = value;
    }

    /**
     * Gets the value of the shapedPulseFile property.
     * 
     * @return
     *     possible object is
     *     {@link SourceFileRefType }
     *     
     */
    public SourceFileRefType getShapedPulseFile() {
        return shapedPulseFile;
    }

    /**
     * Sets the value of the shapedPulseFile property.
     * 
     * @param value
     *     allowed object is
     *     {@link SourceFileRefType }
     *     
     */
    public void setShapedPulseFile(SourceFileRefType value) {
        this.shapedPulseFile = value;
    }

    /**
     * Gets the value of the numberOfSteadyStateScans property.
     * 
     * @return
     *     possible object is
     *     {@link BigInteger }
     *     
     */
    public BigInteger getNumberOfSteadyStateScans() {
        return numberOfSteadyStateScans;
    }

    /**
     * Sets the value of the numberOfSteadyStateScans property.
     * 
     * @param value
     *     allowed object is
     *     {@link BigInteger }
     *     
     */
    public void setNumberOfSteadyStateScans(BigInteger value) {
        this.numberOfSteadyStateScans = value;
    }

    /**
     * Gets the value of the numberOfScans property.
     * 
     * @return
     *     possible object is
     *     {@link BigInteger }
     *     
     */
    public BigInteger getNumberOfScans() {
        return numberOfScans;
    }

    /**
     * Sets the value of the numberOfScans property.
     * 
     * @param value
     *     allowed object is
     *     {@link BigInteger }
     *     
     */
    public void setNumberOfScans(BigInteger value) {
        this.numberOfScans = value;
    }

}
