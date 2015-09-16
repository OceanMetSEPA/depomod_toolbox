classdef (Abstract) Profile
    
    properties        
        isSNS = 0;
    end
    
    methods
        
        function l = length(P)
            l = P.s.NumberOfTimeSteps;
        end
        
        function p = toRCMProfile(P, varargin)
            AutoDepomod.FileUtils.isRCMPackageAvailable;
            
            p = RCM.Current.Profile('WaterDepth', P.s.SiteDepth*-1);
            
            p.addBin(P.b.toRCMTimeSeries(varargin{:}));
            p.addBin(P.m.toRCMTimeSeries(varargin{:}));
            p.addBin(P.s.toRCMTimeSeries(varargin{:}));
        end
        
        function scaleSpeed(P, factor)
            if length(factor) == 1
                factor = repmat(factor, 1,3);
            end
            
            P.s.scaleSpeed(factor(1));
            P.m.scaleSpeed(factor(2));
            P.b.scaleSpeed(factor(3));
        end
            
    end
    
end

