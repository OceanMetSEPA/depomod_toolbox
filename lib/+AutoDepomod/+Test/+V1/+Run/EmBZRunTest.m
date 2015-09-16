classdef EmBZRunTest < matlab.unittest.TestCase
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   EmBZRunTest.m  $
% $Revision:   1.2  $
% $Author:   ted.schlicke  $
% $Date:   May 28 2014 13:03:30  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % These tests test the AutoDepomod.Project project
    %
    
    properties
        Project;
        Run;
        Path;
    end
    
    methods(TestMethodSetup)
        function setup(testCase)

            testDir = what('AutoDepomod\+Test');
            testCase.Path = [testDir.path,'\Fixtures\Gorsten'];
            testCase.Project = AutoDepomod.Project.create(testCase.Path);
            
            testCase.Run = AutoDepomod.V1.Run.EmBZ(testCase.Project, 'Gorsten-E-S-20.cfg');
        end
    end
    
    methods (Test)
        
        function testRunExportFactor(testCase)
            verifyEqual(testCase, testCase.Run.exportFactor, 0.74);
        end
        
        function testRunPrnPath(testCase)
            verifyEqual(testCase, testCase.Run.prnPath, [testCase.Path, '\depomod\resus\Gorsten-E-S-20g0.prn']);
        end
        
        function testRunPrnWithDecayPath(testCase)
            verifyEqual(testCase, testCase.Run.prnPath(1), [testCase.Path, '\depomod\resus\Gorsten-E-S-20g1.prn']);
        end
        
        function testRunDuration(testCase)
            verifyEqual(testCase, testCase.Run.duration, 118);
        end
     
        function testRunSurWithDecay(testCase)
            sur = testCase.Run.surWithDecay;
            
            verifyInstanceOf(testCase, sur, 'AutoDepomod.Sur.Residue');
            verifyEqual(testCase, sur.path, [testCase.Path, '\depomod\resus\Gorsten-E-S-20g1.sur']);
            verifySize(testCase, sur.rawData.xCoords, [1521 1]); % ensure data pulled in successfully
        end
     
        function testRunPrnWithDecay(testCase)
            prn = testCase.Run.prnWithDecay;
            
            verifyInstanceOf(testCase, prn, 'AutoDepomod.PrnSeries');
            verifyEqual(testCase, prn.path, [testCase.Path, '\depomod\resus\Gorsten-E-S-20g1.prn']);
        end
               
    end
    
end
