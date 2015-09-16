classdef Residue < AutoDepomod.Sur.Base
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   ResidueSur.m  $
% $Revision:   1.1  $
% $Author:   ted.schlicke  $
% $Date:   May 28 2014 13:03:54  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
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
        rawDataValueCol = 'outCol2'; % column in the raw data holds the concentration data
    end
        
    methods      
        function RS = Residue()
            RS = RS@AutoDepomod.Sur.Base();
        end     
    end    
    
end
