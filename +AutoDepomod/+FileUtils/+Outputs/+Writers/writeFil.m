function [ sizeInBytes ] = writeFil( filStruct,fileName )
%writeFil Write .fil format file from DEPOMOD Partrack
%see readFil for feild details, used to creat .fil with specific entires.
%Note this version will not pack the mass xCoord and yCoord entries into a
%single loadPos entry for the file.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   writeFil.m  $
% $Revision:   1.1  $
% $Author:   ted.schlicke  $
% $Date:   May 28 2014 13:03:52  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    MACHINEFORMAT='ieee-le';
    PERMISSION='w';
    numberOfMembers=length(filStruct.t);
    
    filePointer= fopen(fileName,PERMISSION,MACHINEFORMAT);
    for index=1:1:numberOfMembers
        fwrite(filePointer,filStruct.t(index),'uint16');% 2 2
        fwrite(filePointer,0,'int8');% 1 3
        fwrite(filePointer,0,'int8');% 1 4
        fwrite(filePointer,0,'int8');% 1 5
        fwrite(filePointer,0,'int8');% 1 6
        fwrite(filePointer,0,'int8');% 1 7
        fwrite(filePointer,0,'int8');% 1 8
        fwrite(filePointer,filStruct.loadPos(index),'float64'); % 8 16
        fwrite(filePointer,filStruct.timeSinceRel(index),'float32');% 4 20
        fwrite(filePointer,filStruct.id(index),'int8');% 1 21
        fwrite(filePointer,0,'int8');% 1 22
        fwrite(filePointer,0,'int8');% 1 23
        fwrite(filePointer,0,'int8');% 1 24
        fwrite(filePointer,filStruct.vs(index),'float64');%8 32
    end
    fclose(filePointer);
    fileInfo=dir(fileName);
    sizeInBytes=fileInfo.bytes;
end

