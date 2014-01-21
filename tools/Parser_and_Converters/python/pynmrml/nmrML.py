#!/usr/bin/env python

#
# Generated Wed Oct 30 15:59:51 2013 by generateDS.py version 2.11a.
#

import sys

import nmrML_lib as supermod

etree_ = None
Verbose_import_ = False
(
    XMLParser_import_none, XMLParser_import_lxml,
    XMLParser_import_elementtree
) = range(3)
XMLParser_import_library = None
try:
    # lxml
    from lxml import etree as etree_
    XMLParser_import_library = XMLParser_import_lxml
    if Verbose_import_:
        print("running with lxml.etree")
except ImportError:
    try:
        # cElementTree from Python 2.5+
        import xml.etree.cElementTree as etree_
        XMLParser_import_library = XMLParser_import_elementtree
        if Verbose_import_:
            print("running with cElementTree on Python 2.5+")
    except ImportError:
        try:
            # ElementTree from Python 2.5+
            import xml.etree.ElementTree as etree_
            XMLParser_import_library = XMLParser_import_elementtree
            if Verbose_import_:
                print("running with ElementTree on Python 2.5+")
        except ImportError:
            try:
                # normal cElementTree install
                import cElementTree as etree_
                XMLParser_import_library = XMLParser_import_elementtree
                if Verbose_import_:
                    print("running with cElementTree")
            except ImportError:
                try:
                    # normal ElementTree install
                    import elementtree.ElementTree as etree_
                    XMLParser_import_library = XMLParser_import_elementtree
                    if Verbose_import_:
                        print("running with ElementTree")
                except ImportError:
                    raise ImportError(
                        "Failed to import ElementTree from any known place")


def parsexml_(*args, **kwargs):
    if (XMLParser_import_library == XMLParser_import_lxml and
            'parser' not in kwargs):
        # Use the lxml ElementTree compatible parser so that, e.g.,
        #   we ignore comments.
        kwargs['parser'] = etree_.ETCompatXMLParser()
    doc = etree_.parse(*args, **kwargs)
    return doc

#
# Globals
#

ExternalEncoding = 'utf-8'

#
# Data representation classes
#


class nmrMLType(supermod.nmrMLType):
    def __init__(self, version=None, accession_url=None, accession=None, id=None, cvList=None, fileDescription=None, contactList=None, referenceableParamGroupList=None, sourceFileList=None, softwareList=None, instrumentConfigurationList=None, dataProcessingList=None, sampleList=None, acquisition=None, spectrumList=None):
        super(nmrMLType, self).__init__(version, accession_url, accession, id, cvList, fileDescription, contactList, referenceableParamGroupList, sourceFileList, softwareList, instrumentConfigurationList, dataProcessingList, sampleList, acquisition, spectrumList, )
supermod.nmrMLType.subclass = nmrMLType
# end class nmrMLType


class CVListType(supermod.CVListType):
    def __init__(self, count=None, cv=None):
        super(CVListType, self).__init__(count, cv, )
supermod.CVListType.subclass = CVListType
# end class CVListType


class CVType(supermod.CVType):
    def __init__(self, fullName=None, version=None, id=None, URI=None):
        super(CVType, self).__init__(fullName, version, id, URI, )
supermod.CVType.subclass = CVType
# end class CVType


class ContactListType(supermod.ContactListType):
    def __init__(self, contact=None):
        super(ContactListType, self).__init__(contact, )
supermod.ContactListType.subclass = ContactListType
# end class ContactListType


class ContactRefType(supermod.ContactRefType):
    def __init__(self, ref=None):
        super(ContactRefType, self).__init__(ref, )
supermod.ContactRefType.subclass = ContactRefType
# end class ContactRefType


class ContactRefListType(supermod.ContactRefListType):
    def __init__(self, count=None, contactRef=None):
        super(ContactRefListType, self).__init__(count, contactRef, )
supermod.ContactRefListType.subclass = ContactRefListType
# end class ContactRefListType


class FileDescriptionType(supermod.FileDescriptionType):
    def __init__(self, fileContent=None):
        super(FileDescriptionType, self).__init__(fileContent, )
supermod.FileDescriptionType.subclass = FileDescriptionType
# end class FileDescriptionType


class CVTermType(supermod.CVTermType):
    def __init__(self, cvRef=None, accession=None, name=None, extensiontype_=None):
        super(CVTermType, self).__init__(cvRef, accession, name, extensiontype_, )
supermod.CVTermType.subclass = CVTermType
# end class CVTermType


class CVParamType(supermod.CVParamType):
    def __init__(self, cvRef=None, accession=None, value=None, name=None):
        super(CVParamType, self).__init__(cvRef, accession, value, name, )
supermod.CVParamType.subclass = CVParamType
# end class CVParamType


class CVParamWithUnitType(supermod.CVParamWithUnitType):
    def __init__(self, name=None, unitName=None, accession=None, value=None, unitAccession=None, cvRef=None, unitCvRef=None):
        super(CVParamWithUnitType, self).__init__(name, unitName, accession, value, unitAccession, cvRef, unitCvRef, )
supermod.CVParamWithUnitType.subclass = CVParamWithUnitType
# end class CVParamWithUnitType


class ValueWithUnitType(supermod.ValueWithUnitType):
    def __init__(self, unitName=None, unitCvRef=None, value=None, unitAccession=None):
        super(ValueWithUnitType, self).__init__(unitName, unitCvRef, value, unitAccession, )
supermod.ValueWithUnitType.subclass = ValueWithUnitType
# end class ValueWithUnitType


class UserParamType(supermod.UserParamType):
    def __init__(self, name=None, unitName=None, valueType=None, value=None, unitAccession=None, unitCvRef=None):
        super(UserParamType, self).__init__(name, unitName, valueType, value, unitAccession, unitCvRef, )
supermod.UserParamType.subclass = UserParamType
# end class UserParamType


class ParamGroupType(supermod.ParamGroupType):
    def __init__(self, referenceableParamGroupRef=None, cvParam=None, cvParamWithUnit=None, cvTerm=None, userParam=None, extensiontype_=None):
        super(ParamGroupType, self).__init__(referenceableParamGroupRef, cvParam, cvParamWithUnit, cvTerm, userParam, extensiontype_, )
supermod.ParamGroupType.subclass = ParamGroupType
# end class ParamGroupType


class ReferenceableParamGroupType(supermod.ReferenceableParamGroupType):
    def __init__(self, id=None, cvParam=None, userParam=None):
        super(ReferenceableParamGroupType, self).__init__(id, cvParam, userParam, )
supermod.ReferenceableParamGroupType.subclass = ReferenceableParamGroupType
# end class ReferenceableParamGroupType


class ReferenceableParamGroupRefType(supermod.ReferenceableParamGroupRefType):
    def __init__(self, ref=None):
        super(ReferenceableParamGroupRefType, self).__init__(ref, )
supermod.ReferenceableParamGroupRefType.subclass = ReferenceableParamGroupRefType
# end class ReferenceableParamGroupRefType


class ReferenceableParamGroupListType(supermod.ReferenceableParamGroupListType):
    def __init__(self, count=None, referenceableParamGroup=None):
        super(ReferenceableParamGroupListType, self).__init__(count, referenceableParamGroup, )
supermod.ReferenceableParamGroupListType.subclass = ReferenceableParamGroupListType
# end class ReferenceableParamGroupListType


class SourceFileListType(supermod.SourceFileListType):
    def __init__(self, count=None, sourceFile=None):
        super(SourceFileListType, self).__init__(count, sourceFile, )
supermod.SourceFileListType.subclass = SourceFileListType
# end class SourceFileListType


class SampleListType(supermod.SampleListType):
    def __init__(self, count=None, sample=None):
        super(SampleListType, self).__init__(count, sample, )
supermod.SampleListType.subclass = SampleListType
# end class SampleListType


class SampleType(supermod.SampleType):
    def __init__(self, originalBiologicalSampleReference=None, originalBiologicalSamplepH=None, postBufferpH=None, buffer=None, fieldFrequencyLock=None, chemicalShiftStandard=None, solventType=None, additionalSoluteList=None, solventConcentration=None, concentrationStandard=None):
        super(SampleType, self).__init__(originalBiologicalSampleReference, originalBiologicalSamplepH, postBufferpH, buffer, fieldFrequencyLock, chemicalShiftStandard, solventType, additionalSoluteList, solventConcentration, concentrationStandard, )
supermod.SampleType.subclass = SampleType
# end class SampleType


class SoftwareListType(supermod.SoftwareListType):
    def __init__(self, count=None, software=None):
        super(SoftwareListType, self).__init__(count, software, )
supermod.SoftwareListType.subclass = SoftwareListType
# end class SoftwareListType


class SoftwareType(supermod.SoftwareType):
    def __init__(self, cvRef=None, accession=None, name=None, version=None, id=None):
        super(SoftwareType, self).__init__(cvRef, accession, name, version, id, )
supermod.SoftwareType.subclass = SoftwareType
# end class SoftwareType


class SoftwareRefType(supermod.SoftwareRefType):
    def __init__(self, ref=None):
        super(SoftwareRefType, self).__init__(ref, )
supermod.SoftwareRefType.subclass = SoftwareRefType
# end class SoftwareRefType


class SoftwareRefListType(supermod.SoftwareRefListType):
    def __init__(self, count=None, softwareRef=None):
        super(SoftwareRefListType, self).__init__(count, softwareRef, )
supermod.SoftwareRefListType.subclass = SoftwareRefListType
# end class SoftwareRefListType


class SourceFileType(supermod.SourceFileType):
    def __init__(self, referenceableParamGroupRef=None, cvParam=None, cvParamWithUnit=None, cvTerm=None, userParam=None, sha1=None, location=None, id=None, name=None):
        super(SourceFileType, self).__init__(referenceableParamGroupRef, cvParam, cvParamWithUnit, cvTerm, userParam, sha1, location, id, name, )
supermod.SourceFileType.subclass = SourceFileType
# end class SourceFileType


class SourceFileRefType(supermod.SourceFileRefType):
    def __init__(self, ref=None):
        super(SourceFileRefType, self).__init__(ref, )
supermod.SourceFileRefType.subclass = SourceFileRefType
# end class SourceFileRefType


class SourceFileRefListType(supermod.SourceFileRefListType):
    def __init__(self, count=None, sourceFileRef=None):
        super(SourceFileRefListType, self).__init__(count, sourceFileRef, )
supermod.SourceFileRefListType.subclass = SourceFileRefListType
# end class SourceFileRefListType


class InstrumentConfigurationType(supermod.InstrumentConfigurationType):
    def __init__(self, referenceableParamGroupRef=None, cvParam=None, cvParamWithUnit=None, cvTerm=None, userParam=None, id=None, softwareRef=None):
        super(InstrumentConfigurationType, self).__init__(referenceableParamGroupRef, cvParam, cvParamWithUnit, cvTerm, userParam, id, softwareRef, )
supermod.InstrumentConfigurationType.subclass = InstrumentConfigurationType
# end class InstrumentConfigurationType


class InstrumentConfigurationListType(supermod.InstrumentConfigurationListType):
    def __init__(self, count=None, instrumentConfiguration=None):
        super(InstrumentConfigurationListType, self).__init__(count, instrumentConfiguration, )
supermod.InstrumentConfigurationListType.subclass = InstrumentConfigurationListType
# end class InstrumentConfigurationListType


class DataProcessingType(supermod.DataProcessingType):
    def __init__(self, id=None, processingMethod=None):
        super(DataProcessingType, self).__init__(id, processingMethod, )
supermod.DataProcessingType.subclass = DataProcessingType
# end class DataProcessingType


class DataProcessingListType(supermod.DataProcessingListType):
    def __init__(self, count=None, dataProcessing=None):
        super(DataProcessingListType, self).__init__(count, dataProcessing, )
supermod.DataProcessingListType.subclass = DataProcessingListType
# end class DataProcessingListType


class ProcessingMethodType(supermod.ProcessingMethodType):
    def __init__(self, referenceableParamGroupRef=None, cvParam=None, cvParamWithUnit=None, cvTerm=None, userParam=None, order=None, softwareRef=None):
        super(ProcessingMethodType, self).__init__(referenceableParamGroupRef, cvParam, cvParamWithUnit, cvTerm, userParam, order, softwareRef, )
supermod.ProcessingMethodType.subclass = ProcessingMethodType
# end class ProcessingMethodType


class BinaryDataArrayType(supermod.BinaryDataArrayType):
    def __init__(self, byteFormat=None, encodedLength=None, compressed=None, dataProcessingRef=None, valueOf_=None):
        super(BinaryDataArrayType, self).__init__(byteFormat, encodedLength, compressed, dataProcessingRef, valueOf_, )
supermod.BinaryDataArrayType.subclass = BinaryDataArrayType
# end class BinaryDataArrayType


class SoluteType(supermod.SoluteType):
    def __init__(self, name=None, concentrationInSample=None):
        super(SoluteType, self).__init__(name, concentrationInSample, )
supermod.SoluteType.subclass = SoluteType
# end class SoluteType


class TemperatureType(supermod.TemperatureType):
    def __init__(self, temperatureUnitID=None, temperature=None, temperatureUnitName=None):
        super(TemperatureType, self).__init__(temperatureUnitID, temperature, temperatureUnitName, )
supermod.TemperatureType.subclass = TemperatureType
# end class TemperatureType


class AdditionalSoluteListType(supermod.AdditionalSoluteListType):
    def __init__(self, solute=None):
        super(AdditionalSoluteListType, self).__init__(solute, )
supermod.AdditionalSoluteListType.subclass = AdditionalSoluteListType
# end class AdditionalSoluteListType


class AcquisitionDimensionParameterSetType(supermod.AcquisitionDimensionParameterSetType):
    def __init__(self, numberOfDataPoints=None, decoupled=None, acquisitionNucleus=None, gammaB1PulseFieldStrength=None, sweepWidth=None, irradiationFrequency=None, decouplingMethod=None, samplingStrategy=None, samplingTimePoints=None):
        super(AcquisitionDimensionParameterSetType, self).__init__(numberOfDataPoints, decoupled, acquisitionNucleus, gammaB1PulseFieldStrength, sweepWidth, irradiationFrequency, decouplingMethod, samplingStrategy, samplingTimePoints, )
supermod.AcquisitionDimensionParameterSetType.subclass = AcquisitionDimensionParameterSetType
# end class AcquisitionDimensionParameterSetType


class AcquisitionIndirectDimensionParameterSetType(supermod.AcquisitionIndirectDimensionParameterSetType):
    def __init__(self, numberOfDataPoints=None, acquisitionParamsFileRef=None, decoupled=None, acquisitionNucleus=None, gammaB1PulseFieldStrength=None, sweepWidth=None, timeDomain=None, encodingMethod=None, irradiationFrequency=None):
        super(AcquisitionIndirectDimensionParameterSetType, self).__init__(numberOfDataPoints, acquisitionParamsFileRef, decoupled, acquisitionNucleus, gammaB1PulseFieldStrength, sweepWidth, timeDomain, encodingMethod, irradiationFrequency, )
supermod.AcquisitionIndirectDimensionParameterSetType.subclass = AcquisitionIndirectDimensionParameterSetType
# end class AcquisitionIndirectDimensionParameterSetType


class AcquisitionParameterSetType(supermod.AcquisitionParameterSetType):
    def __init__(self, numberOfScans=None, numberOfSteadyStateScans=None, contactRefList=None, acquisitionParameterFileRefList=None, softwareRef=None, sampleContainer=None, sampleAcquisitionTemperature=None, solventSuppressionMethod=None, spinningRate=None, relaxationDelay=None, pulseSequence=None, shapedPulseFile=None, extensiontype_=None):
        super(AcquisitionParameterSetType, self).__init__(numberOfScans, numberOfSteadyStateScans, contactRefList, acquisitionParameterFileRefList, softwareRef, sampleContainer, sampleAcquisitionTemperature, solventSuppressionMethod, spinningRate, relaxationDelay, pulseSequence, shapedPulseFile, extensiontype_, )
supermod.AcquisitionParameterSetType.subclass = AcquisitionParameterSetType
# end class AcquisitionParameterSetType


class AcquisitionParameterSet1DType(supermod.AcquisitionParameterSet1DType):
    def __init__(self, numberOfScans=None, numberOfSteadyStateScans=None, contactRefList=None, acquisitionParameterFileRefList=None, softwareRef=None, sampleContainer=None, sampleAcquisitionTemperature=None, solventSuppressionMethod=None, spinningRate=None, relaxationDelay=None, pulseSequence=None, shapedPulseFile=None, DirectDimensionParameterSet=None):
        super(AcquisitionParameterSet1DType, self).__init__(numberOfScans, numberOfSteadyStateScans, contactRefList, acquisitionParameterFileRefList, softwareRef, sampleContainer, sampleAcquisitionTemperature, solventSuppressionMethod, spinningRate, relaxationDelay, pulseSequence, shapedPulseFile, DirectDimensionParameterSet, )
supermod.AcquisitionParameterSet1DType.subclass = AcquisitionParameterSet1DType
# end class AcquisitionParameterSet1DType


class AcquisitionParameterSetMultiDType(supermod.AcquisitionParameterSetMultiDType):
    def __init__(self, numberOfScans=None, numberOfSteadyStateScans=None, contactRefList=None, acquisitionParameterFileRefList=None, softwareRef=None, sampleContainer=None, sampleAcquisitionTemperature=None, solventSuppressionMethod=None, spinningRate=None, relaxationDelay=None, pulseSequence=None, shapedPulseFile=None, hadamardParameterSet=None, directDimensionParameterSet=None, encodingScheme=None, indirectDimensionParameterSet=None):
        super(AcquisitionParameterSetMultiDType, self).__init__(numberOfScans, numberOfSteadyStateScans, contactRefList, acquisitionParameterFileRefList, softwareRef, sampleContainer, sampleAcquisitionTemperature, solventSuppressionMethod, spinningRate, relaxationDelay, pulseSequence, shapedPulseFile, hadamardParameterSet, directDimensionParameterSet, encodingScheme, indirectDimensionParameterSet, )
supermod.AcquisitionParameterSetMultiDType.subclass = AcquisitionParameterSetMultiDType
# end class AcquisitionParameterSetMultiDType


class PulseSequenceType(supermod.PulseSequenceType):
    def __init__(self, referenceableParamGroupRef=None, cvParam=None, cvParamWithUnit=None, cvTerm=None, userParam=None, pulseSequenceFileRefList=None):
        super(PulseSequenceType, self).__init__(referenceableParamGroupRef, cvParam, cvParamWithUnit, cvTerm, userParam, pulseSequenceFileRefList, )
supermod.PulseSequenceType.subclass = PulseSequenceType
# end class PulseSequenceType


class AcquisitionType(supermod.AcquisitionType):
    def __init__(self, acquisition1D=None, acquisitionMultiD=None):
        super(AcquisitionType, self).__init__(acquisition1D, acquisitionMultiD, )
supermod.AcquisitionType.subclass = AcquisitionType
# end class AcquisitionType


class Acquisition1DType(supermod.Acquisition1DType):
    def __init__(self, acquisitionParameterSet=None, fidData=None):
        super(Acquisition1DType, self).__init__(acquisitionParameterSet, fidData, )
supermod.Acquisition1DType.subclass = Acquisition1DType
# end class Acquisition1DType


class AcquisitionMultiDType(supermod.AcquisitionMultiDType):
    def __init__(self, acquisitionParameterSet=None, fidData=None):
        super(AcquisitionMultiDType, self).__init__(acquisitionParameterSet, fidData, )
supermod.AcquisitionMultiDType.subclass = AcquisitionMultiDType
# end class AcquisitionMultiDType


class SpectrumListType(supermod.SpectrumListType):
    def __init__(self, count=None, defaultDataProcessingRef=None, spectrum1D=None, spectrumMultiD=None):
        super(SpectrumListType, self).__init__(count, defaultDataProcessingRef, spectrum1D, spectrumMultiD, )
supermod.SpectrumListType.subclass = SpectrumListType
# end class SpectrumListType


class SpectrumType(supermod.SpectrumType):
    def __init__(self, numberOfDataPoints=None, processingSoftwareRefList=None, processingContactRefList=None, spectrumDataArray=None, xAxis=None, yAxisType=None, processingParameterSet=None, extensiontype_=None):
        super(SpectrumType, self).__init__(numberOfDataPoints, processingSoftwareRefList, processingContactRefList, spectrumDataArray, xAxis, yAxisType, processingParameterSet, extensiontype_, )
supermod.SpectrumType.subclass = SpectrumType
# end class SpectrumType


class Spectrum1DType(supermod.Spectrum1DType):
    def __init__(self, numberOfDataPoints=None, processingSoftwareRefList=None, processingContactRefList=None, spectrumDataArray=None, xAxis=None, yAxisType=None, processingParameterSet=None, firstDimensionProcessingParameterSet=None):
        super(Spectrum1DType, self).__init__(numberOfDataPoints, processingSoftwareRefList, processingContactRefList, spectrumDataArray, xAxis, yAxisType, processingParameterSet, firstDimensionProcessingParameterSet, )
supermod.Spectrum1DType.subclass = Spectrum1DType
# end class Spectrum1DType


class SpectrumMultiDType(supermod.SpectrumMultiDType):
    def __init__(self, numberOfDataPoints=None, processingSoftwareRefList=None, processingContactRefList=None, spectrumDataArray=None, xAxis=None, yAxisType=None, processingParameterSet=None, firstDimensionProcessingParameterSet=None, higherDimensionProcessingParameterSet=None, projected3DProcessingParamaterSet=None):
        super(SpectrumMultiDType, self).__init__(numberOfDataPoints, processingSoftwareRefList, processingContactRefList, spectrumDataArray, xAxis, yAxisType, processingParameterSet, firstDimensionProcessingParameterSet, higherDimensionProcessingParameterSet, projected3DProcessingParamaterSet, )
supermod.SpectrumMultiDType.subclass = SpectrumMultiDType
# end class SpectrumMultiDType


class SpectralProcessingParameterSetType(supermod.SpectralProcessingParameterSetType):
    def __init__(self, processingSoftwareRefList=None, postAcquisitionSolventSuppressionMethod=None, dataTransformationMethod=None, calibrationCompound=None, extensiontype_=None):
        super(SpectralProcessingParameterSetType, self).__init__(processingSoftwareRefList, postAcquisitionSolventSuppressionMethod, dataTransformationMethod, calibrationCompound, extensiontype_, )
supermod.SpectralProcessingParameterSetType.subclass = SpectralProcessingParameterSetType
# end class SpectralProcessingParameterSetType


class SpectralProjectionParameterSetType(supermod.SpectralProjectionParameterSetType):
    def __init__(self, projectionAxis=None, projectionMethod=None):
        super(SpectralProjectionParameterSetType, self).__init__(projectionAxis, projectionMethod, )
supermod.SpectralProjectionParameterSetType.subclass = SpectralProjectionParameterSetType
# end class SpectralProjectionParameterSetType


class SpectralProcessingParameterSet2DType(supermod.SpectralProcessingParameterSet2DType):
    def __init__(self, processingSoftwareRefList=None, postAcquisitionSolventSuppressionMethod=None, dataTransformationMethod=None, calibrationCompound=None, directDimensionParameterSet=None, higherDimensionParameterSet=None):
        super(SpectralProcessingParameterSet2DType, self).__init__(processingSoftwareRefList, postAcquisitionSolventSuppressionMethod, dataTransformationMethod, calibrationCompound, directDimensionParameterSet, higherDimensionParameterSet, )
supermod.SpectralProcessingParameterSet2DType.subclass = SpectralProcessingParameterSet2DType
# end class SpectralProcessingParameterSet2DType


class FirstDimensionProcessingParameterSetType(supermod.FirstDimensionProcessingParameterSetType):
    def __init__(self, noOfDataPoints=None, zeroOrderPhaseCorrection=None, firstOrderPhaseCorrection=None, calibrationReferenceShift=None, spectralDenoisingMethod=None, windowFunction=None, baselineCorrectionMethod=None, parameterFileRef=None, extensiontype_=None):
        super(FirstDimensionProcessingParameterSetType, self).__init__(noOfDataPoints, zeroOrderPhaseCorrection, firstOrderPhaseCorrection, calibrationReferenceShift, spectralDenoisingMethod, windowFunction, baselineCorrectionMethod, parameterFileRef, extensiontype_, )
supermod.FirstDimensionProcessingParameterSetType.subclass = FirstDimensionProcessingParameterSetType
# end class FirstDimensionProcessingParameterSetType


class AxisWithUnitType(supermod.AxisWithUnitType):
    def __init__(self, endValue=None, unitName=None, unitCvRef=None, startValue=None, unitAccession=None):
        super(AxisWithUnitType, self).__init__(endValue, unitName, unitCvRef, startValue, unitAccession, )
supermod.AxisWithUnitType.subclass = AxisWithUnitType
# end class AxisWithUnitType


class HigherDimensionProcessingParameterSetType(supermod.HigherDimensionProcessingParameterSetType):
    def __init__(self, noOfDataPoints=None, zeroOrderPhaseCorrection=None, firstOrderPhaseCorrection=None, calibrationReferenceShift=None, spectralDenoisingMethod=None, windowFunction=None, baselineCorrectionMethod=None, parameterFileRef=None):
        super(HigherDimensionProcessingParameterSetType, self).__init__(noOfDataPoints, zeroOrderPhaseCorrection, firstOrderPhaseCorrection, calibrationReferenceShift, spectralDenoisingMethod, windowFunction, baselineCorrectionMethod, parameterFileRef, )
supermod.HigherDimensionProcessingParameterSetType.subclass = HigherDimensionProcessingParameterSetType
# end class HigherDimensionProcessingParameterSetType


class Projected3DProcessingParamaterSetType(supermod.Projected3DProcessingParamaterSetType):
    def __init__(self, positiveProjectionMethod=None, projectionAngle=None):
        super(Projected3DProcessingParamaterSetType, self).__init__(positiveProjectionMethod, projectionAngle, )
supermod.Projected3DProcessingParamaterSetType.subclass = Projected3DProcessingParamaterSetType
# end class Projected3DProcessingParamaterSetType


class fieldFrequencyLockType(supermod.fieldFrequencyLockType):
    def __init__(self, fieldFrequencyLockName=None):
        super(fieldFrequencyLockType, self).__init__(fieldFrequencyLockName, )
supermod.fieldFrequencyLockType.subclass = fieldFrequencyLockType
# end class fieldFrequencyLockType


class concentrationStandardType(supermod.concentrationStandardType):
    def __init__(self, type_=None, concentrationInSample=None, name=None):
        super(concentrationStandardType, self).__init__(type_, concentrationInSample, name, )
supermod.concentrationStandardType.subclass = concentrationStandardType
# end class concentrationStandardType


class hadamardParameterSetType(supermod.hadamardParameterSetType):
    def __init__(self, hadamardFrequency=None):
        super(hadamardParameterSetType, self).__init__(hadamardFrequency, )
supermod.hadamardParameterSetType.subclass = hadamardParameterSetType
# end class hadamardParameterSetType


class pulseSequenceFileRefListType(supermod.pulseSequenceFileRefListType):
    def __init__(self, pulseSequenceFileRef=None):
        super(pulseSequenceFileRefListType, self).__init__(pulseSequenceFileRef, )
supermod.pulseSequenceFileRefListType.subclass = pulseSequenceFileRefListType
# end class pulseSequenceFileRefListType


class processingParameterSetType(supermod.processingParameterSetType):
    def __init__(self, postAcquisitionSolventSuppressionMethod=None, calibrationCompound=None, dataTransformationMethod=None):
        super(processingParameterSetType, self).__init__(postAcquisitionSolventSuppressionMethod, calibrationCompound, dataTransformationMethod, )
supermod.processingParameterSetType.subclass = processingParameterSetType
# end class processingParameterSetType


class windowFunctionType(supermod.windowFunctionType):
    def __init__(self, windowFunctionMethod=None, windowFunctionParameter=None):
        super(windowFunctionType, self).__init__(windowFunctionMethod, windowFunctionParameter, )
supermod.windowFunctionType.subclass = windowFunctionType
# end class windowFunctionType


class ContactType(supermod.ContactType):
    def __init__(self, referenceableParamGroupRef=None, cvParam=None, cvParamWithUnit=None, cvTerm=None, userParam=None, url=None, id=None, address=None, organization=None, fullname=None, email=None):
        super(ContactType, self).__init__(referenceableParamGroupRef, cvParam, cvParamWithUnit, cvTerm, userParam, url, id, address, organization, fullname, email, )
supermod.ContactType.subclass = ContactType
# end class ContactType


def get_root_tag(node):
    tag = supermod.Tag_pattern_.match(node.tag).groups()[-1]
    rootClass = None
    rootClass = supermod.GDSClassesMapping.get(tag)
    if rootClass is None and hasattr(supermod, tag):
        rootClass = getattr(supermod, tag)
    return tag, rootClass


def parse(inFilename, silence=False):
    doc = parsexml_(inFilename)
    rootNode = doc.getroot()
    rootTag, rootClass = get_root_tag(rootNode)
    if rootClass is None:
        rootTag = 'nmrML'
        rootClass = supermod.nmrML
    rootObj = rootClass.factory()
    rootObj.build(rootNode)
    # Enable Python to collect the space used by the DOM.
    doc = None
    if not silence:
        sys.stdout.write('<?xml version="1.0" ?>\n')
        rootObj.export(
            sys.stdout, 0, name_=rootTag,
            namespacedef_='xmlns:dx="http://nmrml.org/schema"',
            pretty_print=True)
    return rootObj


def parseEtree(inFilename, silence=False):
    doc = parsexml_(inFilename)
    rootNode = doc.getroot()
    rootTag, rootClass = get_root_tag(rootNode)
    if rootClass is None:
        rootTag = 'nmrML'
        rootClass = supermod.nmrML
    rootObj = rootClass.factory()
    rootObj.build(rootNode)
    # Enable Python to collect the space used by the DOM.
    doc = None
    mapping = {}
    rootElement = rootObj.to_etree(None, name_=rootTag, mapping_=mapping)
    reverse_mapping = rootObj.gds_reverse_node_mapping(mapping)
    if not silence:
        content = etree_.tostring(
            rootElement, pretty_print=True,
            xml_declaration=True, encoding="utf-8")
        sys.stdout.write(content)
        sys.stdout.write('\n')
    return rootObj, rootElement, mapping, reverse_mapping


def parseString(inString, silence=False):
    from StringIO import StringIO
    doc = parsexml_(StringIO(inString))
    rootNode = doc.getroot()
    rootTag, rootClass = get_root_tag(rootNode)
    if rootClass is None:
        rootTag = 'nmrML'
        rootClass = supermod.nmrML
    rootObj = rootClass.factory()
    rootObj.build(rootNode)
    # Enable Python to collect the space used by the DOM.
    doc = None
    if not silence:
        sys.stdout.write('<?xml version="1.0" ?>\n')
        rootObj.export(
            sys.stdout, 0, name_=rootTag,
            namespacedef_='xmlns:dx="http://nmrml.org/schema"')
    return rootObj


def parseLiteral(inFilename, silence=False):
    doc = parsexml_(inFilename)
    rootNode = doc.getroot()
    roots = get_root_tag(rootNode)
    rootClass = roots[1]
    if rootClass is None:
        rootClass = supermod.nmrML
    rootObj = rootClass.factory()
    rootObj.build(rootNode)
    # Enable Python to collect the space used by the DOM.
    doc = None
    if not silence:
        sys.stdout.write('#from nmrML_lib import *\n\n')
        sys.stdout.write('import nmrML_lib as model_\n\n')
        sys.stdout.write('rootObj = model_.nmrML(\n')
        rootObj.exportLiteral(sys.stdout, 0, name_="nmrML")
        sys.stdout.write(')\n')
    return rootObj


USAGE_TEXT = """
Usage: python ???.py <infilename>
"""


def usage():
    print USAGE_TEXT
    sys.exit(1)


def main():
    args = sys.argv[1:]
    if len(args) != 1:
        usage()
    infilename = args[0]
    parse(infilename)


if __name__ == '__main__':
    #import pdb; pdb.set_trace()
    main()
