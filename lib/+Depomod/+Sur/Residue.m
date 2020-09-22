classdef Residue < Depomod.Sur.Base
    % Wrapper class for Depomod .sur data files for medicine model runs. This class provides a
    % number of convenience methods for analysing .sur data and comparing two .sur files.
    %
    % 
    %
    % Usage:
    %
    %    sur = Depomod.Outputs.ResidueSur(path);
    %
    %  where path is the absolute path to the .sur file
    % 
    %
    % EXAMPLES:
    %
    %    sur = Depomod.Outputs.ResidueSur('C:\SEPA Consent\DATA\Gorsten\depomod\resus\Gorsten-E-N-1g1.sur')
    %    sur.max()
    %    sur.area(0.763)
    %    sur.volume(0.763)
    %    sur.averageConcentration(0.763)
    %    sur.plot()
    %    sur.contourPlot(0.763)
    %
    % DEPENDENCIES:
    %
    %  - Depomod/Outputs/Sur.m
    % 
         
    properties
        rawDataValueCol   = 'outCol2'; % column in the raw data holds the concentration data
        defaultPlotLevels = [0.00604, 0.01175 0.763]; % Updated to reflect wet/dry density calculation change
        % They correspond to:
        % 0.00604 µg/kg : wet weight (new EQS, equivalent to 12ng/kg dry weight)
        % 0.01175 µg/kg : new UKTag EQS (23.5ng/kg) converted from dry to wet weight
        % 0.763 µg/kg   : old EQS
        % defaultUnit       = 'µg kg^{-1}';
        defaultUnit=sprintf('%cg kg^{-1}',181); % mu symbol gets corrupted by itself for some reason. 181 is ascii value for µ
    end
        
    methods      
        function RS = Residue()
            RS = RS@Depomod.Sur.Base();
        end     
    end    
    
end
