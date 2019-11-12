
package org.nmrml.model;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlID;
import javax.xml.bind.annotation.XmlSchemaType;
import javax.xml.bind.annotation.XmlType;
import javax.xml.bind.annotation.adapters.CollapsedStringAdapter;
import javax.xml.bind.annotation.adapters.XmlJavaTypeAdapter;


/**
 * A temperature and references to a unit from the unit
 *         ontology.
 * 
 * <p>Java class for TemperatureType complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="TemperatureType">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;attribute name="temperature" use="required" type="{http://www.w3.org/2001/XMLSchema}float" />
 *       &lt;attribute name="temperatureUnitName" use="required" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="temperatureUnitID" type="{http://www.w3.org/2001/XMLSchema}ID" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "TemperatureType", namespace = "http://nmrml.org/schema")
public class TemperatureType {

    @XmlAttribute(name = "temperature", required = true)
    protected float temperature;
    @XmlAttribute(name = "temperatureUnitName", required = true)
    protected String temperatureUnitName;
    @XmlAttribute(name = "temperatureUnitID")
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    @XmlID
    @XmlSchemaType(name = "ID")
    protected String temperatureUnitID;

    /**
     * Gets the value of the temperature property.
     * 
     */
    public float getTemperature() {
        return temperature;
    }

    /**
     * Sets the value of the temperature property.
     * 
     */
    public void setTemperature(float value) {
        this.temperature = value;
    }

    /**
     * Gets the value of the temperatureUnitName property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getTemperatureUnitName() {
        return temperatureUnitName;
    }

    /**
     * Sets the value of the temperatureUnitName property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setTemperatureUnitName(String value) {
        this.temperatureUnitName = value;
    }

    /**
     * Gets the value of the temperatureUnitID property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getTemperatureUnitID() {
        return temperatureUnitID;
    }

    /**
     * Sets the value of the temperatureUnitID property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setTemperatureUnitID(String value) {
        this.temperatureUnitID = value;
    }

}
