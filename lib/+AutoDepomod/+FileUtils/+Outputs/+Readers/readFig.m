function [ filStruct ] =  readFig( fileName)
%readFig Read .fig format file from DEPOMOD Resus g-model
%readFig(fileName) reads the file refered to by fileName returning a
%structure with the following fields. loadPos a Nx1 list of the original 
%packed data entries in the file which represent both mass and spatial position,
%mass the unpacked mass of the particle, xCoords and yCoords unpacked
%spatial position, timeSinceRel the time since release, startTime  the
%actual time of release, id the type of particle. Note this file will not
%contain all entries as current particles on the bed or in suspension are
%not written to file by DEPOMOD.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   readFig.m  $
% $Revision:   1.1  $
% $Author:   ted.schlicke  $
% $Date:   May 28 2014 13:03:50  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    MACHINEFORMAT='ieee-le';
    PERMISSION='r';
    FILSTRUCTINBYTES=16;% includes padding
    fileInfo=dir(fileName);
    sizeInBytes=fileInfo.bytes;
    numberOfMembers=sizeInBytes/FILSTRUCTINBYTES;
    filStruct.loadPos=zeros(numberOfMembers,1);
    filStruct.mass=zeros(numberOfMembers,1);
    filStruct.xCoords=zeros(numberOfMembers,1);
    filStruct.yCoords=zeros(numberOfMembers,1);
    filStruct.timeSinceRel=zeros(numberOfMembers,1);
    filStruct.startTime=zeros(numberOfMembers,1);
    filStruct.id=zeros(numberOfMembers,1);

    filePointer= fopen(fileName,PERMISSION,MACHINEFORMAT);
    for index=1:1:numberOfMembers
        filStruct.loadPos(index)=fread(filePointer,1,'float64'); % 1 8
        filStruct.mass(index)=fix(filStruct.loadPos(index));
        filStruct.xCoords(index)=fix((filStruct.loadPos(index)-filStruct.mass(index))*1000);
        filStruct.yCoords(index)=fix((filStruct.loadPos(index)-filStruct.mass(index))*1000000)-1000*filStruct.xCoords(index);        
        filStruct.xCoords(index)=filStruct.xCoords(index)/10;
        filStruct.yCoords(index)=filStruct.yCoords(index)/10;
        filStruct.timeSinceRel(index)=fread(filePointer,1,'float32');% 4 12
        filStruct.startTime(index)=fread(filePointer,1,'int16');% 2 14
        filStruct.id(index)=fread(filePointer,1,'int8');% 1 15
        fread(filePointer,1,'int8');% 1 16
    end
    fclose(filePointer);
end

