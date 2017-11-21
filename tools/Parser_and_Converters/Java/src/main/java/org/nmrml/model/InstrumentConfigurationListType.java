
package org.nmrml.model;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;


/**
 * List and descriptions of instrument configurations. At least one instrument
 *         configuration must be specified, even if it is only to specify that the instrument is
 *         unknown. In that case, the "instrument model" term is used to indicate the unknown
 *         instrument in the instrumentConfiguration.
 * 
 * <p>Java class for InstrumentConfigurationListType complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="InstrumentConfigurationListType">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="instrumentConfiguration" type="{http://nmrml.org/schema}InstrumentConfigurationType" maxOccurs="unbounded"/>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "InstrumentConfigurationListType", namespace = "http://nmrml.org/schema", propOrder = {
    "instrumentConfiguration"
})
public class InstrumentConfigurationListType {

    @XmlElement(namespace = "http://nmrml.org/schema", required = true)
    protected List<InstrumentConfigurationType> instrumentConfiguration;

    /**
     * Gets the value of the instrumentConfiguration property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the instrumentConfiguration property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getInstrumentConfiguration().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link InstrumentConfigurationType }
     * 
     * 
     */
    public List<InstrumentConfigurationType> getInstrumentConfiguration() {
        if (instrumentConfiguration == null) {
            instrumentConfiguration = new ArrayList<InstrumentConfigurationType>();
        }
        return this.instrumentConfiguration;
    }

}
