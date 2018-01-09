
package org.nmrml.model;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;


/**
 * List and descriptions of the source files this nmrML document was generated
 *         or derived from
 * 
 * <p>Java class for SourceFileListType complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="SourceFileListType">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="sourceFile" type="{http://nmrml.org/schema}SourceFileType" maxOccurs="unbounded"/>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "SourceFileListType", namespace = "http://nmrml.org/schema", propOrder = {
    "sourceFile"
})
public class SourceFileListType {

    @XmlElement(namespace = "http://nmrml.org/schema", required = true)
    protected List<SourceFileType> sourceFile;

    /**
     * Gets the value of the sourceFile property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the sourceFile property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getSourceFile().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link SourceFileType }
     * 
     * 
     */
    public List<SourceFileType> getSourceFile() {
        if (sourceFile == null) {
            sourceFile = new ArrayList<SourceFileType>();
        }
        return this.sourceFile;
    }

}
