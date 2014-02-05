
package org.nmrml.model;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlSeeAlso;
import javax.xml.bind.annotation.XmlType;


/**
 * Parameters recorded when raw data set is processed to create a
 *         spectra.
 * 
 * <p>Java class for SpectralProcessingParameterSetType complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="SpectralProcessingParameterSetType">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="processingSoftwareRefList" type="{http://nmrml.org/schema}SoftwareRefListType" maxOccurs="unbounded"/>
 *         &lt;element name="postAcquisitionSolventSuppressionMethod" type="{http://nmrml.org/schema}CVTermType"/>
 *         &lt;element name="dataTransformationMethod" type="{http://nmrml.org/schema}CVTermType"/>
 *         &lt;element name="calibrationCompound" type="{http://nmrml.org/schema}CVTermType"/>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "SpectralProcessingParameterSetType", namespace = "http://nmrml.org/schema", propOrder = {
    "processingSoftwareRefList",
    "postAcquisitionSolventSuppressionMethod",
    "dataTransformationMethod",
    "calibrationCompound"
})
@XmlSeeAlso({
    SpectralProcessingParameterSet2DType.class
})
public class SpectralProcessingParameterSetType {

    @XmlElement(namespace = "http://nmrml.org/schema", required = true)
    protected List<SoftwareRefListType> processingSoftwareRefList;
    @XmlElement(namespace = "http://nmrml.org/schema", required = true)
    protected CVTermType postAcquisitionSolventSuppressionMethod;
    @XmlElement(namespace = "http://nmrml.org/schema", required = true)
    protected CVTermType dataTransformationMethod;
    @XmlElement(namespace = "http://nmrml.org/schema", required = true)
    protected CVTermType calibrationCompound;

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

}
