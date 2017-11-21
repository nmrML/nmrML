function output = zlibdecode(input)
%ZLIBDECODE Decompress input bytes using ZLIB.
%
%    output = zlibdecode(input)
%
% The function takes a compressed byte array INPUT and returns inflated
% bytes OUTPUT. The INPUT is a result of GZIPENCODE function. The OUTPUT
% is always an 1-by-N uint8 array. JAVA must be enabled to use the function.
%
% See also zlibencode typecast
% Copyright (c) 2012, Kota Yamaguchi
% All rights reserved.

error(nargchk(1, 1, nargin));
error(javachk('jvm'));
if ischar(input)
  warning('zlibdecode:inputTypeMismatch', ...
          'Input is char, but treated as uint8.');
  input = int8(input);
end
% if ~isa(input, 'int8') && ~isa(input, 'uint8')
%     error('Input must be either int8 or uint8.');
% end

buffer = java.io.ByteArrayOutputStream();
zlib = java.util.zip.InflaterOutputStream(buffer);
zlib.write(input, 0, numel(input));
zlib.close();
output = typecast(buffer.toByteArray(), 'int32')';

end
