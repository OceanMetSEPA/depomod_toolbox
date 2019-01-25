classdef TimeSeries < Depomod.Currents.TimeSeries
    
    properties
        Name@char;
        Var@char;
    end
    
    methods (Static = true)
        
        function [sns, nsn] = fromFile(datFile)
            datFile
            % Read file
            fd = fopen(datFile,'rt');
            header1 = fgetl(fd);
            header2 = fgetl(fd);
            header3 = fgetl(fd);
            data    = textscan(fd, '%u%f%f%u%f%f');
            fclose(fd);
            
            % Parse out metadata            
            regexString = '^dT=(\d+)s\s*nT=(\d+)\s*depth=([\d\.]+)m\s*([\w\-]+)@([\d\.]+)m?\s*Tide=([\d\.]+)[mW]?\s*Var=([\w\d\.\-]+)';
            
            [~,t]=regexp(header2, regexString, 'match', 'tokens');
            
            deltaT            = str2num(t{1}{1})
            numberOfTimeSteps = str2num(t{1}{2})
            siteDepth         = str2num(t{1}{3})*-1 % Depths negative
            name              = (t{1}{4})
            height            = str2num(t{1}{5})    % Heights positive
            siteTide          = str2num(t{1}{6})
            var_              = t{1}{7}             % var is reserved word
            
            % Are units ever NOT m and s? Let's assume they are for now and
            % not handle alternatives...
            
            constructorArgs = {...
                'DeltaT',            deltaT, ...
                'NumberOfTimeSteps', numberOfTimeSteps, ...
                'SiteDepth',         siteDepth, ...
                'MeterDepth',        height + siteDepth, ... % Gives negative depth
                'SiteTide',          siteTide, ...
                'Name',              name, ...
                'Var',               var_ ...
                };
            
            % Create new current objects: time, speed, direction, metadata
            % Convert cm/s to m/s
            sns = AutoDepomod.Currents.TimeSeries(double(data{4}), data{5}./100.0, data{6}, 'isSNS', 1, constructorArgs{:});
            nsn = AutoDepomod.Currents.TimeSeries(double(data{1}), data{2}./100.0, data{3}, 'isSNS', 0, constructorArgs{:});            
        end
        
        function sizeInBytes = toFile(sns, nsn, fileName)
            
            MACHINEFORMAT = 'ieee-be';
            PERMISSION    = 'w';
            
            filePointer = fopen(fileName,PERMISSION,MACHINEFORMAT);

            % Write header lines
            fprintf(filePointer,['hourly-file','\r\n']);
            fprintf(filePointer,'dT=%ds nT=%d depth=%.1fm %s@%.2fm Tide=%.2fm Var=%s\r\n', ...
                sns.DeltaT, ...
                sns.NumberOfTimeSteps,...
                sns.SiteDepth*-1,...
                sns.Name, ...
                sns.MeterDepth-sns.SiteDepth,...
                sns.SiteTide,...
                sns.Var ...
                );
            
            fprintf(filePointer,'%-29s %-29s \r\n', 'NSN', 'SNS');

            % Write each data record
            for index = 1:nsn.NumberOfTimeSteps

                rowData = [ double(nsn.Time(index)) % coerce to double so that entire row does not get truncated into integers
                            nsn.Speed(index)*100    % convert to cm/s
                            nsn.Direction(index)
                            double(sns.Time(index)) % coerce to double so that entire row does not get truncated into integers
                            sns.Speed(index)*100    % convert to cm/s
                            sns.Direction(index)
                          ];

                % Write row to file
                fprintf(filePointer, '%-9.0u %-9.2f %-9.2f %-9.0u %-9.2f %-9.2f\r\n', rowData);
            end

            % End file file a single '#' character
            fprintf(filePointer,'#\r\n');

            fclose(filePointer);
            fileInfo=dir(fileName);
            sizeInBytes=fileInfo.bytes;
             
        end
    end
    
    methods
        function TS = TimeSeries(time, speed, direction, varargin)
            TS = TS@Depomod.Currents.TimeSeries(varargin{:});
            TS.Time      = time;
            TS.Speed     = speed;
            TS.Direction = direction;
            
            TS.setUV;
        end
    end
    
end

