function [ surMapOutCol1, surMapOutCol2] =mapSur( readSurStruct)
%mapSur produce domain from readSur data structure
%mapSur(readSurStruct) takes output struct from readSur and returns either 
%a MxN or two MxN matrices depending upon the number of output arguements
%and available input data. Note that the first entry of a matrix (upper left
%corner) and the assumed origin of the input data (lower left corner) do
%not match. When using imagesc to display the domian switch off
%the y axis reversal before ploting other points in x-y coordinates.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   mapSur.m  $
% $Revision:   1.1  $
% $Author:   ted.schlicke  $
% $Date:   May 28 2014 13:03:50  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 map2=isfield(readSurStruct,'outCol2');
surMapOutCol2=[];
    index=0;
    for y=39:-1: readSurStruct.yDimenNumber
        for x=1:1: readSurStruct.xDimenNumber
            index=index+1;
            surMapOutCol1(y,x)=readSurStruct.outCol1(index);
            if map2
                surMapOutCol2(y,x)=readSurStruct.outCol2(index);
            end
        end
    end
end

