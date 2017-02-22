classdef InputsPropertiesFile < AutoDepomod.V2.DataPropertiesFile
    
    properties
        dataColumnCount = 6;
    end
    
    methods
        function IPF = InputsPropertiesFile(filePath)
            IPF = IPF@AutoDepomod.V2.DataPropertiesFile(filePath);  
        end
    end
    
end

