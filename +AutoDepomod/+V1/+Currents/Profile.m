classdef Profile < AutoDepomod.Currents.Profile
    
    properties
        s@AutoDepomod.V1.Currents.TimeSeries;
        m@AutoDepomod.V1.Currents.TimeSeries;
        b@AutoDepomod.V1.Currents.TimeSeries;
        
        project@AutoDepomod.V1.Project;
    end
    
    methods (Static = true)
        
        function [sns, nsn] = fromFile(surface, middle, bottom)
            sns = AutoDepomod.V1.Currents.Profile;
            nsn = AutoDepomod.V1.Currents.Profile;
            
            [sns.s, nsn.s]  = AutoDepomod.V1.Currents.TimeSeries.fromFile(surface);
            [sns.m,  nsn.m] = AutoDepomod.V1.Currents.TimeSeries.fromFile(middle);
            [sns.b,  nsn.b] = AutoDepomod.V1.Currents.TimeSeries.fromFile(bottom);
            
            sns.isSNS = 1;            
        end

    end
    
end

