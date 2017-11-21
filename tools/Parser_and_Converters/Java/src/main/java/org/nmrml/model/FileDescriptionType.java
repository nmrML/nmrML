
package org.nmrml.model;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;


/**
 * Information pertaining to the entire nmrML file (i.e. not specific to any
 *         part of the data set) is stored here. The FileDescriptionType element is intended to contain
 *         a summary description of the current nmrML file, for example it could say that the file has
 *         a 1D FID, a processed spectra, and a peak picked spectra. It does not point to source files
 *         or anything like that. It is intended to make it easy to determine what is inside a file
 *         without having to look for different element types etc and build a summary yourself.
 *         RawSpectrumFile would not be a good name. nmrMLInstanceSummary might be a more intuitive
 *         name.
 * 
 * <p>Java class for FileDescriptionType complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="FileDescriptionType">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="fileContent" type="{http://nmrml.org/schema}ParamGroupType"/>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "FileDescriptionType", namespace = "http://nmrml.org/schema", propOrder = {
    "fileContent"
})
public class FileDescriptionType {

    @XmlElement(namespace = "http://nmrml.org/schema", required = true)
    protected ParamGroupType fileContent;

    /**
     * Gets the value of the fileContent property.
     * 
     * @return
     *     possible object is
     *     {@link ParamGroupType }
     *     
     */
    public ParamGroupType getFileContent() {
        return fileContent;
    }

    /**
     * Sets the value of the fileContent property.
     * 
     * @param value
     *     allowed object is
     *     {@link ParamGroupType }
     *     
     */
    public void setFileContent(ParamGroupType value) {
        this.fileContent = value;
    }

}
