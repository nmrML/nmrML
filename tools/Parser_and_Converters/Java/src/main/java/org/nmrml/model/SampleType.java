
package org.nmrml.model;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlSchemaType;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for SampleType complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="SampleType">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="originalBiologicalSamplepH" type="{http://nmrml.org/schema}PhType" minOccurs="0"/>
 *         &lt;element name="postBufferpH" type="{http://nmrml.org/schema}PhType" minOccurs="0"/>
 *         &lt;element name="buffer" type="{http://nmrml.org/schema}CVTermType"/>
 *         &lt;element name="fieldFrequencyLock">
 *           &lt;complexType>
 *             &lt;complexContent>
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                 &lt;attribute name="fieldFrequencyLockName" use="required" type="{http://www.w3.org/2001/XMLSchema}string" />
 *               &lt;/restriction>
 *             &lt;/complexContent>
 *           &lt;/complexType>
 *         &lt;/element>
 *         &lt;element name="chemicalShiftStandard" type="{http://nmrml.org/schema}CVParamType"/>
 *         &lt;element name="solventType" type="{http://nmrml.org/schema}CVTermType"/>
 *         &lt;element name="additionalSoluteList" type="{http://nmrml.org/schema}AdditionalSoluteListType"/>
 *         &lt;element name="solventConcentration" type="{http://nmrml.org/schema}ValueWithUnitType"/>
 *         &lt;element name="concentrationStandard" minOccurs="0">
 *           &lt;complexType>
 *             &lt;complexContent>
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                 &lt;sequence>
 *                   &lt;element name="type" type="{http://nmrml.org/schema}CVTermType"/>
 *                   &lt;element name="concentrationInSample" type="{http://nmrml.org/schema}ValueWithUnitType"/>
 *                   &lt;element name="name" type="{http://nmrml.org/schema}CVTermType"/>
 *                 &lt;/sequence>
 *               &lt;/restriction>
 *             &lt;/complexContent>
 *           &lt;/complexType>
 *         &lt;/element>
 *       &lt;/sequence>
 *       &lt;attribute name="originalBiologicalSampleReference" use="required" type="{http://www.w3.org/2001/XMLSchema}anyURI" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "SampleType", namespace = "http://nmrml.org/schema", propOrder = {
    "originalBiologicalSamplepH",
    "postBufferpH",
    "buffer",
    "fieldFrequencyLock",
    "chemicalShiftStandard",
    "solventType",
    "additionalSoluteList",
    "solventConcentration",
    "concentrationStandard"
})
public class SampleType {

    @XmlElement(namespace = "http://nmrml.org/schema")
    protected Double originalBiologicalSamplepH;
    @XmlElement(namespace = "http://nmrml.org/schema")
    protected Double postBufferpH;
    @XmlElement(namespace = "http://nmrml.org/schema", required = true)
    protected CVTermType buffer;
    @XmlElement(namespace = "http://nmrml.org/schema", required = true)
    protected SampleType.FieldFrequencyLock fieldFrequencyLock;
    @XmlElement(namespace = "http://nmrml.org/schema", required = true)
    protected CVParamType chemicalShiftStandard;
    @XmlElement(namespace = "http://nmrml.org/schema", required = true)
    protected CVTermType solventType;
    @XmlElement(namespace = "http://nmrml.org/schema", required = true)
    protected AdditionalSoluteListType additionalSoluteList;
    @XmlElement(namespace = "http://nmrml.org/schema", required = true)
    protected ValueWithUnitType solventConcentration;
    @XmlElement(namespace = "http://nmrml.org/schema")
    protected SampleType.ConcentrationStandard concentrationStandard;
    @XmlAttribute(name = "originalBiologicalSampleReference", required = true)
    @XmlSchemaType(name = "anyURI")
    protected String originalBiologicalSampleReference;

    /**
     * Gets the value of the originalBiologicalSamplepH property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public Double getOriginalBiologicalSamplepH() {
        return originalBiologicalSamplepH;
    }

    /**
     * Sets the value of the originalBiologicalSamplepH property.
     * 
     * @param value
     *     allowed object is
     *     {@link Double }
     *     
     */
    public void setOriginalBiologicalSamplepH(Double value) {
        this.originalBiologicalSamplepH = value;
    }

    /**
     * Gets the value of the postBufferpH property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public Double getPostBufferpH() {
        return postBufferpH;
    }

    /**
     * Sets the value of the postBufferpH property.
     * 
     * @param value
     *     allowed object is
     *     {@link Double }
     *     
     */
    public void setPostBufferpH(Double value) {
        this.postBufferpH = value;
    }

    /**
     * Gets the value of the buffer property.
     * 
     * @return
     *     possible object is
     *     {@link CVTermType }
     *     
     */
    public CVTermType getBuffer() {
        return buffer;
    }

    /**
     * Sets the value of the buffer property.
     * 
     * @param value
     *     allowed object is
     *     {@link CVTermType }
     *     
     */
    public void setBuffer(CVTermType value) {
        this.buffer = value;
    }

    /**
     * Gets the value of the fieldFrequencyLock property.
     * 
     * @return
     *     possible object is
     *     {@link SampleType.FieldFrequencyLock }
     *     
     */
    public SampleType.FieldFrequencyLock getFieldFrequencyLock() {
        return fieldFrequencyLock;
    }

    /**
     * Sets the value of the fieldFrequencyLock property.
     * 
     * @param value
     *     allowed object is
     *     {@link SampleType.FieldFrequencyLock }
     *     
     */
    public void setFieldFrequencyLock(SampleType.FieldFrequencyLock value) {
        this.fieldFrequencyLock = value;
    }

    /**
     * Gets the value of the chemicalShiftStandard property.
     * 
     * @return
     *     possible object is
     *     {@link CVParamType }
     *     
     */
    public CVParamType getChemicalShiftStandard() {
        return chemicalShiftStandard;
    }

    /**
     * Sets the value of the chemicalShiftStandard property.
     * 
     * @param value
     *     allowed object is
     *     {@link CVParamType }
     *     
     */
    public void setChemicalShiftStandard(CVParamType value) {
        this.chemicalShiftStandard = value;
    }

    /**
     * Gets the value of the solventType property.
     * 
     * @return
     *     possible object is
     *     {@link CVTermType }
     *     
     */
    public CVTermType getSolventType() {
        return solventType;
    }

    /**
     * Sets the value of the solventType property.
     * 
     * @param value
     *     allowed object is
     *     {@link CVTermType }
     *     
     */
    public void setSolventType(CVTermType value) {
        this.solventType = value;
    }

    /**
     * Gets the value of the additionalSoluteList property.
     * 
     * @return
     *     possible object is
     *     {@link AdditionalSoluteListType }
     *     
     */
    public AdditionalSoluteListType getAdditionalSoluteList() {
        return additionalSoluteList;
    }

    /**
     * Sets the value of the additionalSoluteList property.
     * 
     * @param value
     *     allowed object is
     *     {@link AdditionalSoluteListType }
     *     
     */
    public void setAdditionalSoluteList(AdditionalSoluteListType value) {
        this.additionalSoluteList = value;
    }

    /**
     * Gets the value of the solventConcentration property.
     * 
     * @return
     *     possible object is
     *     {@link ValueWithUnitType }
     *     
     */
    public ValueWithUnitType getSolventConcentration() {
        return solventConcentration;
    }

    /**
     * Sets the value of the solventConcentration property.
     * 
     * @param value
     *     allowed object is
     *     {@link ValueWithUnitType }
     *     
     */
    public void setSolventConcentration(ValueWithUnitType value) {
        this.solventConcentration = value;
    }

    /**
     * Gets the value of the concentrationStandard property.
     * 
     * @return
     *     possible object is
     *     {@link SampleType.ConcentrationStandard }
     *     
     */
    public SampleType.ConcentrationStandard getConcentrationStandard() {
        return concentrationStandard;
    }

    /**
     * Sets the value of the concentrationStandard property.
     * 
     * @param value
     *     allowed object is
     *     {@link SampleType.ConcentrationStandard }
     *     
     */
    public void setConcentrationStandard(SampleType.ConcentrationStandard value) {
        this.concentrationStandard = value;
    }

    /**
     * Gets the value of the originalBiologicalSampleReference property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getOriginalBiologicalSampleReference() {
        return originalBiologicalSampleReference;
    }

    /**
     * Sets the value of the originalBiologicalSampleReference property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setOriginalBiologicalSampleReference(String value) {
        this.originalBiologicalSampleReference = value;
    }


    /**
     * <p>Java class for anonymous complex type.
     * 
     * <p>The following schema fragment specifies the expected content contained within this class.
     * 
     * <pre>
     * &lt;complexType>
     *   &lt;complexContent>
     *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
     *       &lt;sequence>
     *         &lt;element name="type" type="{http://nmrml.org/schema}CVTermType"/>
     *         &lt;element name="concentrationInSample" type="{http://nmrml.org/schema}ValueWithUnitType"/>
     *         &lt;element name="name" type="{http://nmrml.org/schema}CVTermType"/>
     *       &lt;/sequence>
     *     &lt;/restriction>
     *   &lt;/complexContent>
     * &lt;/complexType>
     * </pre>
     * 
     * 
     */
    @XmlAccessorType(XmlAccessType.FIELD)
    @XmlType(name = "", propOrder = {
        "type",
        "concentrationInSample",
        "name"
    })
    public static class ConcentrationStandard {

        @XmlElement(namespace = "http://nmrml.org/schema", required = true)
        protected CVTermType type;
        @XmlElement(namespace = "http://nmrml.org/schema", required = true)
        protected ValueWithUnitType concentrationInSample;
        @XmlElement(namespace = "http://nmrml.org/schema", required = true)
        protected CVTermType name;

        /**
         * Gets the value of the type property.
         * 
         * @return
         *     possible object is
         *     {@link CVTermType }
         *     
         */
        public CVTermType getType() {
            return type;
        }

        /**
         * Sets the value of the type property.
         * 
         * @param value
         *     allowed object is
         *     {@link CVTermType }
         *     
         */
        public void setType(CVTermType value) {
            this.type = value;
        }

        /**
         * Gets the value of the concentrationInSample property.
         * 
         * @return
         *     possible object is
         *     {@link ValueWithUnitType }
         *     
         */
        public ValueWithUnitType getConcentrationInSample() {
            return concentrationInSample;
        }

        /**
         * Sets the value of the concentrationInSample property.
         * 
         * @param value
         *     allowed object is
         *     {@link ValueWithUnitType }
         *     
         */
        public void setConcentrationInSample(ValueWithUnitType value) {
            this.concentrationInSample = value;
        }

        /**
         * Gets the value of the name property.
         * 
         * @return
         *     possible object is
         *     {@link CVTermType }
         *     
         */
        public CVTermType getName() {
            return name;
        }

        /**
         * Sets the value of the name property.
         * 
         * @param value
         *     allowed object is
         *     {@link CVTermType }
         *     
         */
        public void setName(CVTermType value) {
            this.name = value;
        }

    }


    /**
     * <p>Java class for anonymous complex type.
     * 
     * <p>The following schema fragment specifies the expected content contained within this class.
     * 
     * <pre>
     * &lt;complexType>
     *   &lt;complexContent>
     *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
     *       &lt;attribute name="fieldFrequencyLockName" use="required" type="{http://www.w3.org/2001/XMLSchema}string" />
     *     &lt;/restriction>
     *   &lt;/complexContent>
     * &lt;/complexType>
     * </pre>
     * 
     * 
     */
    @XmlAccessorType(XmlAccessType.FIELD)
    @XmlType(name = "")
    public static class FieldFrequencyLock {

        @XmlAttribute(name = "fieldFrequencyLockName", required = true)
        protected String fieldFrequencyLockName;

        /**
         * Gets the value of the fieldFrequencyLockName property.
         * 
         * @return
         *     possible object is
         *     {@link String }
         *     
         */
        public String getFieldFrequencyLockName() {
            return fieldFrequencyLockName;
        }

        /**
         * Sets the value of the fieldFrequencyLockName property.
         * 
         * @param value
         *     allowed object is
         *     {@link String }
         *     
         */
        public void setFieldFrequencyLockName(String value) {
            this.fieldFrequencyLockName = value;
        }

    }

}
