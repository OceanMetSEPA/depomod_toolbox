classdef BathymetryFile < AutoDepomod.V2.DataPropertiesFile
    
    properties
%         V1BathymetryFile@AutoDepomod.V1.BathymetryFile
%         V1DomainFile@AutoDepomod.V1.DomainFile
    end
    
    methods
        
        function B = BathymetryFile(filePath)
            B@AutoDepomod.V2.DataPropertiesFile(filePath); 
        end
        
        function b = bathymetry(B)
            b = B.data;
        end
        
        function dcc = dataColumnCount(B)
            dcc = str2num(B.Domain.data.numberOfElementsY);
        end
        
        
    end
    
end

