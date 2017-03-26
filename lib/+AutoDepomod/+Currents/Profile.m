classdef Profile < Depomod.Currents.Profile
    
    properties
        s@AutoDepomod.Currents.TimeSeries;
        m@AutoDepomod.Currents.TimeSeries;
        b@AutoDepomod.Currents.TimeSeries;
        
        project@AutoDepomod.Project;
    end
    
    methods (Static = true)
        
        function [sns, nsn] = fromFile(surface, middle, bottom)
            sns = AutoDepomod.Currents.Profile;
            nsn = AutoDepomod.Currents.Profile;
            
            [sns.s, nsn.s]  = AutoDepomod.Currents.TimeSeries.fromFile(surface);
            [sns.m,  nsn.m] = AutoDepomod.Currents.TimeSeries.fromFile(middle);
            [sns.b,  nsn.b] = AutoDepomod.Currents.TimeSeries.fromFile(bottom);
            
            sns.isSNS = 1;            
        end

    end
    
end

