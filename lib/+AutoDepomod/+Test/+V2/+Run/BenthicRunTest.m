classdef BenthicRunTest < matlab.unittest.TestCase
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   BenthicRunTest.m  $
% $Revision:   1.2  $
% $Author:   ted.schlicke  $
% $Date:   May 28 2014 13:03:28  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % These tests test the AutoDepomod.Project package
    %
    
    properties
        Project;
        Run;
        Path;
    end
    
    methods(TestMethodSetup)
        function setup(testCase)

            testDir = what('AutoDepomod\+Test');
            testCase.Path = [testDir.path,'\Fixtures\Basta Voe South'];
            testCase.Project = AutoDepomod.Project.create(testCase.Path);
            
            testCase.Run = AutoDepomod.V2.Run.Benthic(testCase.Project, 'Basta Voe South-NONE-S-243-Model.properties');
        end
    end
    
    methods (Test)
        
        function testFileNameRunNumberParse(testCase)
            filePath = 'Basta Voe South-NONE-S-2-Model.properties'; % single digit
            verifyEqual(testCase, AutoDepomod.V2.Run.Base.parseRunNumber(filePath), '2');
            
            filePath = 'Basta Voe South-NONE-S-19-Model.properties'; % double digit
            verifyEqual(testCase, AutoDepomod.V2.Run.Base.parseRunNumber(filePath), '19');
            
            filePath = 'Basta Voe South-NONE-S-243-Model.properties'; % triple digit
            verifyEqual(testCase, AutoDepomod.V2.Run.Base.parseRunNumber(filePath), '243');
        end
        
        function testRunProject(testCase)
            verifyInstanceOf(testCase, testCase.Run.project, 'AutoDepomod.Project');
            verifyEqual(testCase, testCase.Run.project.name, 'Basta Voe South');
        end

        function testRunCfgFileName(testCase)
            verifyEqual(testCase, testCase.Run.cfgFileName, 'Basta Voe South-NONE-S-243-Model.properties');
        end

        function testRunNumber(testCase)
            verifyEqual(testCase, testCase.Run.runNumber, '243');
        end

        function testRunCfgFilePath(testCase)
            verifyEqual(testCase, testCase.Run.configPath, [testCase.Path, '\depomod\models\Basta Voe South-NONE-S-243-Model.properties']);
        end

        function testRunCfgFileRoot(testCase)
            verifyEqual(testCase, testCase.Run.configFileRoot, 'Basta Voe South-NONE-S-243');
        end

        function testRunSurPath(testCase)
            verifyEqual(testCase, testCase.Run.surPath, [testCase.Path, '\depomod\intermediate\Basta Voe South-NONE-S-243-g0.sur']);
        end

        function testRunSur1Path(testCase)
            verifyEqual(testCase, testCase.Run.surPath(1), [testCase.Path, '\depomod\intermediate\Basta Voe South-NONE-S-243-g1.sur']);
        end
     
        function testRunIsBenthic(testCase)
            verifyTrue(testCase, testCase.Run.isBenthic);
        end
     
        function testRunIsEmBZ(testCase)
            verifyFalse(testCase, testCase.Run.isEmBZ);
        end
     
        function testRunIsTFBZ(testCase)
            verifyFalse(testCase, testCase.Run.isTFBZ);
        end
     
        function testRunSur(testCase)
            sur = testCase.Run.sur;
            
            verifyInstanceOf(testCase, sur, 'AutoDepomod.Sur.Benthic');
            verifyEqual(testCase, sur.path, [testCase.Path, '\depomod\intermediate\Basta Voe South-NONE-S-243-g0.sur']);
            verifySize(testCase, sur.rawData.xCoords, [8836 1]); % ensure data pulled in successfully
        end
     
        function testRunLog(testCase)
            l = testCase.Run.log;
            
            verifyInstanceOf(testCase, l, 'struct');
            verifyEqual(testCase, l.RunNo, 1);
            verifySize(testCase, fieldnames(l), [36 1]); % ensure data pulled in successfully
            verifyEqual(testCase, l.BenthicSolids, 80);  % ensure data pulled in successfully
        end
        
        function testCages(testCase)
            site = testCase.Run.cages;
            
            verifyEqual(testCase, class(site), 'AutoDepomod.Layout.Site');
            verifyEqual(testCase, site.size, 1); 
            verifyEqual(testCase, class(site.cageGroups{1}), 'AutoDepomod.Layout.Cage.Group');
            verifyEqual(testCase, site.cageGroups{1}.size, 10); 
        end
               
    end
    
    
end
