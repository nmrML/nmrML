
package org.nmrml.model;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlID;
import javax.xml.bind.annotation.XmlSchemaType;
import javax.xml.bind.annotation.XmlType;
import javax.xml.bind.annotation.adapters.CollapsedStringAdapter;
import javax.xml.bind.annotation.adapters.XmlJavaTypeAdapter;


/**
 * Description of a particular hardware configuration of a NMR spectrometer.
 *         For software configuration, use a ReferenceableParamGroup element.
 * 
 * <p>Java class for InstrumentConfigurationType complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="InstrumentConfigurationType">
 *   &lt;complexContent>
 *     &lt;extension base="{http://nmrml.org/schema}ParamGroupType">
 *       &lt;sequence>
 *         &lt;element name="softwareRef" type="{http://nmrml.org/schema}SoftwareRefType" maxOccurs="unbounded" minOccurs="0"/>
 *       &lt;/sequence>
 *       &lt;attribute name="id" use="required" type="{http://www.w3.org/2001/XMLSchema}ID" />
 *     &lt;/extension>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "InstrumentConfigurationType", namespace = "http://nmrml.org/schema", propOrder = {
    "softwareRef"
})
public class InstrumentConfigurationType
    extends ParamGroupType
{

    @XmlElement(namespace = "http://nmrml.org/schema")
    protected List<SoftwareRefType> softwareRef;
    @XmlAttribute(name = "id", required = true)
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    @XmlID
    @XmlSchemaType(name = "ID")
    protected String id;

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

    /**
     * Gets the value of the id property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getId() {
        return id;
    }

    /**
     * Sets the value of the id property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setId(String value) {
        this.id = value;
    }

}
