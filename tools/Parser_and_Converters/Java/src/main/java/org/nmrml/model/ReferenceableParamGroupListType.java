
package org.nmrml.model;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;


/**
 * Container for a list of referenceableParamGroups
 * 
 * <p>Java class for ReferenceableParamGroupListType complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="ReferenceableParamGroupListType">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="referenceableParamGroup" type="{http://nmrml.org/schema}ReferenceableParamGroupType" maxOccurs="unbounded"/>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "ReferenceableParamGroupListType", namespace = "http://nmrml.org/schema", propOrder = {
    "referenceableParamGroup"
})
public class ReferenceableParamGroupListType {

    @XmlElement(namespace = "http://nmrml.org/schema", required = true)
    protected List<ReferenceableParamGroupType> referenceableParamGroup;

    /**
     * Gets the value of the referenceableParamGroup property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the referenceableParamGroup property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getReferenceableParamGroup().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link ReferenceableParamGroupType }
     * 
     * 
     */
    public List<ReferenceableParamGroupType> getReferenceableParamGroup() {
        if (referenceableParamGroup == null) {
            referenceableParamGroup = new ArrayList<ReferenceableParamGroupType>();
        }
        return this.referenceableParamGroup;
    }

}
