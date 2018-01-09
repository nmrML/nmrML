function reOrderAttri(filenameip, filenameop)
%reOrderAttri reorder the attributes following nmrML file format.
%
% INPUT:
%   filenameip   name of the file without the nmrML attribute ordering.
%   filenameop   name of the file with the nmrML attribute ordering.
%
% written 210415 by Dr Jie Hao, Imperial College London
%%
dataw = importdata(filenameip);
%%% adjust first row
L1 = strsplit(dataw{1,1},'"?');
dataw{1,1} = [L1{1} '" standalone="yes"?' L1{2}];
%%% adjust attributes in the rest rows
for i = 2:size(dataw,1)
    clear C12;
    if (~isempty(find(dataw{i,1} == '=')))
        if length(find(dataw{i,1} == '=')>1)
            C = strsplit(dataw{i,1},'" ');
            C1 = strsplit(C{1}, ' ');
            if (isempty(find(C1{end} == '=')))
                C1tmp = 1:length(C1);
                for j2 = length(C1):-1:2
                    if(isempty(find(C1{j2} == '=')))
                        C1{j2-1} = [C1{j2-1} ' ' C1{j2}];
                        C1{j2} = [];
                        C1tmp(j2) = [];
                    else
                        C1 = C1(C1tmp);
                        break;
                    end
                end
            end
            C12{1} = strsplit(C1{end}, '="');
            for j = 2:length(C)
                C12{j} = strsplit(C{j}, '="');
            end
            Ctmp = strsplit(C12{end}{2},'"');
            C12{end} = [C12{end}(1), Ctmp{1}];
            C121 = Ctmp(2:end);
            %%% C12 contains attributes and values in each cell.
            Cx = attriOrder(C12);
            tmp1 = strsplit(dataw{i,1},'<');
            tmp2 = strsplit(tmp1{2},' ');
            Ctmp2 = [tmp1{1} '<' tmp2{1}];
            for j = 1:length(Cx)
                if (length(Cx{j}) == 2)
                    Ctmp2 = [Ctmp2 ' ' Cx{j}{1} '="' Cx{j}{2} '"'];
                else
                    Ctmp2 = [Ctmp2 ' ' Cx{j}{1} '="' '"'];
                end
            end
            Ctmp2 = [Ctmp2 C121{1}];
        end
        dataw{i,1} = Ctmp2;
    end
end
%%% save the attributes adjusted data into output nmrML file
S = cell2charVec(dataw);
fid = fopen(filenameop, 'w');
fprintf( fid, '%s',S);
fclose(fid);