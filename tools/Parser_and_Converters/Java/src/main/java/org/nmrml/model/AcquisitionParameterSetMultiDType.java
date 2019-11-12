
package org.nmrml.model;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for AcquisitionParameterSetMultiDType complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="AcquisitionParameterSetMultiDType">
 *   &lt;complexContent>
 *     &lt;extension base="{http://nmrml.org/schema}AcquisitionParameterSetType">
 *       &lt;sequence>
 *         &lt;element name="hadamardParameterSet" minOccurs="0">
 *           &lt;complexType>
 *             &lt;complexContent>
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                 &lt;sequence>
 *                   &lt;element name="hadamardFrequency" type="{http://nmrml.org/schema}ValueWithUnitType" maxOccurs="unbounded" minOccurs="0"/>
 *                 &lt;/sequence>
 *               &lt;/restriction>
 *             &lt;/complexContent>
 *           &lt;/complexType>
 *         &lt;/element>
 *         &lt;element name="directDimensionParameterSet" type="{http://nmrml.org/schema}AcquisitionDimensionParameterSetType"/>
 *         &lt;element name="encodingScheme" type="{http://nmrml.org/schema}CVParamType"/>
 *         &lt;element name="indirectDimensionParameterSet" type="{http://nmrml.org/schema}AcquisitionDimensionParameterSetType" maxOccurs="unbounded"/>
 *       &lt;/sequence>
 *     &lt;/extension>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "AcquisitionParameterSetMultiDType", namespace = "http://nmrml.org/schema", propOrder = {
    "hadamardParameterSet",
    "directDimensionParameterSet",
    "encodingScheme",
    "indirectDimensionParameterSet"
})
public class AcquisitionParameterSetMultiDType
    extends AcquisitionParameterSetType
{

    @XmlElement(namespace = "http://nmrml.org/schema")
    protected AcquisitionParameterSetMultiDType.HadamardParameterSet hadamardParameterSet;
    @XmlElement(namespace = "http://nmrml.org/schema", required = true)
    protected AcquisitionDimensionParameterSetType directDimensionParameterSet;
    @XmlElement(namespace = "http://nmrml.org/schema", required = true)
    protected CVParamType encodingScheme;
    @XmlElement(namespace = "http://nmrml.org/schema", required = true)
    protected List<AcquisitionDimensionParameterSetType> indirectDimensionParameterSet;

    /**
     * Gets the value of the hadamardParameterSet property.
     * 
     * @return
     *     possible object is
     *     {@link AcquisitionParameterSetMultiDType.HadamardParameterSet }
     *     
     */
    public AcquisitionParameterSetMultiDType.HadamardParameterSet getHadamardParameterSet() {
        return hadamardParameterSet;
    }

    /**
     * Sets the value of the hadamardParameterSet property.
     * 
     * @param value
     *     allowed object is
     *     {@link AcquisitionParameterSetMultiDType.HadamardParameterSet }
     *     
     */
    public void setHadamardParameterSet(AcquisitionParameterSetMultiDType.HadamardParameterSet value) {
        this.hadamardParameterSet = value;
    }

    /**
     * Gets the value of the directDimensionParameterSet property.
     * 
     * @return
     *     possible object is
     *     {@link AcquisitionDimensionParameterSetType }
     *     
     */
    public AcquisitionDimensionParameterSetType getDirectDimensionParameterSet() {
        return directDimensionParameterSet;
    }

    /**
     * Sets the value of the directDimensionParameterSet property.
     * 
     * @param value
     *     allowed object is
     *     {@link AcquisitionDimensionParameterSetType }
     *     
     */
    public void setDirectDimensionParameterSet(AcquisitionDimensionParameterSetType value) {
        this.directDimensionParameterSet = value;
    }

    /**
     * Gets the value of the encodingScheme property.
     * 
     * @return
     *     possible object is
     *     {@link CVParamType }
     *     
     */
    public CVParamType getEncodingScheme() {
        return encodingScheme;
    }

    /**
     * Sets the value of the encodingScheme property.
     * 
     * @param value
     *     allowed object is
     *     {@link CVParamType }
     *     
     */
    public void setEncodingScheme(CVParamType value) {
        this.encodingScheme = value;
    }

    /**
     * Gets the value of the indirectDimensionParameterSet property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the indirectDimensionParameterSet property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getIndirectDimensionParameterSet().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link AcquisitionDimensionParameterSetType }
     * 
     * 
     */
    public List<AcquisitionDimensionParameterSetType> getIndirectDimensionParameterSet() {
        if (indirectDimensionParameterSet == null) {
            indirectDimensionParameterSet = new ArrayList<AcquisitionDimensionParameterSetType>();
        }
        return this.indirectDimensionParameterSet;
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
     *         &lt;element name="hadamardFrequency" type="{http://nmrml.org/schema}ValueWithUnitType" maxOccurs="unbounded" minOccurs="0"/>
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
        "hadamardFrequency"
    })
    public static class HadamardParameterSet {

        @XmlElement(namespace = "http://nmrml.org/schema")
        protected List<ValueWithUnitType> hadamardFrequency;

        /**
         * Gets the value of the hadamardFrequency property.
         * 
         * <p>
         * This accessor method returns a reference to the live list,
         * not a snapshot. Therefore any modification you make to the
         * returned list will be present inside the JAXB object.
         * This is why there is not a <CODE>set</CODE> method for the hadamardFrequency property.
         * 
         * <p>
         * For example, to add a new item, do as follows:
         * <pre>
         *    getHadamardFrequency().add(newItem);
         * </pre>
         * 
         * 
         * <p>
         * Objects of the following type(s) are allowed in the list
         * {@link ValueWithUnitType }
         * 
         * 
         */
        public List<ValueWithUnitType> getHadamardFrequency() {
            if (hadamardFrequency == null) {
                hadamardFrequency = new ArrayList<ValueWithUnitType>();
            }
            return this.hadamardFrequency;
        }

    }

}
