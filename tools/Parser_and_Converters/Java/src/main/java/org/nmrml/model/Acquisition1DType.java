
package org.nmrml.model;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for Acquisition1DType complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="Acquisition1DType">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="acquisitionParameterSet">
 *           &lt;complexType>
 *             &lt;complexContent>
 *               &lt;extension base="{http://nmrml.org/schema}AcquisitionParameterSet1DType">
 *                 &lt;sequence>
 *                   &lt;element name="DirectDimensionParameterSet" type="{http://nmrml.org/schema}AcquisitionDimensionParameterSetType"/>
 *                 &lt;/sequence>
 *               &lt;/extension>
 *             &lt;/complexContent>
 *           &lt;/complexType>
 *         &lt;/element>
 *         &lt;element name="fid" type="{http://nmrml.org/schema}BinaryDataArrayType"/>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "Acquisition1DType", propOrder = {
    "acquisitionParameterSet",
    "fid"
})
public class Acquisition1DType {

    @XmlElement(required = true)
    protected Acquisition1DType.AcquisitionParameterSet acquisitionParameterSet;
    @XmlElement(required = true)
    protected BinaryDataArrayType fid;

    /**
     * Gets the value of the acquisitionParameterSet property.
     * 
     * @return
     *     possible object is
     *     {@link Acquisition1DType.AcquisitionParameterSet }
     *     
     */
    public Acquisition1DType.AcquisitionParameterSet getAcquisitionParameterSet() {
        return acquisitionParameterSet;
    }

    /**
     * Sets the value of the acquisitionParameterSet property.
     * 
     * @param value
     *     allowed object is
     *     {@link Acquisition1DType.AcquisitionParameterSet }
     *     
     */
    public void setAcquisitionParameterSet(Acquisition1DType.AcquisitionParameterSet value) {
        this.acquisitionParameterSet = value;
    }

    /**
     * Gets the value of the fid property.
     * 
     * @return
     *     possible object is
     *     {@link BinaryDataArrayType }
     *     
     */
    public BinaryDataArrayType getFid() {
        return fid;
    }

    /**
     * Sets the value of the fid property.
     * 
     * @param value
     *     allowed object is
     *     {@link BinaryDataArrayType }
     *     
     */
    public void setFid(BinaryDataArrayType value) {
        this.fid = value;
    }


    /**
     * <p>Java class for anonymous complex type.
     * 
     * <p>The following schema fragment specifies the expected content contained within this class.
     * 
     * <pre>
     * &lt;complexType>
     *   &lt;complexContent>
     *     &lt;extension base="{http://nmrml.org/schema}AcquisitionParameterSet1DType">
     *       &lt;sequence>
     *         &lt;element name="DirectDimensionParameterSet" type="{http://nmrml.org/schema}AcquisitionDimensionParameterSetType"/>
     *       &lt;/sequence>
     *     &lt;/extension>
     *   &lt;/complexContent>
     * &lt;/complexType>
     * </pre>
     * 
     * 
     */
    @XmlAccessorType(XmlAccessType.FIELD)
    @XmlType(name = "", propOrder = {
        "directDimensionParameterSet"
    })
    public static class AcquisitionParameterSet
        extends AcquisitionParameterSet1DType
    {

        @XmlElement(name = "DirectDimensionParameterSet", required = true)
        protected AcquisitionDimensionParameterSetType directDimensionParameterSet;

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

    }

}
