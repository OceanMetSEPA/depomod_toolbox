function [ sizeInBytes ] = writePar( parStruct,fileName)
%writePar read particles 
%writePar(parStruct,fileName) write particles in parStruct to file refered to by filename.
%The file produced is compatible with the java version of DEPOMOD.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   writePar.m  $
% $Revision:   1.1  $
% $Author:   ted.schlicke  $
% $Date:   May 28 2014 13:03:52  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    MACHINEFORMAT='ieee-be';
    PERMISSION='w';
    numberOfMembers=length(parStruct.t);
    filePointer= fopen(fileName,PERMISSION,MACHINEFORMAT);
    if isfield(parStruct,'dvar')==1
        %this is a java format struct
        for index=1:1:numberOfMembers
            fwrite(filePointer,parStruct.loadPos(index),'float64'); % 8 8
            fwrite(filePointer,parStruct.xCoords(index),'float64'); % 8 16
            fwrite(filePointer,parStruct.yCoords(index),'float64'); % 8 24
            fwrite(filePointer,parStruct.vs(index),'float64'); % 8 32
            fwrite(filePointer,parStruct.dvar(index),'float64'); % 8 40
            fwrite(filePointer,parStruct.timeSinceRel(index),'float64'); % 8 48
            fwrite(filePointer,parStruct.indexI(index),'int32'); % 4 52
            fwrite(filePointer,parStruct.indexJ(index),'int32'); % 4 56
            fwrite(filePointer,parStruct.partSource(index),'int32'); % 4 60  
            fwrite(filePointer,parStruct.id(index),'int32'); % 4 64
            fwrite(filePointer,parStruct.t(index),'int32'); % 4 72 
            fwrite(filePointer,parStruct.timLoop(index),'int32'); % 4 80
        end
    else
        %this is delphi format struct - use mass instead of loadPos
        for index=1:1:numberOfMembers
            fwrite(filePointer,parStruct.mass(index),'float64'); % 8 8
            fwrite(filePointer,parStruct.xCoords(index),'float64'); % 8 16
            fwrite(filePointer,parStruct.yCoords(index),'float64'); % 8 24
            fwrite(filePointer,parStruct.vs(index),'float64'); % 8 32
            fwrite(filePointer,0,'float64'); % 8 40
            fwrite(filePointer,parStruct.timeSinceRel(index),'float64'); % 8 48
            fwrite(filePointer,0,'int32'); % 4 52
            fwrite(filePointer,0,'int32'); % 4 56
            fwrite(filePointer,0,'int32'); % 4 60  
            fwrite(filePointer,parStruct.id(index),'int32'); % 4 64
            fwrite(filePointer,parStruct.t(index),'int32'); % 4 72 
            fwrite(filePointer,0,'int32'); % 4 80        
        end
    end
    fclose(filePointer);
    fileInfo=dir(fileName);
    sizeInBytes=fileInfo.bytes;
end

