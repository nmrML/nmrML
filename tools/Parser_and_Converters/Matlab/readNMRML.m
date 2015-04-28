function [NMRML, RootName] = readNMRML(file)
%readNMRML reads a nmrML spectrum data file, and saved it in
%matlab structure tree. 
%
% INPUT:
%   file         nmrML input file name in string 
%
% OUTPUT:
%   NMRML        Matlab structure tree corresponding to nmrML file,
%                also added the decoded spectrum data intensity, ppm and
%                fid data intensity.
%   RootName     String with nmrML tag name used for root (top level) node
%
%  written 120914 by Dr Jie Hao, Imperial College London
%%
[tree, RootName] = xml_read(file);         % read nmrML file
% tree.ATTRIBUTE.version = num2str(sprintf('%.1f',tree.ATTRIBUTE.version));
NMRML = tree;
if  strcmp(NMRML.spectrumList.spectrum1D.spectrumDataArray.ATTRIBUTE.byteFormat,'Integer32')
    raw1 = base64decode(NMRML.spectrumList.spectrum1D.spectrumDataArray.CONTENT, '', 'java');   % convert xml image to raw binary
    spectrumDataLength = NMRML.spectrumList.spectrum1D.spectrumDataArray.ATTRIBUTE.encodedLength;
    spectrumData = zlibdecode(raw1);
    
    nspec = length(spectrumData);
    if (nspec~= str2num(spectrumDataLength))
        error('Error in number of data points.');
    end
    forppm = NMRML.acquisition.acquisition1D.acquisitionParameterSet.DirectDimensionParameterSet;
    sf = str2num(forppm.irradiationFrequency.ATTRIBUTE.value);
    sw = str2num(forppm.sweepWidth.ATTRIBUTE.value);
    swp = sw/sf;
    offset = str2num(NMRML.spectrumList.spectrum1D.xAxis.ATTRIBUTE.startValue);
    dppm = swp/(nspec-1);
    ppm = offset:-dppm:(offset-swp);
    NMRML.spectrumList.spectrum1D.spectrumDataArray.intensity = spectrumData;
    NMRML.spectrumList.spectrum1D.spectrumDataArray.ppm = ppm;
    %%% read Fid
    raw2 = base64decode(NMRML.acquisition.acquisition1D.fidData.CONTENT, '', 'java');   % convert xml image to raw binary
    fidDatalength = NMRML.acquisition.acquisition1D.fidData.ATTRIBUTE.encodedLength;
    fidData = zlibdecode(raw2);
    NMRML.acquisition.acquisition1D.fidData.intensity = fidData;
%     fidData = zlibdecode(raw2);
    %
    % if (length(fidData)~=(fidDatalength/2))
    %     error('Error in number of data points.');
    % end
else
    error('Spectrum byteFormat not int32.');
end




