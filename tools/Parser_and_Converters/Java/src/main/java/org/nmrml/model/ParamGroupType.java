
package org.nmrml.model;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlSeeAlso;
import javax.xml.bind.annotation.XmlType;


/**
 * Structure allowing the use of a controlled (cvParam) or uncontrolled
 *         vocabulary (userParam), or a reference to a predefined set of these in this nmrML file
 *         (paramGroupRef).
 * 
 * <p>Java class for ParamGroupType complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="ParamGroupType">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence minOccurs="0">
 *         &lt;element name="referenceableParamGroupRef" type="{http://nmrml.org/schema}ReferenceableParamGroupRefType" maxOccurs="unbounded" minOccurs="0"/>
 *         &lt;element name="cvParam" type="{http://nmrml.org/schema}CVParamType" maxOccurs="unbounded" minOccurs="0"/>
 *         &lt;element name="cvParamWithUnit" type="{http://nmrml.org/schema}CVParamWithUnitType" maxOccurs="unbounded" minOccurs="0"/>
 *         &lt;element name="cvTerm" type="{http://nmrml.org/schema}CVTermType" maxOccurs="unbounded" minOccurs="0"/>
 *         &lt;element name="userParam" type="{http://nmrml.org/schema}UserParamType" maxOccurs="unbounded" minOccurs="0"/>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "ParamGroupType", namespace = "http://nmrml.org/schema", propOrder = {
    "referenceableParamGroupRef",
    "cvParam",
    "cvParamWithUnit",
    "cvTerm",
    "userParam"
})
@XmlSeeAlso({
    ProcessingMethodType.class,
    ContactType.class,
    SourceFileType.class,
    PulseSequenceType.class,
    InstrumentConfigurationType.class
})
public class ParamGroupType {

    @XmlElement(namespace = "http://nmrml.org/schema")
    protected List<ReferenceableParamGroupRefType> referenceableParamGroupRef;
    @XmlElement(namespace = "http://nmrml.org/schema")
    protected List<CVParamType> cvParam;
    @XmlElement(namespace = "http://nmrml.org/schema")
    protected List<CVParamWithUnitType> cvParamWithUnit;
    @XmlElement(namespace = "http://nmrml.org/schema")
    protected List<CVTermType> cvTerm;
    @XmlElement(namespace = "http://nmrml.org/schema")
    protected List<UserParamType> userParam;

    /**
     * Gets the value of the referenceableParamGroupRef property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the referenceableParamGroupRef property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getReferenceableParamGroupRef().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link ReferenceableParamGroupRefType }
     * 
     * 
     */
    public List<ReferenceableParamGroupRefType> getReferenceableParamGroupRef() {
        if (referenceableParamGroupRef == null) {
            referenceableParamGroupRef = new ArrayList<ReferenceableParamGroupRefType>();
        }
        return this.referenceableParamGroupRef;
    }

    /**
     * Gets the value of the cvParam property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the cvParam property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getCvParam().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link CVParamType }
     * 
     * 
     */
    public List<CVParamType> getCvParam() {
        if (cvParam == null) {
            cvParam = new ArrayList<CVParamType>();
        }
        return this.cvParam;
    }

    /**
     * Gets the value of the cvParamWithUnit property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the cvParamWithUnit property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getCvParamWithUnit().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link CVParamWithUnitType }
     * 
     * 
     */
    public List<CVParamWithUnitType> getCvParamWithUnit() {
        if (cvParamWithUnit == null) {
            cvParamWithUnit = new ArrayList<CVParamWithUnitType>();
        }
        return this.cvParamWithUnit;
    }

    /**
     * Gets the value of the cvTerm property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the cvTerm property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getCvTerm().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link CVTermType }
     * 
     * 
     */
    public List<CVTermType> getCvTerm() {
        if (cvTerm == null) {
            cvTerm = new ArrayList<CVTermType>();
        }
        return this.cvTerm;
    }

    /**
     * Gets the value of the userParam property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the userParam property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getUserParam().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link UserParamType }
     * 
     * 
     */
    public List<UserParamType> getUserParam() {
        if (userParam == null) {
            userParam = new ArrayList<UserParamType>();
        }
        return this.userParam;
    }

}
