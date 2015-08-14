classdef DataTest < matlab.unittest.TestCase
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   DataTest.m  $
% $Revision:   1.2  $
% $Author:   ted.schlicke  $
% $Date:   May 28 2014 13:03:30  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % These tests test the AutoDepomod.Data package
    %
    
    properties
    end
    
    methods(TestMethodSetup)
        function setup(testCase)
        end
    end
    
    methods (Test)

        function testRootPath(testCase)
            actSolution = AutoDepomod.Data.root;
            expSolution = 'C:\SEPA Consent\DATA';
          
            verifyEqual(testCase, actSolution, expSolution);
        end
        
        function testNamespacedRootPath(testCase)
            actSolution = AutoDepomod.Data.root('test-string');
            expSolution = 'C:\SEPA Consent\DATA-test-string';
          
            verifyEqual(testCase, actSolution, expSolution);
        end
        
        function testNamespacePath(testCase)
            actSolution = AutoDepomod.Data.namespacePath('C:\SEPA Consent\DATA\Gorsten\depomod\resus\BENTHIC.log', 'test-string');
            expSolution = 'C:\SEPA Consent\DATA-test-string\Gorsten\depomod\resus\BENTHIC.log';
          
            verifyEqual(testCase, actSolution, expSolution);
        end

    end
    
    
end
