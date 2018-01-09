
package org.nmrml.model;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;


/**
 * A list of references to the source files that define the pulse sequence,
 *         including pulse shape files, pulse sequence source code, pulse sequence parameter files,
 *         etc.
 * 
 * <p>Java class for PulseSequenceType complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="PulseSequenceType">
 *   &lt;complexContent>
 *     &lt;extension base="{http://nmrml.org/schema}ParamGroupType">
 *       &lt;sequence minOccurs="0">
 *         &lt;element name="pulseSequenceFileRefList">
 *           &lt;complexType>
 *             &lt;complexContent>
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                 &lt;sequence>
 *                   &lt;element name="sourceFileRef" type="{http://nmrml.org/schema}SourceFileRefType" maxOccurs="unbounded" minOccurs="0"/>
 *                 &lt;/sequence>
 *               &lt;/restriction>
 *             &lt;/complexContent>
 *           &lt;/complexType>
 *         &lt;/element>
 *       &lt;/sequence>
 *     &lt;/extension>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "PulseSequenceType", namespace = "http://nmrml.org/schema", propOrder = {
    "pulseSequenceFileRefList"
})
public class PulseSequenceType
    extends ParamGroupType
{

    @XmlElement(namespace = "http://nmrml.org/schema")
    protected PulseSequenceType.PulseSequenceFileRefList pulseSequenceFileRefList;

    /**
     * Gets the value of the pulseSequenceFileRefList property.
     * 
     * @return
     *     possible object is
     *     {@link PulseSequenceType.PulseSequenceFileRefList }
     *     
     */
    public PulseSequenceType.PulseSequenceFileRefList getPulseSequenceFileRefList() {
        return pulseSequenceFileRefList;
    }

    /**
     * Sets the value of the pulseSequenceFileRefList property.
     * 
     * @param value
     *     allowed object is
     *     {@link PulseSequenceType.PulseSequenceFileRefList }
     *     
     */
    public void setPulseSequenceFileRefList(PulseSequenceType.PulseSequenceFileRefList value) {
        this.pulseSequenceFileRefList = value;
    }


    /**
     * <p>Java class for anonymous complex type.
     * 
     * <p>The following schema fragment specifies the expected content contained within this class.
     * 
     * <pre>
     * &lt;complexType>
     *   &lt;complexContent>
     *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
     *       &lt;sequence>
     *         &lt;element name="sourceFileRef" type="{http://nmrml.org/schema}SourceFileRefType" maxOccurs="unbounded" minOccurs="0"/>
     *       &lt;/sequence>
     *     &lt;/restriction>
     *   &lt;/complexContent>
     * &lt;/complexType>
     * </pre>
     * 
     * 
     */
    @XmlAccessorType(XmlAccessType.FIELD)
    @XmlType(name = "", propOrder = {
        "sourceFileRef"
    })
    public static class PulseSequenceFileRefList {

        @XmlElement(namespace = "http://nmrml.org/schema")
        protected List<SourceFileRefType> sourceFileRef;

        /**
         * Gets the value of the sourceFileRef property.
         * 
         * <p>
         * This accessor method returns a reference to the live list,
         * not a snapshot. Therefore any modification you make to the
         * returned list will be present inside the JAXB object.
         * This is why there is not a <CODE>set</CODE> method for the sourceFileRef property.
         * 
         * <p>
         * For example, to add a new item, do as follows:
         * <pre>
         *    getSourceFileRef().add(newItem);
         * </pre>
         * 
         * 
         * <p>
         * Objects of the following type(s) are allowed in the list
         * {@link SourceFileRefType }
         * 
         * 
         */
        public List<SourceFileRefType> getSourceFileRef() {
            if (sourceFileRef == null) {
                sourceFileRef = new ArrayList<SourceFileRefType>();
            }
            return this.sourceFileRef;
        }

    }

}
