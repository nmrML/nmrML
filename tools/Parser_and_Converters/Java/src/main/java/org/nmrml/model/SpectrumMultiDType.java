
package org.nmrml.model;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for SpectrumMultiDType complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="SpectrumMultiDType">
 *   &lt;complexContent>
 *     &lt;extension base="{http://nmrml.org/schema}SpectrumType">
 *       &lt;sequence>
 *         &lt;element name="firstDimensionProcessingParameterSet" type="{http://nmrml.org/schema}FirstDimensionProcessingParameterSetType"/>
 *         &lt;element name="higherDimensionProcessingParameterSet" type="{http://nmrml.org/schema}HigherDimensionProcessingParameterSetType" maxOccurs="2"/>
 *         &lt;element name="projected3DProcessingParamaterSet" type="{http://nmrml.org/schema}Projected3DProcessingParamaterSetType" minOccurs="0"/>
 *       &lt;/sequence>
 *     &lt;/extension>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "SpectrumMultiDType", namespace = "http://nmrml.org/schema", propOrder = {
    "firstDimensionProcessingParameterSet",
    "higherDimensionProcessingParameterSet",
    "projected3DProcessingParamaterSet"
})
public class SpectrumMultiDType
    extends SpectrumType
{

    @XmlElement(namespace = "http://nmrml.org/schema", required = true)
    protected FirstDimensionProcessingParameterSetType firstDimensionProcessingParameterSet;
    @XmlElement(namespace = "http://nmrml.org/schema", required = true)
    protected List<HigherDimensionProcessingParameterSetType> higherDimensionProcessingParameterSet;
    @XmlElement(namespace = "http://nmrml.org/schema")
    protected Projected3DProcessingParamaterSetType projected3DProcessingParamaterSet;

    /**
     * Gets the value of the firstDimensionProcessingParameterSet property.
     * 
     * @return
     *     possible object is
     *     {@link FirstDimensionProcessingParameterSetType }
     *     
     */
    public FirstDimensionProcessingParameterSetType getFirstDimensionProcessingParameterSet() {
        return firstDimensionProcessingParameterSet;
    }

    /**
     * Sets the value of the firstDimensionProcessingParameterSet property.
     * 
     * @param value
     *     allowed object is
     *     {@link FirstDimensionProcessingParameterSetType }
     *     
     */
    public void setFirstDimensionProcessingParameterSet(FirstDimensionProcessingParameterSetType value) {
        this.firstDimensionProcessingParameterSet = value;
    }

    /**
     * Gets the value of the higherDimensionProcessingParameterSet property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the higherDimensionProcessingParameterSet property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getHigherDimensionProcessingParameterSet().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link HigherDimensionProcessingParameterSetType }
     * 
     * 
     */
    public List<HigherDimensionProcessingParameterSetType> getHigherDimensionProcessingParameterSet() {
        if (higherDimensionProcessingParameterSet == null) {
            higherDimensionProcessingParameterSet = new ArrayList<HigherDimensionProcessingParameterSetType>();
        }
        return this.higherDimensionProcessingParameterSet;
    }

    /**
     * Gets the value of the projected3DProcessingParamaterSet property.
     * 
     * @return
     *     possible object is
     *     {@link Projected3DProcessingParamaterSetType }
     *     
     */
    public Projected3DProcessingParamaterSetType getProjected3DProcessingParamaterSet() {
        return projected3DProcessingParamaterSet;
    }

    /**
     * Sets the value of the projected3DProcessingParamaterSet property.
     * 
     * @param value
     *     allowed object is
     *     {@link Projected3DProcessingParamaterSetType }
     *     
     */
    public void setProjected3DProcessingParamaterSet(Projected3DProcessingParamaterSetType value) {
        this.projected3DProcessingParamaterSet = value;
    }

}
