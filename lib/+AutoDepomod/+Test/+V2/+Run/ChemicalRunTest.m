classdef ChemicalRunTest < matlab.unittest.TestCase
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   ChemicalRunTest.m  $
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
            testCase.Path = [testDir.path,'\Fixtures\Basta Voe South'];
            testCase.Project = AutoDepomod.Project.create(testCase.Path);
            
            testCase.Run = AutoDepomod.V2.Run.EmBZ(testCase.Project, 'Basta Voe South-EMBZ-S-2-Model.properties');
        end
    end
    
    methods (Test)
        
        function testRunProject(testCase)
            verifyInstanceOf(testCase, testCase.Run.project, 'AutoDepomod.Project');
            verifyEqual(testCase, testCase.Run.project.name, 'Basta Voe South');
        end

        function testRunCfgFileName(testCase)
            verifyEqual(testCase, testCase.Run.cfgFileName, 'Basta Voe South-EMBZ-S-2-Model.properties');
        end

        function testRunNumber(testCase)
            verifyEqual(testCase, testCase.Run.runNumber, '2');
        end

        function testRunCfgFilePath(testCase)
            verifyEqual(testCase, testCase.Run.configPath, [testCase.Path, '\depomod\models\Basta Voe South-EMBZ-S-2-Model.properties']);
        end

        function testRunSurPath(testCase)
            verifyEqual(testCase, testCase.Run.surPath, [testCase.Path, '\depomod\intermediate\Basta Voe South-EMBZ-S-2-g0.sur']);
        end

        function testRunSur1Path(testCase)
            verifyEqual(testCase, testCase.Run.surPath(1), [testCase.Path, '\depomod\intermediate\Basta Voe South-EMBZ-S-2-g1.sur']);
        end
     
        function testRunIsBenthic(testCase)
            verifyFalse(testCase, testCase.Run.isBenthic);
        end
     
        function testRunIsEmBZ(testCase)
            verifyTrue(testCase, testCase.Run.isEmBZ);
        end
     
        function testRunIsTFBZ(testCase)
            verifyFalse(testCase, testCase.Run.isTFBZ);
        end
     
%         function testRunSur(testCase)
%             sur = testCase.Run.sur;
%             
%             verifyInstanceOf(testCase, sur, 'AutoDepomod.Sur.Residue');
%             verifyEqual(testCase, sur.path, [testCase.Path, '\depomod\intermediate\Basta Voe South-EMBZ-S-2-g0.sur']);
%             verifySize(testCase, sur.rawData.xCoords, [1521 1]); % ensure data pulled in successfully
%         end
     
%         function testRunLog(testCase)
%             l = testCase.Run.log;
%             
%             verifyInstanceOf(testCase, l, 'struct');
%             verifyEqual(testCase, l.RunNo, 20);
%             verifySize(testCase, fieldnames(l), [24 1]); % ensure data pulled in successfully
%             verifyEqual(testCase, l.Tide, 'S');  % ensure data pulled in successfully
%         end
%         
%         function testCages(testCase)
%             site = testCase.Run.cages;
%             
%             verifyEqual(testCase, class(site), 'AutoDepomod.Layout.Site');
%             verifyEqual(testCase, site.size, 1); 
%             verifyEqual(testCase, class(site.cageGroups{1}), 'AutoDepomod.Layout.Cage.Group');
%             verifyEqual(testCase, site.cageGroups{1}.size, 10); 
%         end
%         
%         function testRunConsentMass(testCase)
%             verifyEqual(testCase, testCase.Run.consentMass, 2406.25);
%         end
%         
%         function testRunMassBalance(testCase)
%             verifyEqual(testCase, testCase.Run.massBalance, 1707.04723510127);
%         end
%         
%         function testRunMassBalanceFraction(testCase)
%             verifyEqual(testCase, testCase.Run.massBalanceFraction, 1707.04723510127/2406.25);
%         end
%         
%         function testRunMassBalancePercent(testCase)
%             verifyEqual(testCase, testCase.Run.massBalancePercent, 1707.04723510127/2406.25*100.0);
%         end
%         
%         function testRunExport(testCase)
%             verifyEqual(testCase, testCase.Run.export, 2406.25*0.74 - 1707.04723510127);
%         end
%         
%         function testRunExportFraction(testCase)
%             verifyEqual(testCase, testCase.Run.exportFraction, (2406.25*0.74 - 1707.04723510127)/2406.25);
%         end
%         
%         function testRunExportPercent(testCase)
%             verifyEqual(testCase, testCase.Run.exportPercent, (2406.25*0.74 - 1707.04723510127)/2406.25*100);
%         end
%         
%         function testRunFarFieldImpactArea(testCase)
%             verifyEqual(testCase, testCase.Run.farFieldImpactArea, 224250 - 291.211233114154);
%         end
%         
%         function testRunFarFieldAZE(testCase)
%             verifyEqual(testCase, testCase.Run.AZE, 224250);
%         end
               
        
    end
    
    
end
