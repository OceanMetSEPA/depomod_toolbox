classdef TimeSeries < AutoDepomod.Currents.TimeSeries
    
      methods (Static = true)
        
        function ts = fromFile(datFile)
            % Read file
            fd = fopen(datFile,'rt');
            
            refStr     = '#startOfDataMarker';
            matchStr   = '';
            dataPrefix = 'Flowmetry.';
            
            while ~isequal(matchStr, refStr)
                line = fgetl(fd);
                
                if ~isempty(strfind(line, dataPrefix))
                    line = strrep(line, dataPrefix, '');
                    evalc(line);
                end
   
                matchStr = line;
            end
            
            isSNS = 0;
            
            if strfind(datFile, '-S-')
                isSNS = 1;
            end
                
            data = textscan(fd, '%f,%f,%f');
            
            fclose(fd);            
            
            constructorArgs = {...
                'DeltaT',            deltaT, ...
                'NumberOfTimeSteps', numberOfTimeSteps, ...
                'SiteDepth',         siteDepth, ...
                'MeterDepth',        meterDepth, ...
                'SiteTide',          siteTide, ...
                'LengthUnitSIConversionFactor', lengthUnitsSiConversionFactor, ...
                'TimeUnitSIConversionFactor',   timeUnitsSiConversionFactor, ...
                'isSNS', isSNS ...
                };
            
            ts = AutoDepomod.V2.Currents.TimeSeries(data{1}, data{2}, data{3}, constructorArgs{:});            
        end
        
        function sizeInBytes = writeToFile(c, fileName)
            
            MACHINEFORMAT = 'ieee-be';
            PERMISSION    = 'w';
            
            filePointer = fopen(fileName,PERMISSION,MACHINEFORMAT);

            % Write header lines
            fprintf(filePointer,['#',datestr(now,'ddd mmm dd HH:MM:SS UTC YYYY'),'\r\n']);
            fprintf(filePointer, 'Flowmetry.deltaT=%.1f\r\n', c.DeltaT);
            fprintf(filePointer, 'Flowmetry.lengthUnitsSiConversionFactor=%.1f\r\n', c.LengthUnitSIConversionFactor);
            fprintf(filePointer, 'Flowmetry.meterDepth=%.1f\r\n', c.MeterDepth);
            fprintf(filePointer, 'Flowmetry.numberOfTimeSteps=%d\r\n', c.NumberOfTimeSteps);
            fprintf(filePointer, 'Flowmetry.siteDepth=%.1f\r\n', c.SiteDepth);
            fprintf(filePointer, 'Flowmetry.siteTide=%.1f\r\n', c.SiteTide);
            fprintf(filePointer, 'Flowmetry.timeUnitsSiConversionFactor=%.1f\r\n', c.TimeUnitSIConversionFactor);
            fprintf(filePointer, 'endOfDataMarker=endOfDataMarker\r\n');
            fprintf(filePointer, 'startOfDataMarker=startOfDataMarker\r\n');
            fprintf(filePointer, '#startOfDataMarker\r\n');

            % Write each data record
            for index = 1:c.NumberOfTimeSteps
                % Write row to file
                fprintf(filePointer, '%.5f,%.8f,%.8f\r\n', c.Time(index), c.u(index), c.v(index));
            end

            % End file file a single '#' character
            fprintf(filePointer,'#\r\n');

            fclose(filePointer);
            fileInfo=dir(fileName);
            sizeInBytes=fileInfo.bytes;
             
        end 
      end
    
    methods
        function TS = TimeSeries(time, u, v, varargin)
            TS = TS@AutoDepomod.Currents.TimeSeries(varargin{:});
            
            TS.Time = time;
            TS.u    = u;
            TS.v    = v;
            
            TS.setSpeedAndDirection;
        end
        
        function sizeInBytes = toFile(TS, filePath)
            sizeInBytes = AutoDepomod.V2.Currents.TimeSeries.writeToFile(TS, filePath);
        end
        
    end
    
end

