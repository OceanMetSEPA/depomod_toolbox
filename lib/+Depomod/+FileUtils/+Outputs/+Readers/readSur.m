function [ outStruct ] = readSur( fileName )
%readSur read resus output mass grid file from DEPOMOD Resus
%readSur(filename) reads .sur file refered to by filename. the output is
%stored in a structure and contains the following feilds. xCoords and
%yCoords a Nx1 lists of the sample positions (cell centers) in local
%coordinates. xDimen and yDimen spacing between cell centers. outCol1 and
%(optionally) outCol2 Nx1 lists of sample values at the cell cemters. outCol1Units 
%and outCol2Units, the entry from the header line in the .sur file. 
%The existance of outCol2 and outCol2Units depends upon the input data.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   readSur.m  $
% $Revision:   1.2  $
% $Author:   ted.schlicke  $
% $Date:   May 28 2014 13:03:52  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    A=importdata(fileName,',',1);    
    outStruct.xCoords=A.data(:,1);
    outStruct.yCoords=A.data(:,2);
    outStruct.xDimen=outStruct.xCoords(2)-outStruct.xCoords(1);
    outStruct.yDimen=outStruct.xDimen;
    outStruct.yDimenNumber=(max(outStruct.yCoords) - min(outStruct.yCoords))/outStruct.yDimen;%(outStruct.yCoords(1)+outStruct.yDimen/2)/outStruct.yDimen;
    outStruct.xDimenNumber=(max(outStruct.xCoords) - min(outStruct.xCoords))/outStruct.xDimen;%outStruct.yDimenNumber;
    outStruct.outCol1=A.data(:,3);
    if size(A.data,2)==4
        outStruct.outCol2=A.data(:,4);
    end
    outStruct.outCol1Units= A.colheaders{3};
    if size(A.data,2)==4
       outStruct.outCol2Units= A.colheaders{4};
    end
end

