classdef ITITest < matlab.unittest.TestCase
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   ITITest.m  $
% $Revision:   1.2  $
% $Author:   ted.schlicke  $
% $Date:   May 28 2014 13:03:44  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % These tests test the AutoDepomod.ITI package
    %
    
    properties
    end
    
    methods(TestMethodSetup)
        function setup(testCase)
        end
    end
    
    methods (Test)

        % Standard flux -> ITI mapping at far-field compliance flux
        function testFromFluxFarField(testCase)
            actSolution = AutoDepomod.ITI.fromFlux(191.8);
            expSolution = 30; % from HGAnalysis spreadsheet
          
            verifyEqual(testCase, actSolution, expSolution, 'AbsTol', 0.1);
        end
        
        % Standard flux -> ITI mapping at near field optimization flux
        function testFromFluxNearField(testCase)
            actSolution = AutoDepomod.ITI.fromFlux(1561);
            expSolution = 10; % from HGAnalysis spreadsheet
          
            verifyEqual(testCase, actSolution, expSolution, 'AbsTol', 0.1);
        end
        
        % Flux at the upper bound (10e5) of the peicewise linear fit domain (10e5) should
        % translate to a minimum, ITI = 1.
        function testFromFluxUpperBound(testCase)
            actSolution = AutoDepomod.ITI.fromFlux(10000);
            expSolution = 1; 
          
            verifyEqual(testCase, actSolution, expSolution, 'AbsTol', 0.1);
        end
        
        % Flux outside the piecewise linear domain. Large values (10e5 -> Inf) should
        % translate to a minimum, ITI = 1.
        function testFromFluxAboveDomain(testCase)
            actSolution = AutoDepomod.ITI.fromFlux(10000000);
            expSolution = 1; 
          
            verifyEqual(testCase, actSolution, expSolution, 'AbsTol', 0.1);
        end
        
        % Flux outside the piecewise linear domain. Negative values should
        % be undefined.
        function testFromFluxBelowDomain(testCase)
            actSolution = AutoDepomod.ITI.fromFlux(-1);
            expSolution = NaN; 
          
            verifyEqual(testCase, actSolution, expSolution, 'AbsTol', 0.1);
        end
        
        % Flux at the lower bound (0) of the peicewise linear fit domain (10e5) should
        % translate to ITI = 59.
        function testFromFluxLowerBound(testCase)
            actSolution = AutoDepomod.ITI.fromFlux(0);
            expSolution = 59; 
          
            verifyEqual(testCase, actSolution, expSolution, 'AbsTol', 0.1);
        end
        
        % Standard ITI -> flux mapping at far field compliance flux
        function testToFluxFarField(testCase)
            actSolution = AutoDepomod.ITI.toFlux(30);
            expSolution = 191.8; % from HGAnalysis spreadsheet
          
            verifyEqual(testCase, actSolution, expSolution, 'AbsTol', 1);
        end
        
        % Standard ITI -> flux mapping at near field optimization flux
        function testToFluxNearField(testCase)
            actSolution = AutoDepomod.ITI.toFlux(10);
            expSolution = 1561; % from HGAnalysis spreadsheet
          
            verifyEqual(testCase, actSolution, expSolution, 'AbsTol', 10);
        end
        
        % ITI -> flux is underfined for ITI > 59, so just assume 0
        function testToFluxAboveDomain(testCase)
            actSolution = AutoDepomod.ITI.toFlux(60);
            expSolution = 0; 
          
            verifyEqual(testCase, actSolution, expSolution, 'AbsTol', 1);
        end
        
        % Lower flux domain bound, ITI = 59 -> flux = 0
        function testToFluxUpperBound(testCase)
            actSolution = AutoDepomod.ITI.toFlux(59);
            expSolution = 0; 
          
            verifyEqual(testCase, actSolution, expSolution, 'AbsTol', 1);
        end
        
        % Upper flux bound, domain only defined for ITI > 1, so just assume
        % 10000
        function testToFluxLowerBound(testCase)
            actSolution = AutoDepomod.ITI.toFlux(1);
            expSolution = 10000; 
          
            verifyEqual(testCase, actSolution, expSolution, 'AbsTol', 1);
        end
        
        
        

    end
    
    
end
