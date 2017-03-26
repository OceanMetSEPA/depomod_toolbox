function [ sizeInBytes ] = writeFigBe( figStruct,fileName )
%writeFigBe Write .fig format file from DEPOMOD Partrack
%see readFig for feild details, used to creat .fig with specific entires.
%Big endian version compatible with jvm byte ordering.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   writeFigBe.m  $
% $Revision:   1.1  $
% $Author:   ted.schlicke  $
% $Date:   May 28 2014 13:03:52  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    MACHINEFORMAT='ieee-be';
    PERMISSION='w';
    numberOfMembers=length(figStruct.loadPos);
    
    filePointer= fopen(fileName,PERMISSION,MACHINEFORMAT);
    for index=1:1:numberOfMembers
        fwrite(filePointer,figStruct.loadPos(index),'float64'); % 8 8
        fwrite(filePointer,figStruct.timeSinceRel(index),'float32');% 4 12
        fwrite(filePointer,figStruct.startTime(index),'int16');% 1 14
        fwrite(filePointer,figStruct.id(index),'int8');% 1 15
        fwrite(filePointer,0,'int8');% 1 16
    end
    fclose(filePointer);
    fileInfo=dir(fileName);
    sizeInBytes=fileInfo.bytes;
end

