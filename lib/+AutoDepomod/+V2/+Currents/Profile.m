classdef Profile < AutoDepomod.Currents.Profile
    
    properties
        s@AutoDepomod.V2.Currents.TimeSeries;
        m@AutoDepomod.V2.Currents.TimeSeries;
        b@AutoDepomod.V2.Currents.TimeSeries;
        
        project@AutoDepomod.V2.Project;
    end
    
    methods (Static = true)
        
        function p = fromFile(surface, middle, bottom)
            p = AutoDepomod.V2.Currents.Profile;
            
            p.s = AutoDepomod.V2.Currents.TimeSeries.fromFile(surface);
            p.m = AutoDepomod.V2.Currents.TimeSeries.fromFile(middle);
            p.b = AutoDepomod.V2.Currents.TimeSeries.fromFile(bottom);
            
            p.isSNS = p.s.isSNS;            
        end
    end
    
end

