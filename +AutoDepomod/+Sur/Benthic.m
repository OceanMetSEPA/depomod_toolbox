classdef Benthic < AutoDepomod.Sur.Base
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   BenthicSur.m  $
% $Revision:   1.1  $
% $Author:   ted.schlicke  $
% $Date:   May 28 2014 13:03:54  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Wrapper class for Depomod .sur data files for benthic model runs. This class provides a
    % number of convenience methods for analysing .sur data and comparing two .sur files.
    %
    % 
    %
    % Usage:
    %
    %    sur = Depomod.Outputs.BenthicSur(path);
    %
    %  where path is the absolute path to the .sur file
    % 
    %
    % EXAMPLES:
    %
    %    sur = Depomod.Outputs.BenthicSur('C:\SEPA Consent\DATA\Gorsten\depomod\resus\Gorsten-BcnstFI-N-1g0.sur')
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
        rawDataValueCol = 'outCol1'; % column in the raw data that holds the flux data
    end
        
    methods      
        function BS = Benthic()
            BS = BS@AutoDepomod.Sur.Base();
        end     
    end    
    
end

