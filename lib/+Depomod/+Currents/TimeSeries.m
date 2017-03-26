classdef TimeSeries < dynamicprops
    
    properties
        Time@double;
        Speed@double;
        Direction@double;
        u@double;
        v@double;
        
        MeterDepth@double;
        SiteDepth@double;
        DeltaT@double;
        NumberOfTimeSteps@double;
        SiteTide@double;
        
        LengthUnitSIConversionFactor@double = 1.0;
        TimeUnitSIConversionFactor@double   = 1.0;
        
        isSNS = [];
    end
    
    methods
        
        function TS = TimeSeries(varargin)
           if ~isempty(varargin)
                for i = 1:2:size(varargin,2)
                    % Dynamically populate nested properties
                    % Calling function this way suppresses text output
                    if ischar(varargin{i+1})
                        cmd = sprintf('TS.(''%s\'') = ''%s''', varargin{i},varargin{i+1});
                    else
                        cmd = sprintf('TS.(''%s\'') = %s', varargin{i},num2str(varargin{i+1}));
                    end
                    evalc(cmd);
                end   
            end
        end
        
        function idxs = timeIndexes(TS)
            idxs = (1:length(TS.Time))';
        end
        
        function t = contextualiseTime(TS, startDatenum)
            DeltaTDays = TS.DeltaT/(60*60*24); % Assumes DeltaT is always in seconds.          
            
            t = startDatenum + (TS.timeIndexes - 1)* DeltaTDays;       
        end
        
        function m = meanSpeed(TS)
            m = mean(TS.Speed);
        end
        
        function scaleSpeed(TS, factor)
            TS.Speed = TS.Speed * factor;
            TS.setUV;
        end
        
        function ts = toRCMTimeSeries(TS, varargin)
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
            
            ts = RCM.Current.TimeSeries.create(TS.contextualiseTime(startTime), TS.Speed, TS.Direction);
            ts.HeightAboveBed = TS.MeterDepth - TS.SiteDepth;
        end
        
        function setUV(TS)
            [TS.v, TS.u] = pol2cart(TS.Direction*pi/180,TS.Speed);
        end
        
        function setSpeedAndDirection(TS)
            [TS.Direction, TS.Speed]=cart2pol(TS.v, TS.u);
            TS.Direction = TS.Direction * 180 / pi;
            indx = find(TS.Direction<0);
            TS.Direction(indx) = TS.Direction(indx)+360;
        end
    end
    
end

