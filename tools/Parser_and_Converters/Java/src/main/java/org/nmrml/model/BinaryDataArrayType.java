
package org.nmrml.model;

import java.math.BigInteger;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlIDREF;
import javax.xml.bind.annotation.XmlSchemaType;
import javax.xml.bind.annotation.XmlType;
import javax.xml.bind.annotation.XmlValue;


/**
 * <p>Java class for BinaryDataArrayType complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="BinaryDataArrayType">
 *   &lt;simpleContent>
 *     &lt;extension base="&lt;http://www.w3.org/2001/XMLSchema>base64Binary">
 *       &lt;attribute name="compressed" use="required" type="{http://www.w3.org/2001/XMLSchema}boolean" />
 *       &lt;attribute name="dataProcessingRef" type="{http://www.w3.org/2001/XMLSchema}IDREF" />
 *       &lt;attribute name="encodedLength" use="required" type="{http://www.w3.org/2001/XMLSchema}nonNegativeInteger" />
 *       &lt;attribute name="byteFormat" use="required" type="{http://www.w3.org/2001/XMLSchema}string" />
 *     &lt;/extension>
 *   &lt;/simpleContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "BinaryDataArrayType", namespace = "http://nmrml.org/schema", propOrder = {
    "value"
})
public class BinaryDataArrayType {

    @XmlValue
    protected byte[] value;
    @XmlAttribute(name = "compressed", required = true)
    protected boolean compressed;
    @XmlAttribute(name = "dataProcessingRef")
    @XmlIDREF
    @XmlSchemaType(name = "IDREF")
    protected Object dataProcessingRef;
    @XmlAttribute(name = "encodedLength", required = true)
    @XmlSchemaType(name = "nonNegativeInteger")
    protected BigInteger encodedLength;
    @XmlAttribute(name = "byteFormat", required = true)
    protected String byteFormat;

    /**
     * Gets the value of the value property.
     * 
     * @return
     *     possible object is
     *     byte[]
     */
    public byte[] getValue() {
        return value;
    }

    /**
     * Sets the value of the value property.
     * 
     * @param value
     *     allowed object is
     *     byte[]
     */
    public void setValue(byte[] value) {
        this.value = value;
    }

    /**
     * Gets the value of the compressed property.
     * 
     */
    public boolean isCompressed() {
        return compressed;
    }

    /**
     * Sets the value of the compressed property.
     * 
     */
    public void setCompressed(boolean value) {
        this.compressed = value;
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
     * Gets the value of the encodedLength property.
     * 
     * @return
     *     possible object is
     *     {@link BigInteger }
     *     
     */
    public BigInteger getEncodedLength() {
        return encodedLength;
    }

    /**
     * Sets the value of the encodedLength property.
     * 
     * @param value
     *     allowed object is
     *     {@link BigInteger }
     *     
     */
    public void setEncodedLength(BigInteger value) {
        this.encodedLength = value;
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
