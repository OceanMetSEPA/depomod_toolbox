classdef Profile < Depomod.Currents.Profile
    
    properties
        s@NewDepomod.Currents.TimeSeries;
        m@NewDepomod.Currents.TimeSeries;
        b@NewDepomod.Currents.TimeSeries;
        
        project@NewDepomod.Project;
    end
    
    methods (Static = true)
        
        function p = fromFile(surface, middle, bottom)
            p = NewDepomod.Currents.Profile;
            
            p.s = NewDepomod.Currents.TimeSeries.fromFile(surface);
            p.m = NewDepomod.Currents.TimeSeries.fromFile(middle);
            p.b = NewDepomod.Currents.TimeSeries.fromFile(bottom);
            
            p.isSNS = p.s.isSNS;            
        end
    end
    
end

