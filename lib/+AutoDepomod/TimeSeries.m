classdef TimeSeries < handle
        
    properties
        Time      = [];
        Value     = [];
        ValueName = '';
        TimeUnit  = '';
        ValueUnit = '';
        source = []; % PrnFile or DepomodTimeSeriesFile
    end

    methods (Static = true)
        function TS = createFromPrnFile(prnFile)
            TS = AutoDepomod.TimeSeries();

            if ~isequal(class(prnFile),'AutoDepomod.V1.PrnFile')
                prnFile = AutoDepomod.V1.PrnFile.createFromFile(prnFile);
            end

            TS.Time  = prnFile.Day;
            TS.Value = prnFile.Total;
            TS.ValueName = 'Total EmBZ mass';
            TS.ValueUnit = 'kg';
            TS.TimeUnit  = 'day';
            TS.source    = prnFile;
        end

        function TS = createFromTimeSeriesFile(tsFile, column)
            TS = AutoDepomod.TimeSeries();

            if ~isequal(class(tsFile),'AutoDepomod.V2.TimeSeriesFile')
                tsFile = AutoDepomod.V2.TimeSeriesFile(tsFile);
            end

            TS.Time  = tsFile.data(:,1);
            TS.Value = tsFile.data(:,column);
            TS.ValueName = tsFile.headers{column};
            TS.ValueUnit = tsFile.units{column};
            TS.TimeUnit  = tsFile.units{1};
            TS.source    = tsFile;
        end
    end

    methods
        
        function TS = scale(TS, factor)
            TS.Value = TS.Value * factor;              
        end
        
        function sizeInBytes = toFile(TS, filePath)                      
            if ~exist('filePath', 'var')
                filePath = TS.source.path;
                warning('No file path given. Existing source file will be overwritten.')
            end

            sourceType = class(TS.source);

            if isequal(sourceType,'AutoDepomod.V1.PrnFile')
                TS.source.Total = TS.Value;
                TS.source.toFile(filePath);                
            elseif isequal(sourceType,'AutoDepomod.V2.TimeSeriesFile')
                sourceColumn = find(strcmp(TS.source.headers, TS.ValueName));
                TS.source.data(:, sourceColumn) = TS.Value;
                TS.source.toFile(filePath); 
            else
                error('AutoDepomod:TimeSeries:InsufficientData', ...
                    'TimeSeries needs a .prn or .depomodtimeseries source.');
            end

            fileInfo    = dir(filePath);
            sizeInBytes = fileInfo.bytes;
        end
        
        function plot(TS)
            figure; plot(TS.Time,TS.Value); grid on;
            xlabel(['Time (', TS.TimeUnit, ')']); ylabel([TS.ValueName, '(', TS.ValueUnit, ')']);
        end
        
        function [val] = valueAt(TS, idx)
            % Returns the total value at the day passed in
            
            if length(TS.Time) >= idx
                val = TS.Value(idx,1);
            else
                val = [];
            end
        end
              
    end
    
end

