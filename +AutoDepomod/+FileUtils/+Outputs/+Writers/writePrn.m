function [ sizeInBytes ] = writePrn(prnStruct, fileName)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   writePrn.m  $
% $Revision:   1.2  $
% $Author:   ted.schlicke  $
% $Date:   May 28 2014 13:03:54  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Writes out the passed in prnStruct to the passed in filename
    % according to the standard format for a .prn file, i.e.
    %
    %    Day	Total(Kg)(gt)	ngrid	39	39	gridl	25.0	25.0
    %    1.0	0.043510
    %    2.0	0.084933
    %    3.0	0.128208
    %    ...
    %
    % Usage:
    %
    %    sizeInBytes = Depomod.Outputs.Writers.writePrn(prnStruct, fileName)
    %
    %  where:
    %    prnStruct: is a struct similar in structure to that returned by
    %    Depomod.Outputs.Readers.readPrn
    %
    %    fileName: is the destination file path
    %
    % Output:
    %
    %   sizeInBytes: the size of the produced file in bytes
    %

    MACHINEFORMAT='ieee-be';
    PERMISSION='w';
    numberOfMembers = length(prnStruct.Day);
    filePointer = fopen(fileName,PERMISSION,MACHINEFORMAT);
    
    header = {};
    header{1} = 'Day';
    header{2} = 'Total(Kg)';
    header{3} = 'ngrid';
    header{4} = num2str(prnStruct.NGrid{1});
    header{5} = num2str(prnStruct.NGrid{1});
    header{6} = 'gridl';
    header{7} = num2str(prnStruct.GridL{1},'%0.1f');
    header{8} = num2str(prnStruct.GridL{2},'%0.1f');
    
    fprintf(filePointer,[strjoin(header, '\t'),'\r\n']);
    
    for index = 1:1:numberOfMembers
        day   = num2str(prnStruct.Day(index),  '%0.1f');
        total = num2str(prnStruct.Total(index),'%0.9f');
                
        fprintf(filePointer,[day,'\t',sprintf(total,'%0.9f'),'\r\n']);
    end
    
    fclose(filePointer);
    fileInfo=dir(fileName);
    sizeInBytes=fileInfo.bytes;
end

