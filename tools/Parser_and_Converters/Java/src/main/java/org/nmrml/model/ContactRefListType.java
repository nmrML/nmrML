
package org.nmrml.model;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for ContactRefListType complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="ContactRefListType">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="contactRef" type="{http://nmrml.org/schema}ContactRefType" maxOccurs="unbounded"/>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "ContactRefListType", namespace = "http://nmrml.org/schema", propOrder = {
    "contactRef"
})
public class ContactRefListType {

    @XmlElement(namespace = "http://nmrml.org/schema", required = true)
    protected List<ContactRefType> contactRef;

    /**
     * Gets the value of the contactRef property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the contactRef property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getContactRef().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link ContactRefType }
     * 
     * 
     */
    public List<ContactRefType> getContactRef() {
        if (contactRef == null) {
            contactRef = new ArrayList<ContactRefType>();
        }
        return this.contactRef;
    }

}
