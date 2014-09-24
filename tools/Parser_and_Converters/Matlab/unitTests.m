testSpec = (ones(1,2000));
raw = base64encode(testSpec);
testSpecResult = base64decode(raw,'','java');
isequal(testSpec, testSpecResult)
rawzlib = zlibencode(uint8(testSpec));
rawresult = typecast(zlibdecode(rawzlib),'uint8');
isequal(testSpec, rawresult)