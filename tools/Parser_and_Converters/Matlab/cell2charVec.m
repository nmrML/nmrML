function S = cell2charVec(C)
%cell2charVec Converts a row vector strings cell array into character array.
% INPUT:
%   C            row vector cell array.
%   S            character array.
%
%written 210415 by Dr Jie Hao, Imperial College London

% if C has the correct dimensions
if (size(C,2) ~= 1)
    error(sprintf('%s must be a row vecotr cell',  inputname(1)));
end

S = [];
%%%% add each row of C into S with return new line char in between
for i = 1:size(C,1)
    Ci = C{i,:};
    Cc = char(Ci);
    nCol = size(Cc,2);
    Slength = length(S);
    if (Slength > 0)
        S(1,(Slength+1)) = char(13);
        Slength = length(S);
    end
    S(1,(Slength+1):(Slength+nCol)) = Cc;
end

% convert char code into char.
S = char(S);

