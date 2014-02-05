
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
 * A spectrum that is the result of processing the acquisition and a
 *         description of the process used to create it.
 * 
 * <p>Java class for SpectrumType complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="SpectrumType">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="processingSoftwareRefList" type="{http://nmrml.org/schema}SoftwareRefListType" maxOccurs="unbounded"/>
 *         &lt;element name="processingContactRefList" type="{http://nmrml.org/schema}ContactRefListType"/>
 *         &lt;element name="spectrumDataArray" type="{http://nmrml.org/schema}BinaryDataArrayType"/>
 *         &lt;element name="xAxis" type="{http://nmrml.org/schema}AxisWithUnitType"/>
 *         &lt;element name="yAxisType" type="{http://nmrml.org/schema}CVTermType"/>
 *         &lt;element name="processingParameterSet">
 *           &lt;complexType>
 *             &lt;complexContent>
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                 &lt;sequence>
 *                   &lt;element name="postAcquisitionSolventSuppressionMethod" type="{http://nmrml.org/schema}CVTermType"/>
 *                   &lt;element name="calibrationCompound" type="{http://nmrml.org/schema}CVTermType"/>
 *                   &lt;element name="dataTransformationMethod" type="{http://nmrml.org/schema}CVTermType"/>
 *                 &lt;/sequence>
 *               &lt;/restriction>
 *             &lt;/complexContent>
 *           &lt;/complexType>
 *         &lt;/element>
 *       &lt;/sequence>
 *       &lt;attribute name="numberOfDataPoints" use="required" type="{http://www.w3.org/2001/XMLSchema}integer" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "SpectrumType", namespace = "http://nmrml.org/schema", propOrder = {
    "processingSoftwareRefList",
    "processingContactRefList",
    "spectrumDataArray",
    "xAxis",
    "yAxisType",
    "processingParameterSet"
})
@XmlSeeAlso({
    SpectrumMultiDType.class,
    Spectrum1DType.class
})
public class SpectrumType {

    @XmlElement(namespace = "http://nmrml.org/schema", required = true)
    protected List<SoftwareRefListType> processingSoftwareRefList;
    @XmlElement(namespace = "http://nmrml.org/schema", required = true)
    protected ContactRefListType processingContactRefList;
    @XmlElement(namespace = "http://nmrml.org/schema", required = true)
    protected BinaryDataArrayType spectrumDataArray;
    @XmlElement(namespace = "http://nmrml.org/schema", required = true)
    protected AxisWithUnitType xAxis;
    @XmlElement(namespace = "http://nmrml.org/schema", required = true)
    protected CVTermType yAxisType;
    @XmlElement(namespace = "http://nmrml.org/schema", required = true)
    protected SpectrumType.ProcessingParameterSet processingParameterSet;
    @XmlAttribute(name = "numberOfDataPoints", required = true)
    protected BigInteger numberOfDataPoints;

    /**
     * Gets the value of the processingSoftwareRefList property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the processingSoftwareRefList property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getProcessingSoftwareRefList().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link SoftwareRefListType }
     * 
     * 
     */
    public List<SoftwareRefListType> getProcessingSoftwareRefList() {
        if (processingSoftwareRefList == null) {
            processingSoftwareRefList = new ArrayList<SoftwareRefListType>();
        }
        return this.processingSoftwareRefList;
    }

    /**
     * Gets the value of the processingContactRefList property.
     * 
     * @return
     *     possible object is
     *     {@link ContactRefListType }
     *     
     */
    public ContactRefListType getProcessingContactRefList() {
        return processingContactRefList;
    }

    /**
     * Sets the value of the processingContactRefList property.
     * 
     * @param value
     *     allowed object is
     *     {@link ContactRefListType }
     *     
     */
    public void setProcessingContactRefList(ContactRefListType value) {
        this.processingContactRefList = value;
    }

    /**
     * Gets the value of the spectrumDataArray property.
     * 
     * @return
     *     possible object is
     *     {@link BinaryDataArrayType }
     *     
     */
    public BinaryDataArrayType getSpectrumDataArray() {
        return spectrumDataArray;
    }

    /**
     * Sets the value of the spectrumDataArray property.
     * 
     * @param value
     *     allowed object is
     *     {@link BinaryDataArrayType }
     *     
     */
    public void setSpectrumDataArray(BinaryDataArrayType value) {
        this.spectrumDataArray = value;
    }

    /**
     * Gets the value of the xAxis property.
     * 
     * @return
     *     possible object is
     *     {@link AxisWithUnitType }
     *     
     */
    public AxisWithUnitType getXAxis() {
        return xAxis;
    }

    /**
     * Sets the value of the xAxis property.
     * 
     * @param value
     *     allowed object is
     *     {@link AxisWithUnitType }
     *     
     */
    public void setXAxis(AxisWithUnitType value) {
        this.xAxis = value;
    }

    /**
     * Gets the value of the yAxisType property.
     * 
     * @return
     *     possible object is
     *     {@link CVTermType }
     *     
     */
    public CVTermType getYAxisType() {
        return yAxisType;
    }

    /**
     * Sets the value of the yAxisType property.
     * 
     * @param value
     *     allowed object is
     *     {@link CVTermType }
     *     
     */
    public void setYAxisType(CVTermType value) {
        this.yAxisType = value;
    }

    /**
     * Gets the value of the processingParameterSet property.
     * 
     * @return
     *     possible object is
     *     {@link SpectrumType.ProcessingParameterSet }
     *     
     */
    public SpectrumType.ProcessingParameterSet getProcessingParameterSet() {
        return processingParameterSet;
    }

    /**
     * Sets the value of the processingParameterSet property.
     * 
     * @param value
     *     allowed object is
     *     {@link SpectrumType.ProcessingParameterSet }
     *     
     */
    public void setProcessingParameterSet(SpectrumType.ProcessingParameterSet value) {
        this.processingParameterSet = value;
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
     * <p>Java class for anonymous complex type.
     * 
     * <p>The following schema fragment specifies the expected content contained within this class.
     * 
     * <pre>
     * &lt;complexType>
     *   &lt;complexContent>
     *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
     *       &lt;sequence>
     *         &lt;element name="postAcquisitionSolventSuppressionMethod" type="{http://nmrml.org/schema}CVTermType"/>
     *         &lt;element name="calibrationCompound" type="{http://nmrml.org/schema}CVTermType"/>
     *         &lt;element name="dataTransformationMethod" type="{http://nmrml.org/schema}CVTermType"/>
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
        "postAcquisitionSolventSuppressionMethod",
        "calibrationCompound",
        "dataTransformationMethod"
    })
    public static class ProcessingParameterSet {

        @XmlElement(namespace = "http://nmrml.org/schema", required = true)
        protected CVTermType postAcquisitionSolventSuppressionMethod;
        @XmlElement(namespace = "http://nmrml.org/schema", required = true)
        protected CVTermType calibrationCompound;
        @XmlElement(namespace = "http://nmrml.org/schema", required = true)
        protected CVTermType dataTransformationMethod;

        /**
         * Gets the value of the postAcquisitionSolventSuppressionMethod property.
         * 
         * @return
         *     possible object is
         *     {@link CVTermType }
         *     
         */
        public CVTermType getPostAcquisitionSolventSuppressionMethod() {
            return postAcquisitionSolventSuppressionMethod;
        }

        /**
         * Sets the value of the postAcquisitionSolventSuppressionMethod property.
         * 
         * @param value
         *     allowed object is
         *     {@link CVTermType }
         *     
         */
        public void setPostAcquisitionSolventSuppressionMethod(CVTermType value) {
            this.postAcquisitionSolventSuppressionMethod = value;
        }

        /**
         * Gets the value of the calibrationCompound property.
         * 
         * @return
         *     possible object is
         *     {@link CVTermType }
         *     
         */
        public CVTermType getCalibrationCompound() {
            return calibrationCompound;
        }

        /**
         * Sets the value of the calibrationCompound property.
         * 
         * @param value
         *     allowed object is
         *     {@link CVTermType }
         *     
         */
        public void setCalibrationCompound(CVTermType value) {
            this.calibrationCompound = value;
        }

        /**
         * Gets the value of the dataTransformationMethod property.
         * 
         * @return
         *     possible object is
         *     {@link CVTermType }
         *     
         */
        public CVTermType getDataTransformationMethod() {
            return dataTransformationMethod;
        }

        /**
         * Sets the value of the dataTransformationMethod property.
         * 
         * @param value
         *     allowed object is
         *     {@link CVTermType }
         *     
         */
        public void setDataTransformationMethod(CVTermType value) {
            this.dataTransformationMethod = value;
        }

    }

}
