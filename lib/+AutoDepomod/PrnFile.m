classdef PrnFile < handle
    % Base class for wrapping functionality related to Depomod .prn files.
    % This would have simply been called Prn, but astonishingly Windows
    % does not allow files to be called 'prn'.
    %
    %
    % DEPENDENCIES:
    %
    %  - Depomod/Outputs/Readers/readPrn.m
    % 
        
    properties
        path    = [];
        
        Day   = [];
        Total = [];
        NGrid = [];
        GridL = [];
    end

    methods (Static = true)
        function prn = createFromFile(path)
            prn = AutoDepomod.PrnFile();
            
            prn.path = path;

            fd = fopen(path,'rt');
            header = textscan(fd, '%s%s%s%u%u%s%f%f', 1);
            data   = textscan(fd, '%f%f');
            fclose(fd);

            prn.Day   = data{1}(:);
            prn.Total = data{2}(:);
            prn.NGrid = header(1,4:5);
            prn.GridL = header(1,7:8);
        end
    end
        
    methods

        function ts = toTimeSeries(Prn)
            ts = Depomod.TimeSeries.createFromPrnFile(Prn);
        end
        
        function sizeInBytes = toFile(Prn, fileName)          
            MACHINEFORMAT   = 'ieee-be';
            PERMISSION      = 'w';
            numberOfMembers = length(Prn.Day);
            filePointer     = fopen(fileName, PERMISSION, MACHINEFORMAT);

            header = {};
            header{1} = 'Day';
            header{2} = 'Total(Kg)';
            header{3} = 'ngrid';
            header{4} = num2str(Prn.NGrid{1});
            header{5} = num2str(Prn.NGrid{1});
            header{6} = 'gridl';
            header{7} = num2str(Prn.GridL{1},'%0.1f');
            header{8} = num2str(Prn.GridL{2},'%0.1f');

            fprintf(filePointer,[strjoin(header, '\t'),'\r\n']);

            for index = 1:1:numberOfMembers
                day   = num2str(Prn.Day(index),  '%0.1f');
                total = num2str(Prn.Total(index),'%0.9f');

                fprintf(filePointer,[day,'\t',sprintf(total,'%0.9f'),'\r\n']);
            end

            fclose(filePointer);
            fileInfo    = dir(fileName);
            sizeInBytes = fileInfo.bytes;
        end

    end % methods
    
end

