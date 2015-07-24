function [ outStruct ] = readPrn( fileName )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   readPrn.m  $
% $Revision:   1.2  $
% $Author:   ted.schlicke  $
% $Date:   May 28 2014 13:03:52  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Reads the passed in .prn file and returns the data as a struct.
    %
    % .prn files are structured like this:
    %
    %    Day	Total(Kg)(gt)	ngrid	39	39	gridl	25.0	25.0
    %    1.0	0.043510
    %    2.0	0.084933
    %    3.0	0.128208
    %    ...
    %
    % Usage:
    %
    %    prn = Depomod.Outputs.Readers.readPrn(path)
    %
    %  where:
    %    path: is the absolute file path of the .prn file
    %
    % Output:
    %
    %   outStruct: a struct containing the .prn data
    %
    %
    % EXAMPLES:
    %
    %    filename = 'C:\...\<site name>-E-S-3g1.prn'
    %
    %    prn = Depomod.Outputs.Readers.readPrn(filename)
    %
    %    prn.Day
    %    ans = 
    %      [1.00; 2.00; 3.00; ... ]
    %
    %    prn.Total
    %    ans = 
    %      [0.123456; 0.234567; 0.3456789; ... 


    fd = fopen(fileName,'rt');
    header = textscan(fd, '%s%s%s%u%u%s%f%f', 1);
    data   = textscan(fd, '%f%f');
    fclose(fd);
        
    outStruct.Day   = data{1}(:);
    outStruct.Total = data{2}(:);
    outStruct.NGrid = header(1,4:5);
    outStruct.GridL = header(1,7:8);
end

