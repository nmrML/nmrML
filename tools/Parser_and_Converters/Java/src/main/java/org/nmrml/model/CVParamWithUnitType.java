
package org.nmrml.model;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlIDREF;
import javax.xml.bind.annotation.XmlSchemaType;
import javax.xml.bind.annotation.XmlType;


/**
 * This element holds additional data or annotation. Only controlled values are
 *         allowed here.
 * 
 * <p>Java class for CVParamWithUnitType complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="CVParamWithUnitType">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;attribute name="cvRef" use="required" type="{http://www.w3.org/2001/XMLSchema}IDREF" />
 *       &lt;attribute name="accession" use="required" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="name" use="required" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="value" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="unitCvRef" type="{http://www.w3.org/2001/XMLSchema}IDREF" />
 *       &lt;attribute name="unitAccession" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="unitName" type="{http://www.w3.org/2001/XMLSchema}string" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "CVParamWithUnitType", namespace = "http://nmrml.org/schema")
public class CVParamWithUnitType {

    @XmlAttribute(name = "cvRef", required = true)
    @XmlIDREF
    @XmlSchemaType(name = "IDREF")
    protected Object cvRef;
    @XmlAttribute(name = "accession", required = true)
    protected String accession;
    @XmlAttribute(name = "name", required = true)
    protected String name;
    @XmlAttribute(name = "value")
    protected String value;
    @XmlAttribute(name = "unitCvRef")
    @XmlIDREF
    @XmlSchemaType(name = "IDREF")
    protected Object unitCvRef;
    @XmlAttribute(name = "unitAccession")
    protected String unitAccession;
    @XmlAttribute(name = "unitName")
    protected String unitName;

    /**
     * Gets the value of the cvRef property.
     * 
     * @return
     *     possible object is
     *     {@link Object }
     *     
     */
    public Object getCvRef() {
        return cvRef;
    }

    /**
     * Sets the value of the cvRef property.
     * 
     * @param value
     *     allowed object is
     *     {@link Object }
     *     
     */
    public void setCvRef(Object value) {
        this.cvRef = value;
    }

    /**
     * Gets the value of the accession property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getAccession() {
        return accession;
    }

    /**
     * Sets the value of the accession property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setAccession(String value) {
        this.accession = value;
    }

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

}
