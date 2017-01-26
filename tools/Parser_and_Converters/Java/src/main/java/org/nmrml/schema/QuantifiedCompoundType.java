//
// This file was generated by the JavaTM Architecture for XML Binding(JAXB) Reference Implementation, v2.2.8-b130911.1802 
// See <a href="http://java.sun.com/xml/jaxb">http://java.sun.com/xml/jaxb</a> 
// Any modifications to this file will be lost upon recompilation of the source schema. 
// Generated on: 2017.01.24 at 10:31:51 PM GMT 
//


package org.nmrml.schema;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for QuantifiedCompoundType complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="QuantifiedCompoundType">
 *   &lt;complexContent>
 *     &lt;extension base="{http://nmrml.org/schema}ChemicalCompoundType">
 *       &lt;sequence>
 *         &lt;element name="concentration" type="{http://nmrml.org/schema}ValueWithUnitType"/>
 *         &lt;element name="clusterList" type="{http://nmrml.org/schema}ClusterListType" minOccurs="0"/>
 *         &lt;element name="peakList" type="{http://nmrml.org/schema}PeakListType" minOccurs="0"/>
 *       &lt;/sequence>
 *     &lt;/extension>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "QuantifiedCompoundType", propOrder = {
    "concentration",
    "clusterList",
    "peakList"
})
public class QuantifiedCompoundType
    extends ChemicalCompoundType
{

    @XmlElement(required = true)
    protected ValueWithUnitType concentration;
    protected ClusterListType clusterList;
    protected PeakListType peakList;

    /**
     * Gets the value of the concentration property.
     * 
     * @return
     *     possible object is
     *     {@link ValueWithUnitType }
     *     
     */
    public ValueWithUnitType getConcentration() {
        return concentration;
    }

    /**
     * Sets the value of the concentration property.
     * 
     * @param value
     *     allowed object is
     *     {@link ValueWithUnitType }
     *     
     */
    public void setConcentration(ValueWithUnitType value) {
        this.concentration = value;
    }

    /**
     * Gets the value of the clusterList property.
     * 
     * @return
     *     possible object is
     *     {@link ClusterListType }
     *     
     */
    public ClusterListType getClusterList() {
        return clusterList;
    }

    /**
     * Sets the value of the clusterList property.
     * 
     * @param value
     *     allowed object is
     *     {@link ClusterListType }
     *     
     */
    public void setClusterList(ClusterListType value) {
        this.clusterList = value;
    }

    /**
     * Gets the value of the peakList property.
     * 
     * @return
     *     possible object is
     *     {@link PeakListType }
     *     
     */
    public PeakListType getPeakList() {
        return peakList;
    }

    /**
     * Sets the value of the peakList property.
     * 
     * @param value
     *     allowed object is
     *     {@link PeakListType }
     *     
     */
    public void setPeakList(PeakListType value) {
        this.peakList = value;
    }

}