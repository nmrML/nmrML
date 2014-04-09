
package org.nmrml.model;

import java.math.BigInteger;
import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlSeeAlso;
import javax.xml.bind.annotation.XmlType;


/**
 * Parameters recorded when raw data set is processed to create a spectra that
 *         are specific to a dimension.
 * 
 * <p>Java class for FirstDimensionProcessingParameterSetType complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="FirstDimensionProcessingParameterSetType">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="zeroOrderPhaseCorrection" type="{http://nmrml.org/schema}ValueWithUnitType" minOccurs="0"/>
 *         &lt;element name="firstOrderPhaseCorrection" type="{http://nmrml.org/schema}ValueWithUnitType" minOccurs="0"/>
 *         &lt;element name="calibrationReferenceShift" type="{http://nmrml.org/schema}ValueWithUnitType"/>
 *         &lt;element name="spectralDenoisingMethod" type="{http://nmrml.org/schema}CVTermType"/>
 *         &lt;element name="windowFunction" maxOccurs="unbounded">
 *           &lt;complexType>
 *             &lt;complexContent>
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                 &lt;sequence>
 *                   &lt;element name="windowFunctionMethod" type="{http://nmrml.org/schema}CVTermType"/>
 *                   &lt;element name="windowFunctionParameter" type="{http://nmrml.org/schema}CVParamType" maxOccurs="unbounded"/>
 *                 &lt;/sequence>
 *               &lt;/restriction>
 *             &lt;/complexContent>
 *           &lt;/complexType>
 *         &lt;/element>
 *         &lt;element name="baselineCorrectionMethod" type="{http://nmrml.org/schema}CVTermType"/>
 *         &lt;element name="parameterFileRef" type="{http://nmrml.org/schema}SourceFileRefType"/>
 *       &lt;/sequence>
 *       &lt;attribute name="noOfDataPoints" use="required" type="{http://www.w3.org/2001/XMLSchema}integer" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "FirstDimensionProcessingParameterSetType", namespace = "http://nmrml.org/schema", propOrder = {
    "zeroOrderPhaseCorrection",
    "firstOrderPhaseCorrection",
    "calibrationReferenceShift",
    "spectralDenoisingMethod",
    "windowFunction",
    "baselineCorrectionMethod",
    "parameterFileRef"
})
@XmlSeeAlso({
    HigherDimensionProcessingParameterSetType.class
})
public class FirstDimensionProcessingParameterSetType {

    @XmlElement(namespace = "http://nmrml.org/schema")
    protected ValueWithUnitType zeroOrderPhaseCorrection;
    @XmlElement(namespace = "http://nmrml.org/schema")
    protected ValueWithUnitType firstOrderPhaseCorrection;
    @XmlElement(namespace = "http://nmrml.org/schema", required = true)
    protected ValueWithUnitType calibrationReferenceShift;
    @XmlElement(namespace = "http://nmrml.org/schema", required = true)
    protected CVTermType spectralDenoisingMethod;
    @XmlElement(namespace = "http://nmrml.org/schema", required = true)
    protected List<FirstDimensionProcessingParameterSetType.WindowFunction> windowFunction;
    @XmlElement(namespace = "http://nmrml.org/schema", required = true)
    protected CVTermType baselineCorrectionMethod;
    @XmlElement(namespace = "http://nmrml.org/schema", required = true)
    protected SourceFileRefType parameterFileRef;
    @XmlAttribute(name = "noOfDataPoints", required = true)
    protected BigInteger noOfDataPoints;

    /**
     * Gets the value of the zeroOrderPhaseCorrection property.
     * 
     * @return
     *     possible object is
     *     {@link ValueWithUnitType }
     *     
     */
    public ValueWithUnitType getZeroOrderPhaseCorrection() {
        return zeroOrderPhaseCorrection;
    }

    /**
     * Sets the value of the zeroOrderPhaseCorrection property.
     * 
     * @param value
     *     allowed object is
     *     {@link ValueWithUnitType }
     *     
     */
    public void setZeroOrderPhaseCorrection(ValueWithUnitType value) {
        this.zeroOrderPhaseCorrection = value;
    }

    /**
     * Gets the value of the firstOrderPhaseCorrection property.
     * 
     * @return
     *     possible object is
     *     {@link ValueWithUnitType }
     *     
     */
    public ValueWithUnitType getFirstOrderPhaseCorrection() {
        return firstOrderPhaseCorrection;
    }

    /**
     * Sets the value of the firstOrderPhaseCorrection property.
     * 
     * @param value
     *     allowed object is
     *     {@link ValueWithUnitType }
     *     
     */
    public void setFirstOrderPhaseCorrection(ValueWithUnitType value) {
        this.firstOrderPhaseCorrection = value;
    }

    /**
     * Gets the value of the calibrationReferenceShift property.
     * 
     * @return
     *     possible object is
     *     {@link ValueWithUnitType }
     *     
     */
    public ValueWithUnitType getCalibrationReferenceShift() {
        return calibrationReferenceShift;
    }

    /**
     * Sets the value of the calibrationReferenceShift property.
     * 
     * @param value
     *     allowed object is
     *     {@link ValueWithUnitType }
     *     
     */
    public void setCalibrationReferenceShift(ValueWithUnitType value) {
        this.calibrationReferenceShift = value;
    }

    /**
     * Gets the value of the spectralDenoisingMethod property.
     * 
     * @return
     *     possible object is
     *     {@link CVTermType }
     *     
     */
    public CVTermType getSpectralDenoisingMethod() {
        return spectralDenoisingMethod;
    }

    /**
     * Sets the value of the spectralDenoisingMethod property.
     * 
     * @param value
     *     allowed object is
     *     {@link CVTermType }
     *     
     */
    public void setSpectralDenoisingMethod(CVTermType value) {
        this.spectralDenoisingMethod = value;
    }

    /**
     * Gets the value of the windowFunction property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the windowFunction property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getWindowFunction().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link FirstDimensionProcessingParameterSetType.WindowFunction }
     * 
     * 
     */
    public List<FirstDimensionProcessingParameterSetType.WindowFunction> getWindowFunction() {
        if (windowFunction == null) {
            windowFunction = new ArrayList<FirstDimensionProcessingParameterSetType.WindowFunction>();
        }
        return this.windowFunction;
    }

    /**
     * Gets the value of the baselineCorrectionMethod property.
     * 
     * @return
     *     possible object is
     *     {@link CVTermType }
     *     
     */
    public CVTermType getBaselineCorrectionMethod() {
        return baselineCorrectionMethod;
    }

    /**
     * Sets the value of the baselineCorrectionMethod property.
     * 
     * @param value
     *     allowed object is
     *     {@link CVTermType }
     *     
     */
    public void setBaselineCorrectionMethod(CVTermType value) {
        this.baselineCorrectionMethod = value;
    }

    /**
     * Gets the value of the parameterFileRef property.
     * 
     * @return
     *     possible object is
     *     {@link SourceFileRefType }
     *     
     */
    public SourceFileRefType getParameterFileRef() {
        return parameterFileRef;
    }

    /**
     * Sets the value of the parameterFileRef property.
     * 
     * @param value
     *     allowed object is
     *     {@link SourceFileRefType }
     *     
     */
    public void setParameterFileRef(SourceFileRefType value) {
        this.parameterFileRef = value;
    }

    /**
     * Gets the value of the noOfDataPoints property.
     * 
     * @return
     *     possible object is
     *     {@link BigInteger }
     *     
     */
    public BigInteger getNoOfDataPoints() {
        return noOfDataPoints;
    }

    /**
     * Sets the value of the noOfDataPoints property.
     * 
     * @param value
     *     allowed object is
     *     {@link BigInteger }
     *     
     */
    public void setNoOfDataPoints(BigInteger value) {
        this.noOfDataPoints = value;
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
     *         &lt;element name="windowFunctionMethod" type="{http://nmrml.org/schema}CVTermType"/>
     *         &lt;element name="windowFunctionParameter" type="{http://nmrml.org/schema}CVParamType" maxOccurs="unbounded"/>
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
        "windowFunctionMethod",
        "windowFunctionParameter"
    })
    public static class WindowFunction {

        @XmlElement(namespace = "http://nmrml.org/schema", required = true)
        protected CVTermType windowFunctionMethod;
        @XmlElement(namespace = "http://nmrml.org/schema", required = true)
        protected List<CVParamType> windowFunctionParameter;

        /**
         * Gets the value of the windowFunctionMethod property.
         * 
         * @return
         *     possible object is
         *     {@link CVTermType }
         *     
         */
        public CVTermType getWindowFunctionMethod() {
            return windowFunctionMethod;
        }

        /**
         * Sets the value of the windowFunctionMethod property.
         * 
         * @param value
         *     allowed object is
         *     {@link CVTermType }
         *     
         */
        public void setWindowFunctionMethod(CVTermType value) {
            this.windowFunctionMethod = value;
        }

        /**
         * Gets the value of the windowFunctionParameter property.
         * 
         * <p>
         * This accessor method returns a reference to the live list,
         * not a snapshot. Therefore any modification you make to the
         * returned list will be present inside the JAXB object.
         * This is why there is not a <CODE>set</CODE> method for the windowFunctionParameter property.
         * 
         * <p>
         * For example, to add a new item, do as follows:
         * <pre>
         *    getWindowFunctionParameter().add(newItem);
         * </pre>
         * 
         * 
         * <p>
         * Objects of the following type(s) are allowed in the list
         * {@link CVParamType }
         * 
         * 
         */
        public List<CVParamType> getWindowFunctionParameter() {
            if (windowFunctionParameter == null) {
                windowFunctionParameter = new ArrayList<CVParamType>();
            }
            return this.windowFunctionParameter;
        }

    }

}
