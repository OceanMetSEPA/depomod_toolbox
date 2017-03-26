classdef EmBZRunTest < matlab.unittest.TestCase
    
    % These tests test the AutoDepomod.Project project
    %
    
    properties
        Project;
        Run;
        Path;
    end
    
    methods(TestMethodSetup)
        function setup(testCase)

            testDir = what('NewDepomod\+Test');
            testCase.Path = [testDir.path,'\Fixtures\Basta Voe South'];
            testCase.Project = NewDepomod.Project.create(testCase.Path);
            
            testCase.Run = NewDepomod.Run.EmBZ(testCase.Project, 'Basta Voe South-EMBZ-S-2-Model.properties');
        end
    end
    
    methods (Test)
        
        function testRunExportFactor(testCase)
            verifyEqual(testCase, testCase.Run.exportFactor, 0.74);
        end
        
        function testRunPrnPath(testCase)
            verifyEqual(testCase, testCase.Run.prnPath, [testCase.Path, '\depomod\intermediate\Basta Voe South-EMBZ-S-2-consolidated-g0.depomodtimeseries']);
        end
        
        function testRunPrnWithDecayPath(testCase)
            verifyEqual(testCase, testCase.Run.prnPath(1), [testCase.Path, '\depomod\intermediate\Basta Voe South-EMBZ-S-2-consolidated-g1.depomodtimeseries']);
        end
             
%         function testRunSurWithDecay(testCase)
%             sur = testCase.Run.surWithDecay;
%             
%             verifyInstanceOf(testCase, sur, 'Depomod.Sur.Residue');
%             verifyEqual(testCase, sur.path, [testCase.Path, '\depomod\resus\Gorsten-E-S-20g1.sur']);
%             verifySize(testCase, sur.rawData.xCoords, [1521 1]); % ensure data pulled in successfully
%         end
%      
%         function testRunPrnWithDecay(testCase)
%             prn = testCase.Run.prnWithDecay;
%             
%             verifyInstanceOf(testCase, prn, 'Depomod.TimeSeries');
%         end
               
    end
    
end
