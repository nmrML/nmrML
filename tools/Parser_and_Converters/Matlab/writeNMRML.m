function writeNMRML(filename,tree, RootName)
%writeNMRML writes a matlab structure tree into nmrML file format. 
%
% INPUT:
%   filename     nmrML output file name in string 
%   tree         Matlab structure tree corresponding to nmrML file
%   RootName     String with nmrML tag name used for root (top level) node
%
% written 210415 by Dr Jie Hao, Imperial College London
%%
%%% remove non-compressed values
tree.spectrumList.spectrum1D.spectrumDataArray = rmfield(tree.spectrumList.spectrum1D.spectrumDataArray, 'intensity');
tree.spectrumList.spectrum1D.spectrumDataArray= rmfield(tree.spectrumList.spectrum1D.spectrumDataArray, 'ppm');
tree.acquisition.acquisition1D.fidData = rmfield(tree.acquisition.acquisition1D.fidData, 'intensity');
%%% temporary file name
filetmp = 'testtmp.nmrML';
xml_write(filetmp, tree, RootName);
%%% reorder attributes in nmrML format.
reOrderAttri(filetmp, filename);
%%% delete temporary file
delete(filetmp);