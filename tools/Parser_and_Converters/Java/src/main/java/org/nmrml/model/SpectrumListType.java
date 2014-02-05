
package org.nmrml.model;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlIDREF;
import javax.xml.bind.annotation.XmlSchemaType;
import javax.xml.bind.annotation.XmlType;


/**
 * List and descriptions of spectra.
 * 
 * <p>Java class for SpectrumListType complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="SpectrumListType">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;choice>
 *         &lt;element name="spectrum1D" type="{http://nmrml.org/schema}Spectrum1DType" maxOccurs="unbounded" minOccurs="0"/>
 *         &lt;element name="spectrumMultiD" type="{http://nmrml.org/schema}SpectrumMultiDType" maxOccurs="unbounded" minOccurs="0"/>
 *       &lt;/choice>
 *       &lt;attribute name="defaultDataProcessingRef" use="required" type="{http://www.w3.org/2001/XMLSchema}IDREF" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "SpectrumListType", namespace = "http://nmrml.org/schema", propOrder = {
    "spectrum1D",
    "spectrumMultiD"
})
public class SpectrumListType {

    @XmlElement(namespace = "http://nmrml.org/schema")
    protected List<Spectrum1DType> spectrum1D;
    @XmlElement(namespace = "http://nmrml.org/schema")
    protected List<SpectrumMultiDType> spectrumMultiD;
    @XmlAttribute(name = "defaultDataProcessingRef", required = true)
    @XmlIDREF
    @XmlSchemaType(name = "IDREF")
    protected Object defaultDataProcessingRef;

    /**
     * Gets the value of the spectrum1D property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the spectrum1D property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getSpectrum1D().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link Spectrum1DType }
     * 
     * 
     */
    public List<Spectrum1DType> getSpectrum1D() {
        if (spectrum1D == null) {
            spectrum1D = new ArrayList<Spectrum1DType>();
        }
        return this.spectrum1D;
    }

    /**
     * Gets the value of the spectrumMultiD property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the spectrumMultiD property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getSpectrumMultiD().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link SpectrumMultiDType }
     * 
     * 
     */
    public List<SpectrumMultiDType> getSpectrumMultiD() {
        if (spectrumMultiD == null) {
            spectrumMultiD = new ArrayList<SpectrumMultiDType>();
        }
        return this.spectrumMultiD;
    }

    /**
     * Gets the value of the defaultDataProcessingRef property.
     * 
     * @return
     *     possible object is
     *     {@link Object }
     *     
     */
    public Object getDefaultDataProcessingRef() {
        return defaultDataProcessingRef;
    }

    /**
     * Sets the value of the defaultDataProcessingRef property.
     * 
     * @param value
     *     allowed object is
     *     {@link Object }
     *     
     */
    public void setDefaultDataProcessingRef(Object value) {
        this.defaultDataProcessingRef = value;
    }

}
