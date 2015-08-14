function [ parStruct ] = readPar( fileName )
%readPar read particles 
%readPar(fileName) read particles produced by java DEPOMOD from file refered to by filename.
%The particle records are output in a structure.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   readPar.m  $
% $Revision:   1.1  $
% $Author:   ted.schlicke  $
% $Date:   May 28 2014 13:03:50  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    MACHINEFORMAT='ieee-be';
    PERMISSION='r';
    FILSTRUCTINBYTES=80;
    fileInfo=dir(fileName);
    sizeInBytes=fileInfo.bytes;
    numberOfMembers=sizeInBytes/FILSTRUCTINBYTES;
    
    parStruct.t=zeros(numberOfMembers,1);
    parStruct.loadPos=zeros(numberOfMembers,1);
    parStruct.mass=zeros(numberOfMembers,1);
    parStruct.xCoords=zeros(numberOfMembers,1);
    parStruct.yCoords=zeros(numberOfMembers,1);
    parStruct.timeSinceRel=zeros(numberOfMembers,1);
    parStruct.id=zeros(numberOfMembers,1);
    parStruct.vs=zeros(numberOfMembers,1);
    parStruct.dvar=zeros(numberOfMembers,1);
    parStruct.indexI=zeros(numberOfMembers,1);
    parStruct.indexJ=zeros(numberOfMembers,1);
    parStruct.partSource=zeros(numberOfMembers,1);
    parStruct.timLoop=zeros(numberOfMembers,1);
    parStruct.starttime=zeros(numberOfMembers,1);
    parStruct.age=zeros(numberOfMembers,1);
    
    filePointer= fopen(fileName,PERMISSION,MACHINEFORMAT);
    for index=1:1:numberOfMembers
        parStruct.loadPos(index)=fread(filePointer,1,'float64'); % 8 8
        parStruct.mass(index)=parStruct.loadPos(index);
        parStruct.xCoords(index)=fread(filePointer,1,'float64'); % 8 16
        parStruct.yCoords(index)=fread(filePointer,1,'float64'); % 8 24
        parStruct.vs(index)=fread(filePointer,1,'float64'); % 8 32
        parStruct.dvar(index)=fread(filePointer,1,'float64'); % 8 40
        parStruct.timeSinceRel(index)=fread(filePointer,1,'float64'); % 8 48        
        parStruct.indexI(index)=fread(filePointer,1,'int32'); % 4 52
        parStruct.indexJ(index)=fread(filePointer,1,'int32'); % 4 56
        parStruct.partSource(index)=fread(filePointer,1,'int32'); % 4 60
        parStruct.id(index)=fread(filePointer,1,'int32'); % 4 64
        parStruct.t(index)=fread(filePointer,1,'int32'); % 4 68
        parStruct.timLoop(index)=fread(filePointer,1,'int32'); % 4 72
        parStruct.startTime(index)=fread(filePointer,1,'int32'); % 4 76
        parStruct.age(index)=fread(filePointer,1,'int32'); % 4 80
    end
    
    fclose(filePointer);
    
end

