
package org.nmrml.model;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;


/**
 * Parameters recorded when raw data set is processed to create a 2D
 *         spectra.
 * 
 * <p>Java class for SpectralProcessingParameterSet2DType complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="SpectralProcessingParameterSet2DType">
 *   &lt;complexContent>
 *     &lt;extension base="{http://nmrml.org/schema}SpectralProcessingParameterSetType">
 *       &lt;sequence>
 *         &lt;element name="directDimensionParameterSet" type="{http://nmrml.org/schema}FirstDimensionProcessingParameterSetType"/>
 *         &lt;element name="higherDimensionParameterSet" type="{http://nmrml.org/schema}HigherDimensionProcessingParameterSetType" maxOccurs="2"/>
 *       &lt;/sequence>
 *     &lt;/extension>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "SpectralProcessingParameterSet2DType", namespace = "http://nmrml.org/schema", propOrder = {
    "directDimensionParameterSet",
    "higherDimensionParameterSet"
})
public class SpectralProcessingParameterSet2DType
    extends SpectralProcessingParameterSetType
{

    @XmlElement(namespace = "http://nmrml.org/schema", required = true)
    protected FirstDimensionProcessingParameterSetType directDimensionParameterSet;
    @XmlElement(namespace = "http://nmrml.org/schema", required = true)
    protected List<HigherDimensionProcessingParameterSetType> higherDimensionParameterSet;

    /**
     * Gets the value of the directDimensionParameterSet property.
     * 
     * @return
     *     possible object is
     *     {@link FirstDimensionProcessingParameterSetType }
     *     
     */
    public FirstDimensionProcessingParameterSetType getDirectDimensionParameterSet() {
        return directDimensionParameterSet;
    }

    /**
     * Sets the value of the directDimensionParameterSet property.
     * 
     * @param value
     *     allowed object is
     *     {@link FirstDimensionProcessingParameterSetType }
     *     
     */
    public void setDirectDimensionParameterSet(FirstDimensionProcessingParameterSetType value) {
        this.directDimensionParameterSet = value;
    }

    /**
     * Gets the value of the higherDimensionParameterSet property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the higherDimensionParameterSet property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getHigherDimensionParameterSet().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link HigherDimensionProcessingParameterSetType }
     * 
     * 
     */
    public List<HigherDimensionProcessingParameterSetType> getHigherDimensionParameterSet() {
        if (higherDimensionParameterSet == null) {
            higherDimensionParameterSet = new ArrayList<HigherDimensionProcessingParameterSetType>();
        }
        return this.higherDimensionParameterSet;
    }

}
