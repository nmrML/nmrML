
package org.nmrml.model;

import java.math.BigInteger;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlIDREF;
import javax.xml.bind.annotation.XmlSchemaType;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for BinaryDataArrayType complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="BinaryDataArrayType">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="binary" type="{http://www.w3.org/2001/XMLSchema}base64Binary"/>
 *       &lt;/sequence>
 *       &lt;attribute name="byteLength" type="{http://www.w3.org/2001/XMLSchema}integer" />
 *       &lt;attribute name="dataProcessingRef" type="{http://www.w3.org/2001/XMLSchema}IDREF" />
 *       &lt;attribute name="totalBytes" use="required" type="{http://www.w3.org/2001/XMLSchema}nonNegativeInteger" />
 *       &lt;attribute name="byteFormat" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "BinaryDataArrayType", propOrder = {
    "binary"
})
public class BinaryDataArrayType {

    @XmlElement(required = true)
    protected byte[] binary;
    @XmlAttribute(name = "byteLength")
    protected BigInteger byteLength;
    @XmlAttribute(name = "dataProcessingRef")
    @XmlIDREF
    @XmlSchemaType(name = "IDREF")
    protected Object dataProcessingRef;
    @XmlAttribute(name = "totalBytes", required = true)
    @XmlSchemaType(name = "nonNegativeInteger")
    protected BigInteger totalBytes;
    @XmlAttribute(name = "byteFormat")
    @XmlSchemaType(name = "anySimpleType")
    protected String byteFormat;

    /**
     * Gets the value of the binary property.
     * 
     * @return
     *     possible object is
     *     byte[]
     */
    public byte[] getBinary() {
        return binary;
    }

    /**
     * Sets the value of the binary property.
     * 
     * @param value
     *     allowed object is
     *     byte[]
     */
    public void setBinary(byte[] value) {
        this.binary = value;
    }

    /**
     * Gets the value of the byteLength property.
     * 
     * @return
     *     possible object is
     *     {@link BigInteger }
     *     
     */
    public BigInteger getByteLength() {
        return byteLength;
    }

    /**
     * Sets the value of the byteLength property.
     * 
     * @param value
     *     allowed object is
     *     {@link BigInteger }
     *     
     */
    public void setByteLength(BigInteger value) {
        this.byteLength = value;
    }

    /**
     * Gets the value of the dataProcessingRef property.
     * 
     * @return
     *     possible object is
     *     {@link Object }
     *     
     */
    public Object getDataProcessingRef() {
        return dataProcessingRef;
    }

    /**
     * Sets the value of the dataProcessingRef property.
     * 
     * @param value
     *     allowed object is
     *     {@link Object }
     *     
     */
    public void setDataProcessingRef(Object value) {
        this.dataProcessingRef = value;
    }

    /**
     * Gets the value of the totalBytes property.
     * 
     * @return
     *     possible object is
     *     {@link BigInteger }
     *     
     */
    public BigInteger getTotalBytes() {
        return totalBytes;
    }

    /**
     * Sets the value of the totalBytes property.
     * 
     * @param value
     *     allowed object is
     *     {@link BigInteger }
     *     
     */
    public void setTotalBytes(BigInteger value) {
        this.totalBytes = value;
    }

    /**
     * Gets the value of the byteFormat property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getByteFormat() {
        return byteFormat;
    }

    /**
     * Sets the value of the byteFormat property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setByteFormat(String value) {
        this.byteFormat = value;
    }

}
