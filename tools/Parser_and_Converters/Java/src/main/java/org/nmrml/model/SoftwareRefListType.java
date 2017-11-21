
package org.nmrml.model;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for SoftwareRefListType complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="SoftwareRefListType">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="softwareRef" type="{http://nmrml.org/schema}SoftwareRefType" maxOccurs="unbounded" minOccurs="0"/>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "SoftwareRefListType", namespace = "http://nmrml.org/schema", propOrder = {
    "softwareRef"
})
public class SoftwareRefListType {

    @XmlElement(namespace = "http://nmrml.org/schema")
    protected List<SoftwareRefType> softwareRef;

    /**
     * Gets the value of the softwareRef property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the softwareRef property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getSoftwareRef().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link SoftwareRefType }
     * 
     * 
     */
    public List<SoftwareRefType> getSoftwareRef() {
        if (softwareRef == null) {
            softwareRef = new ArrayList<SoftwareRefType>();
        }
        return this.softwareRef;
    }

}
