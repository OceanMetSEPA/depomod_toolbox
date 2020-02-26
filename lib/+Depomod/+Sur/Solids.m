classdef Solids < Depomod.Sur.Base
    
    % Wrapper class for Depomod .sur data files for benthic model runs. This class provides a
    % number of convenience methods for analysing .sur data and comparing two .sur files.
    %
    % 
    %
   
         
    properties
        rawDataValueCol   = 'outCol1'; % column in the raw data that holds the flux data
        %defaultPlotLevels = [4,192,1553,10000];
        defaultPlotLevels = [1,250,1000]; % Defaults for new standards (20200226)
        defaultUnit       = 'g m^{-2}';
    end
        
    methods      
        function SS = Solids()
            SS = SS@Depomod.Sur.Base();
        end     
    end    
    
end

