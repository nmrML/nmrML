
package org.nmrml.model;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlIDREF;
import javax.xml.bind.annotation.XmlSchemaType;
import javax.xml.bind.annotation.XmlType;


/**
 * Uncontrolled user parameters (essentially allowing free text). Before using
 *         these, one should verify whether there is an appropriate CV term available, and if so, use
 *         the CV term instead
 * 
 * <p>Java class for UserParamType complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="UserParamType">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;attribute name="name" use="required" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="valueType" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="value" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="unitAccession" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="unitName" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="unitCvRef" type="{http://www.w3.org/2001/XMLSchema}IDREF" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "UserParamType", namespace = "http://nmrml.org/schema")
public class UserParamType {

    @XmlAttribute(name = "name", required = true)
    protected String name;
    @XmlAttribute(name = "valueType")
    protected String valueType;
    @XmlAttribute(name = "value")
    protected String value;
    @XmlAttribute(name = "unitAccession")
    protected String unitAccession;
    @XmlAttribute(name = "unitName")
    protected String unitName;
    @XmlAttribute(name = "unitCvRef")
    @XmlIDREF
    @XmlSchemaType(name = "IDREF")
    protected Object unitCvRef;

    /**
     * Gets the value of the name property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getName() {
        return name;
    }

    /**
     * Sets the value of the name property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setName(String value) {
        this.name = value;
    }

    /**
     * Gets the value of the valueType property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getValueType() {
        return valueType;
    }

    /**
     * Sets the value of the valueType property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setValueType(String value) {
        this.valueType = value;
    }

    /**
     * Gets the value of the value property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getValue() {
        return value;
    }

    /**
     * Sets the value of the value property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setValue(String value) {
        this.value = value;
    }

    /**
     * Gets the value of the unitAccession property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getUnitAccession() {
        return unitAccession;
    }

    /**
     * Sets the value of the unitAccession property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setUnitAccession(String value) {
        this.unitAccession = value;
    }

    /**
     * Gets the value of the unitName property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getUnitName() {
        return unitName;
    }

    /**
     * Sets the value of the unitName property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setUnitName(String value) {
        this.unitName = value;
    }

    /**
     * Gets the value of the unitCvRef property.
     * 
     * @return
     *     possible object is
     *     {@link Object }
     *     
     */
    public Object getUnitCvRef() {
        return unitCvRef;
    }

    /**
     * Sets the value of the unitCvRef property.
     * 
     * @param value
     *     allowed object is
     *     {@link Object }
     *     
     */
    public void setUnitCvRef(Object value) {
        this.unitCvRef = value;
    }

}
