%%%% test decoding
testSpec = (ones(1,2000));
raw = base64encode(testSpec);
testSpecResult = base64decode(raw,'','java');
isequal(testSpec, testSpecResult)
rawzlib = zlibencode(uint8(testSpec));
rawresult = typecast(zlibdecode(rawzlib),'uint8');
isequal(testSpec, rawresult)

%%% test readNMRML and writeNMRML
file = 'MMBBI_10M12-CE01-1a.nmrML';
[nmrML,RootName] = readNMRML(file);
filename = 'test.nmrML';
writeNMRML(filename,nmrML,RootName);
[nmrML2,RootName2] = readNMRML(filename);
isequal(nmrML,nmrML2)