classdef InputsPropertiesFile < AutoDepomod.V2.PropertiesFile
    
    properties
        data = [];
    end
    
    methods
        
        function IPF = InputsPropertiesFile(filePath)
            IPF = IPF@AutoDepomod.V2.PropertiesFile(filePath);
            
                       
        end
        
        function readDataTable(IPF)
            fid = fopen(IPF.path, 'r');
            
            tline = fgets(fid);
            
            while ~isequal(tline(1:length(IPF.startOfDataMarker)+1), ['#',IPF.startOfDataMarker])
                tline = fgets(fid);
            end
            
            fclose(fid);
        end
    end
    
end

