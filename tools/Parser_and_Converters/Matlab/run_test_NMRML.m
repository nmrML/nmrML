clear
%%%%% test nmrML parser with example file
file = 'MMBBI_10M12-CE01-1a.nmrML';
[nmrML,RootName] = readNMRML(file);
%%%%% plot spectrum
plot(nmrML.spectrumList.spectrum1D.spectrumDataArray.ppm,...
    nmrML.spectrumList.spectrum1D.spectrumDataArray.intensity)
set(gca,'XDir','reverse');
xlabel('ppm')
ylabel('Intensity')
title(file)
% % filename = 'test.nmrML';
% % writeNMRML(filename,nmrML,RootName);
% % [nmrML2,RootName2] = readNMRML(filename);
% % isequal(nmrML,nmrML2)