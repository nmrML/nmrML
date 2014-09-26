%%%%% test nmrML parser with example file
file = 'MMBBI_10M12-CE01-1a.nmrML';
nmrML = readNMRML(file);
plot(nmrML.spectrumList.spectrum1D.spectrumDataArray.ppm,...
    nmrML.spectrumList.spectrum1D.spectrumDataArray.intensity)
set(gca,'XDir','reverse');
xlabel('ppm')
ylabel('Intensity')
title(file)
