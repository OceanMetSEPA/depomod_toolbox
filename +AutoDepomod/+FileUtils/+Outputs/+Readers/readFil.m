function [ filStruct ] =  readFil( fileName)
%readFil Read .fil format file from DEPOMOD Partrack
%readFig Read .fil format file from DEPOMOD Partrack
%readFig(fileName) reads the file refered to by fileName returning a
%structure with the following fields. t  a Nx1 list of the time index when released
%loadPos the original packed data entries in the file which represent 
%both mass and spatial position, mass the unpacked mass of the particle, 
%xCoords and yCoords unpacked spatial position, timeSinceRel the time since 
%release, startTime the actual time of release, id the type of particle.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   readFil.m  $
% $Revision:   1.1  $
% $Author:   ted.schlicke  $
% $Date:   May 28 2014 13:03:50  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    MACHINEFORMAT='ieee-le';
    PERMISSION='r';
    FILSTRUCTINBYTES=32;% includes padding
    fileInfo=dir(fileName);
    sizeInBytes=fileInfo.bytes;
    numberOfMembers=sizeInBytes/FILSTRUCTINBYTES;
    filStruct.t=zeros(numberOfMembers,1);
    filStruct.loadPos=zeros(numberOfMembers,1);
    filStruct.mass=zeros(numberOfMembers,1);
    filStruct.xCoords=zeros(numberOfMembers,1);
    filStruct.yCoords=zeros(numberOfMembers,1);
    filStruct.timeSinceRel=zeros(numberOfMembers,1);
    filStruct.id=zeros(numberOfMembers,1);
    filStruct.vs=zeros(numberOfMembers,1);

    filePointer= fopen(fileName,PERMISSION,MACHINEFORMAT);
    for index=1:1:numberOfMembers
        filStruct.t(index)=fread(filePointer,1,'uint16'); % 2 2
        fread(filePointer,1,'int8');% 1 3
        fread(filePointer,1,'int8');% 1 4
        fread(filePointer,1,'int8');% 1 5
        fread(filePointer,1,'int8');% 1 6
        fread(filePointer,1,'int8');% 1 7
        fread(filePointer,1,'int8');% 1 8
        filStruct.loadPos(index)=fread(filePointer,1,'float64'); % 8 16
        filStruct.mass(index)=fix(filStruct.loadPos(index));
        filStruct.xCoords(index)=fix((filStruct.loadPos(index)-filStruct.mass(index))*1000);
        filStruct.yCoords(index)=fix((filStruct.loadPos(index)-filStruct.mass(index))*1000000)-1000*filStruct.xCoords(index);        
        filStruct.xCoords(index)=filStruct.xCoords(index)/10;
        filStruct.yCoords(index)=filStruct.yCoords(index)/10;
        filStruct.timeSinceRel(index)=fread(filePointer,1,'float32');% 4 20
        filStruct.id(index)=fread(filePointer,1,'int8');% 1 21
        fread(filePointer,1,'int8');% 1 22
        fread(filePointer,1,'int8');% 1 23
        fread(filePointer,1,'int8');% 1 24
        filStruct.vs(index)=fread(filePointer,1,'float64');% 8 32
    end
    fclose(filePointer);
end

