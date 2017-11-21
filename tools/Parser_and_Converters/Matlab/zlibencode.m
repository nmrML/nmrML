function output = zlibencode(input)
%ZLIBENCODE Compress input bytes with ZLIB.
%
%    output = zlibencode(input)
%
% The function takes a char, int8, or uint8 array INPUT and returns
% compressed bytes OUTPUT as a uint8 array. Note that the compression
% doesn't preserve input dimensions. JAVA must be enabled to use the
% function.
%
% See also zlibdecode typecast
% Copyright (c) 2012, Kota Yamaguchi
% All rights reserved.

error(nargchk(1, 1, nargin));
error(javachk('jvm'));
if ischar(input), input = uint8(input); end
if ~isa(input, 'int8') && ~isa(input, 'uint8')
    error('Input must be either char, int8 or uint8.');
end

buffer = java.io.ByteArrayOutputStream();
zlib = java.util.zip.DeflaterOutputStream(buffer);
zlib.write(input, 0, numel(input));
zlib.close();
output = typecast(buffer.toByteArray(), 'uint8')';

end