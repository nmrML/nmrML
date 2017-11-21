
package org.nmrml.model;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;


/**
 * Container for one or more controlled vocabulary
 *         definitions.
 * 
 * <p>Java class for CVListType complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="CVListType">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="cv" type="{http://nmrml.org/schema}CVType" maxOccurs="unbounded"/>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "CVListType", namespace = "http://nmrml.org/schema", propOrder = {
    "cv"
})
public class CVListType {

    @XmlElement(namespace = "http://nmrml.org/schema", required = true)
    protected List<CVType> cv;

    /**
     * Gets the value of the cv property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the cv property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getCv().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link CVType }
     * 
     * 
     */
    public List<CVType> getCv() {
        if (cv == null) {
            cv = new ArrayList<CVType>();
        }
        return this.cv;
    }

}
