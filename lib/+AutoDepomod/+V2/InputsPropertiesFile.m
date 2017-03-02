classdef InputsPropertiesFile < AutoDepomod.V2.DataPropertiesFile
    
    properties
        dataColumnCount = 6;
    end
    
    methods
        function IPF = InputsPropertiesFile(filePath)
            IPF = IPF@AutoDepomod.V2.DataPropertiesFile(filePath);  
        end
        
        function bool = scaleBiomass(IPF, factor)
            existingBiomass         = str2num(IPF.FeedInputs.biomass);
            existingStockingDensity = str2num(IPF.FeedInputs.stockingDensity);

            IPF.FeedInputs.biomass         = num2str(existingBiomass * factor);
            IPF.FeedInputs.stockingDensity = num2str(existingStockingDensity * factor);
            IPF.data(:,1:2) = IPF.data(:,1:2).*factor;
            IPF.data(:,4:5) = IPF.data(:,4:5).*factor;
        end
        
        function bool = scaleChemical(IPF, factor)
            IPF.data(:,3) = IPF.data(:,3).*factor;
            IPF.data(:,6) = IPF.data(:,6).*factor;
        end
    end
    
end

