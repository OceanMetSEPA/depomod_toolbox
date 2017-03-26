classdef SolidsRunTest < matlab.unittest.TestCase
    
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
            testCase.Path = [testDir.path,'\Fixtures\Gorsten'];
            testCase.Project = Depomod.Project.create(testCase.Path);
            
            testCase.Run = AutoDepomod.Run.Solids(testCase.Project, 'Gorsten-BcnstFI-N-1.cfg');
        end
    end
    
    methods (Test)
        
        function testFileNameRunNumberParse(testCase)
            filePath = 'Gorsten-BcnstFI-N-2.cfg'; % single digit
            verifyEqual(testCase, AutoDepomod.Run.Base.parseRunNumber(filePath), '2');
            
            filePath = 'Gorsten-BcnstFI-N-19.cfg'; % double digit
            verifyEqual(testCase, AutoDepomod.Run.Base.parseRunNumber(filePath), '19');
            
            filePath = 'Gorsten-BcnstFI-N-109.cfg'; % triple digit
            verifyEqual(testCase, AutoDepomod.Run.Base.parseRunNumber(filePath), '109');
        end
        
        function testRunProject(testCase)
            verifyInstanceOf(testCase, testCase.Run.project, 'AutoDepomod.Project');
            verifyEqual(testCase, testCase.Run.project.name, 'Gorsten');
        end

        function testRunCfgFileName(testCase)
            verifyEqual(testCase, testCase.Run.cfgFileName, 'Gorsten-BcnstFI-N-1.cfg');
        end

        function testRunNumber(testCase)
            verifyEqual(testCase, testCase.Run.runNumber, '1');
        end

        function testRunCfgFilePath(testCase)
            verifyEqual(testCase, testCase.Run.configPath, [testCase.Path, '\depomod\partrack\Gorsten-BcnstFI-N-1.cfg']);
        end

        function testRunSurPath(testCase)
            verifyEqual(testCase, testCase.Run.surPath, [testCase.Path, '\depomod\resus\Gorsten-BcnstFI-N-1g0.sur']);
        end

        function testRunSur1Path(testCase)
            verifyEqual(testCase, testCase.Run.surPath(1), [testCase.Path, '\depomod\resus\Gorsten-BcnstFI-N-1g1.sur']);
        end
     
        function testRunIsSolids(testCase)
            verifyTrue(testCase, testCase.Run.isSolids);
        end
     
        function testRunIsEmBZ(testCase)
            verifyFalse(testCase, testCase.Run.isEmBZ);
        end
     
        function testRunIsTFBZ(testCase)
            verifyFalse(testCase, testCase.Run.isTFBZ);
        end
     
        function testRunSur(testCase)
            sur = testCase.Run.sur;
            
            verifyInstanceOf(testCase, sur, 'Depomod.Sur.Solids');
            verifyEqual(testCase, sur.path, [testCase.Path, '\depomod\resus\Gorsten-BcnstFI-N-1g0.sur']);
            verifySize(testCase, sur.rawData.xCoords, [1521 1]); % ensure data pulled in successfully
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
            
            verifyEqual(testCase, class(site), 'Depomod.Layout.Site');
            verifyEqual(testCase, site.size, 1); 
            verifyEqual(testCase, class(site.cageGroups{1}), 'Depomod.Layout.Cage.Group');
            verifyEqual(testCase, site.cageGroups{1}.size, 24); 
        end
               
        
    end
    
    
end
