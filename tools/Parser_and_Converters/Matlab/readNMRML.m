function tree = readNMRML(file)
%readNMRMLspectrumData reads a nmrML file, and saved in
%matlab structure tree. 
%
% INPUT:
%   file - nmrML file name in string 
%
% OUTPUT:
%   tree - tree of structs and/or cell arrays corresponding to nmrML file,
%          and also include the decoded spectrum data intensity, ppm and
%          fid data intensity.
%
%  written 120914 by Dr Jie Hao, Imperial College London
%%
tree = xml_read(file);         % read nmrML file

if  strcmp(tree.spectrumList.spectrum1D.spectrumDataArray.ATTRIBUTE.byteFormat,'Integer32')
    raw1 = base64decode(tree.spectrumList.spectrum1D.spectrumDataArray.CONTENT, '', 'java');   % convert xml image to raw binary
    spectrumDataLength = tree.spectrumList.spectrum1D.spectrumDataArray.ATTRIBUTE.encodedLength;
    spectrumData = zlibdecode(raw1);
    
    nspec = length(spectrumData);
    if (nspec~=spectrumDataLength)
        error('Error in number of data points.');
    end
    forppm = tree.acquisition.acquisition1D.acquisitionParameterSet.DirectDimensionParameterSet;
    sf = forppm.irradiationFrequency.ATTRIBUTE.value;
    sw = forppm.sweepWidth.ATTRIBUTE.value;
    swp = sw/sf;
    offset = tree.spectrumList.spectrum1D.xAxis.ATTRIBUTE.startValue;
    dppm = swp/(nspec-1);
    ppm = offset:-dppm:(offset-swp);
    tree.spectrumList.spectrum1D.spectrumDataArray.intensity = spectrumData;
    tree.spectrumList.spectrum1D.spectrumDataArray.ppm = ppm;
    %%% read Fid
    raw2 = base64decode(tree.acquisition.acquisition1D.fidData.CONTENT, '', 'java');   % convert xml image to raw binary
    fidDatalength = tree.acquisition.acquisition1D.fidData.ATTRIBUTE.encodedLength;
    fidData = zlibdecode(raw2);
    tree.acquisition.acquisition1D.fidData.intensity = fidData;
%     fidData = zlibdecode(raw2);
    %
    % if (length(fidData)~=(fidDatalength/2))
    %     error('Error in number of data points.');
    % end
else
    error('Spectrum byteFormat not int32.');
end



