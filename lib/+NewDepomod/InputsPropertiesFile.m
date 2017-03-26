classdef InputsPropertiesFile < NewDepomod.DataPropertiesFile
    
    properties
        dataColumnCount = 6;
        run@NewDepomod.Run.Base
    end
    
    methods
        function IPF = InputsPropertiesFile(filePath)
            IPF = IPF@NewDepomod.DataPropertiesFile(filePath);  
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
        
        function setBiomass(IPF, biomass, varargin) % tonnes
            
            % Note: this clears the inputs data table, including chemical
            % data
            
            IPF.FeedInputs.biomass         = num2str(biomass)
            IPF.FeedInputs.stockingDensity = num2str(biomass * 1000.0 / IPF.run.cages.cageVolume);
            
            feedWaterPercentage = 9;
            feedWastePercentage = 3;
            feedAbsorbedPercentage = 85;
            feedCarbonPercentage   = 49;
            faecesCarbonPercentage = 30;
            
            days = 365;
            feedRatio = 7; % kg/t/day
            
            for i = 1:2:length(varargin) % only bother with odd arguments, i.e. the labels
                switch varargin{i}
                    case 'feedWaterPercentage' % 
                        feedWaterPercentage = varargin{i+1};
                    case 'feedWastePercentage' % 
                        feedWastePercentage = varargin{i+1};
                    case 'feedAbsorbedPercentage' % 
                        feedAbsorbedPercentage = varargin{i+1};
                    case 'feedCarbonPercentage' % 
                        feedCarbonPercentage = varargin{i+1};
                    case 'faecesCarbonPercentage' % 
                        faecesCarbonPercentage = varargin{i+1};
                    case 'days' % 
                        days = varargin{i+1};
                    case 'feedRatio' % 
                        feedRatio = varargin{i+1};
                end
            end 
            
            hours = days*24.0;
            
            IPF.FeedInputs.numberOfTimeSteps = num2str(hours); 
            
            IPF.data = zeros(hours, 6);

            feedInputWastedSolidsProportion   = (1-feedWaterPercentage/100.0)*feedWastePercentage/100.0;
            feedInputWastedCarbonProportion   = feedInputWastedSolidsProportion*feedCarbonPercentage/100.0;
            feedInputExcretedSolidsProportion = (1-feedWaterPercentage/100.0)*(1-feedWastePercentage/100.0)*(1-feedAbsorbedPercentage/100.0);
            feedInputExcretedCarbonProportion = feedInputExcretedSolidsProportion*faecesCarbonPercentage/100.0;
            
            hourlyFeed = biomass * feedRatio / 24.0;
            
            wastedSolids   = hourlyFeed * feedInputWastedSolidsProportion;
            wastedCarbon   = hourlyFeed * feedInputWastedCarbonProportion;
            excretedSolids = hourlyFeed * feedInputExcretedSolidsProportion;
            excretedCarbon = hourlyFeed * feedInputExcretedCarbonProportion;

            IPF.data(:, 1) = wastedSolids;
            IPF.data(:, 2) = wastedCarbon;

            IPF.data(:, 4) = excretedSolids;
            IPF.data(:, 5) = excretedCarbon;
        end
        
        function setStockingDensity(IPF, stockingDensity, varargin)
            eqBiomass = stockingDensity * IPF.run.cages.cageVolume / 1000.0;
            IPF.setBiomass(eqBiomass, varargin{:});            
        end
        
        function setEmBZQuantity(IPF, quantity, varargin) % g
            
            feedWaterPercentage = 9;
            feedWastePercentage = 3;
            feedAbsorbedPercentage = 85;
            feedCarbonPercentage   = 49;
            faecesCarbonPercentage = 30;
            
            days = 118;
            
            for i = 1:2:length(varargin) % only bother with odd arguments, i.e. the labels
                switch varargin{i}
                    case 'feedWaterPercentage' % 
                        feedWaterPercentage = varargin{i+1};
                    case 'feedWastePercentage' % 
                        feedWastePercentage = varargin{i+1};
                    case 'feedAbsorbedPercentage' % 
                        feedAbsorbedPercentage = varargin{i+1};
                    case 'feedCarbonPercentage' % 
                        feedCarbonPercentage = varargin{i+1};
                    case 'faecesCarbonPercentage' % 
                        faecesCarbonPercentage = varargin{i+1};
                    case 'days' % 
                        days = varargin{i+1};
                end
            end 
            
            totalHours = days * 24.0;
            
            IPF.FeedInputs.numberOfTimeSteps = num2str(totalHours); 
            
            treatmentQuantityKg  = quantity/1000.0;
            treatmentHours       = 7 * 24;
            treatmentSteps       = treatmentHours;
           
            exponentialConstantDays = 0.01925408834889;
            exponentialConstantHrs  = exponentialConstantDays/24.0;
           
            wastedChemical         = treatmentQuantityKg * (feedWastePercentage / 100.0);
            consumedChemical       = treatmentQuantityKg - wastedChemical;
            hourlyWastedChemical   = wastedChemical / treatmentHours;
            hourlyExcretedChemical = consumedChemical * 0.1 / treatmentHours;

            IPF.data(1:treatmentSteps, 3) = hourlyWastedChemical;
            IPF.data(1:treatmentSteps, 6) = hourlyExcretedChemical;

            % How many steps do we need to fill up the excretion history from this
            % treatment up to the sampling date?
            expExcretionSteps = (1:(totalHours - treatmentSteps))';
           
            % Now calculate the excretion history for the treatment
            expExcretionProfile = (exponentialConstantHrs * 0.9 * consumedChemical * exp(-exponentialConstantHrs * (expExcretionSteps-1)));

            % Add to the main data table (only the the required number of
            % rows)
            IPF.data(treatmentSteps+1:totalHours, 6) = expExcretionProfile(expExcretionSteps)
            
            IPF.data(treatmentSteps+1:totalHours, 3) = 0.0;
        end
    end
    
end

