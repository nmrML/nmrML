
package org.nmrml.model;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for AdditionalSoluteListType complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="AdditionalSoluteListType">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="solute" type="{http://nmrml.org/schema}SoluteType" maxOccurs="unbounded" minOccurs="0"/>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "AdditionalSoluteListType", namespace = "http://nmrml.org/schema", propOrder = {
    "solute"
})
public class AdditionalSoluteListType {

    @XmlElement(namespace = "http://nmrml.org/schema")
    protected List<SoluteType> solute;

    /**
     * Gets the value of the solute property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the solute property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getSolute().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link SoluteType }
     * 
     * 
     */
    public List<SoluteType> getSolute() {
        if (solute == null) {
            solute = new ArrayList<SoluteType>();
        }
        return this.solute;
    }

}
