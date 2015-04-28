function Cx = attriOrder(C)
%attriOrder adjust attributes order set by nmrML. 
%
% INPUT:
%   C            cells containing attributes in matlab default order.
%   Cx           cells containing attributes in nmrML order.
%
% written 210415 by Dr Jie Hao, Imperial College London
%%

%%% attribute order list
attriOrder ={'xmlns', 'xmlns:xsi', 'id', 'fullName','version', 'xsi:schemaLocation', ...
    'URI','email','cvRef','accession',...
    'name', 'value','location','sha1','order', 'softwareRef', ...
    'numberOfSteadyStateScans',' numberOfScans',...
    'unitAccession','unitName','unitCvRef','startValue','endValue',...
    'decoupled','numberOfDataPoints','compressed','encodedLength','byteFormat'};

%%% reorder input attributes
for i = 1:length(C)
    fields{i} = C{i}{1};
end
[~,a] = ismember(fields,attriOrder);
[~,b] = sort(a);
for i = 1:length(b)
    Cx{i} = C{b(i)};
end