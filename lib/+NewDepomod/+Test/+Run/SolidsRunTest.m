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

            testDir = what('NewDepomod\+Test');
            testCase.Path = [testDir.path,'\Fixtures\Basta Voe South'];
            testCase.Project = NewDepomod.Project.create(testCase.Path);
            
            testCase.Run = NewDepomod.Run.Solids(testCase.Project, 'Basta Voe South-NONE-S-243-Model.properties');
        end
    end
    
    methods (Test)
        
        function testFileNameRunNumberParse(testCase)
            filePath = 'Basta Voe South-NONE-S-2-Model.properties'; % single digit
            verifyEqual(testCase, NewDepomod.Run.Base.parseRunNumber(filePath), '2');
            
            filePath = 'Basta Voe South-NONE-S-19-Model.properties'; % double digit
            verifyEqual(testCase, NewDepomod.Run.Base.parseRunNumber(filePath), '19');
            
            filePath = 'Basta Voe South-NONE-S-243-Model.properties'; % triple digit
            verifyEqual(testCase, NewDepomod.Run.Base.parseRunNumber(filePath), '243');
        end
        
        function testRunProject(testCase)
            verifyInstanceOf(testCase, testCase.Run.project, 'NewDepomod.Project');
            verifyEqual(testCase, testCase.Run.project.name, 'Basta Voe South');
        end

        function testRunModelFileName(testCase)
            verifyEqual(testCase, testCase.Run.modelFileName, 'Basta Voe South-NONE-S-243-Model.properties');
        end

        function testRunNumber(testCase)
            verifyEqual(testCase, testCase.Run.runNumber, '243');
        end

        function testRunModelFilePath(testCase)
            verifyEqual(testCase, testCase.Run.modelPath, [testCase.Path, '\depomod\models\Basta Voe South-NONE-S-243-Model.properties']);
        end

        function testRunConfigFilePath(testCase)
            verifyEqual(testCase, testCase.Run.configPath, [testCase.Path, '\depomod\models\Basta Voe South-NONE-S-243-Configuration.properties']);
        end

        function testRunModelFileRoot(testCase)
            verifyEqual(testCase, testCase.Run.modelFileRoot, 'Basta Voe South-NONE-S-243');
        end

        function testRunSurPath(testCase)
            verifyEqual(testCase, testCase.Run.solidsSurPath, [testCase.Path, '\depomod\intermediate\Basta Voe South-NONE-S-243-g0.sur']);
        end

        function testRunSur1Path(testCase)
            verifyEqual(testCase, testCase.Run.surPath('solids',1), [testCase.Path, '\depomod\intermediate\Basta Voe South-NONE-S-243-solids-g1.sur']);
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
            verifyEqual(testCase, sur.path, [testCase.Path, '\depomod\intermediate\Basta Voe South-NONE-S-243-g0.sur']);
            verifySize(testCase, sur.rawData.xCoords, [8836 1]); % ensure data pulled in successfully
        end
     
%         function testRunLog(testCase)
%             l = testCase.Run.log;
%             
%             verifyInstanceOf(testCase, l, 'struct');
%             verifyEqual(testCase, l.RunNo, 1);
%             verifySize(testCase, fieldnames(l), [36 1]); % ensure data pulled in successfully
%             verifyEqual(testCase, l.BenthicSolids, 80);  % ensure data pulled in successfully
%         end
        
        function testCages(testCase)
            site = testCase.Run.cages;
            
            verifyEqual(testCase, class(site), 'Depomod.Layout.Site');
            verifyEqual(testCase, site.size, 1); 
            verifyEqual(testCase, class(site.cageGroups{1}), 'Depomod.Layout.Cage.Group');
            verifyEqual(testCase, site.cageGroups{1}.size, 10); 
        end
               
    end
    
    
end
