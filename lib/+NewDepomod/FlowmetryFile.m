classdef FlowmetryFile < NewDepomod.DataPropertiesFile
    
    properties
        depthCount;
    end
    
    methods (Static = true)
        function ff = fromRCMProfile(profile, varargin)
            % not supported yet.
            
            
        end
    end
    
    methods
        
        function F = FlowmetryFile(filePath)
            F@NewDepomod.DataPropertiesFile(filePath); 
        end
        
        function dc = get.depthCount(F)
            if isempty(F.depthCount)
                depths = strsplit(F.Flowmetry.meterDepths, ',')
                
                F.depthCount = length(depths);
            end
            
            dc = F.depthCount;
        end
        
        function dcc = dataColumnCount(F)
            % each depth has 2 columns (u, v) plus 1 time column
            dcc = F.depthCount * 2 + 1;
        end
        
        function idxs = timeIndexes(F)
            idxs = (1:size(F.data,1))';
        end
        
        function t = contextualiseTime(F, startDatenum)
            deltaTDays = str2num(F.Flowmetry.deltaT)/(60*60*24); % Assumes DeltaT is always in seconds.          
            
            t = startDatenum + (F.timeIndexes - 1)* deltaTDays;       
        end
        
        function [u,v] = uvAtDepth(F, depthIndex)
            u = F.data(:,depthIndex*2);
            v = F.data(:,(depthIndex*2)+1);
        end
        
        function [speed, direction] = speedAndDirectionAtDepth(F, depthIndex)
            [u,v] = F.uvAtDepth(depthIndex);
            [direction, speed]=cart2pol(v, u);
            
            direction = direction * 180 / pi;
            indx = find(direction<0);
            direction(indx) = direction(indx)+360;
        end
        
        function m = meanSpeedAtDepth(F, depthIndex)
            [speed, ~] = F.speedAndDirectionAtDepth(depthIndex);
            m = mean(speed);
        end
        
        function scaleSpeedAtDepth(F, depthIndex, factor)
            F.data(:, (depthIndex*2):(depthIndex*2)+1) = F.data(:, (depthIndex*2):(depthIndex*2)+1).* factor;
        end
        
        function bp = depthAtIndex(F,depthIndex)
            depths = strsplit(F.Flowmetry.meterDepths, ',');
                
            bp = str2num(depths{depthIndex});
        end
        
        function ts = toRCMTimeSeries(F, depthIndex, varargin)
            Depomod.FileUtils.isRCMPackageAvailable;
            
            startTime = 719529; % 01/01/1970
            
            if ~isempty(varargin)
                for i = 1:2:size(varargin,2)
                    switch varargin{i}
                      case 'startTime'
                        startTime = varargin{i + 1};
                    end
                end   
            end
               
            [u,v] = F.uvAtDepth(depthIndex);
            
            ts = RCM.Current.TimeSeries.createFromComponents(F.contextualiseTime(startTime), u, v);
            
            ts.Easting        = str2num(F.Flowmetry.siteXCoordinate);
            ts.Northing       = str2num(F.Flowmetry.siteYCoordinate);
            ts.HeightAboveBed = F.depthAtIndex(depthIndex) - str2num(F.Flowmetry.siteDepth);
            ts.calculateHarmonics;
        end
        
        function p = toRCMProfile(F, varargin)
            Depomod.FileUtils.isRCMPackageAvailable;
            
            p = RCM.Current.Profile();
            
            for depthIndex = 1:F.depthCount    
                p.addBin(F.toRCMTimeSeries(depthIndex, varargin{:}));
            end

            p.Easting = str2num(F.Flowmetry.siteXCoordinate);
            p.Northing = str2num(F.Flowmetry.siteYCoordinate);
        end
        
    end
    
end

