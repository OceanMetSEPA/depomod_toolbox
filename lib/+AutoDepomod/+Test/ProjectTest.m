classdef ProjectTest < matlab.unittest.TestCase
     properties
        Project;
        Path;
    end
    
    methods(TestMethodSetup)
        function setup(testCase)

            testDir = what('AutoDepomod\+Test');
            testCase.Path = [testDir.path,'\Fixtures\Gorsten'];
            
            testCase.Project = Depomod.Project.create(testCase.Path);
        end
    end
    
    methods (Test)
        
        % Instances

        function testName(testCase)
            actSolution = testCase.Project.name;
            expSolution = 'Gorsten';
          
            verifyEqual(testCase, actSolution, expSolution);
        end
        
        function testPath(testCase)
            actSolution = testCase.Project.path;
            expSolution = testCase.Path;
          
            verifyEqual(testCase, actSolution, expSolution);
        end
        
        function testVersion(testCase)
            actSolution = testCase.Project.version;
            expSolution = 1;
          
            verifyEqual(testCase, actSolution, expSolution);
        end
        
        function testDepomodPath(testCase)
            actSolution = testCase.Project.depomodPath;
            expSolution = [testCase.Path, '\depomod'];
          
            verifyEqual(testCase, actSolution, expSolution);
        end
        
        function testPartrackPath(testCase)
            actSolution = testCase.Project.partrackPath;
            expSolution = [testCase.Path, '\depomod\partrack'];
          
            verifyEqual(testCase, actSolution, expSolution);
        end
        
        function testResusPath(testCase)
            actSolution = testCase.Project.resusPath;
            expSolution = [testCase.Path, '\depomod\resus'];
          
            verifyEqual(testCase, actSolution, expSolution);
        end
        
        function testSolidsLogPath(testCase)
            actSolution = testCase.Project.logFilePath('S');
            expSolution = [testCase.Path, '\depomod\resus\Gorsten-BENTHIC.log'];
          
            verifyEqual(testCase, actSolution, expSolution);
        end
        
        function testEmBZLogPath(testCase)
            actSolution = testCase.Project.logFilePath('E');
            expSolution = [testCase.Path, '\depomod\resus\Gorsten-EMBZ.log'];
          
            verifyEqual(testCase, actSolution, expSolution);
        end
        
        function testTFBZLogPath(testCase)
            actSolution = testCase.Project.logFilePath('T');
            expSolution = [testCase.Path, '\depomod\resus\Gorsten-TFBZ.log'];
          
            verifyEqual(testCase, actSolution, expSolution);
        end
        
        function testCurrentFilePath(testCase)
            verifyEqual(testCase, testCase.Project.currentFilePath('s'), ...
                [testCase.Path, '\depomod\partrack\current-data\Gorsten-NS-s.dat']);
            verifyEqual(testCase, testCase.Project.currentFilePath('m'), ...
                [testCase.Path, '\depomod\partrack\current-data\Gorsten-NS-m.dat']);
            verifyEqual(testCase, testCase.Project.currentFilePath('b'), ...
                [testCase.Path, '\depomod\partrack\current-data\Gorsten-NS-b.dat']);
        end
        
        function testSNSCurrents(testCase)
            SNSCurrents = testCase.Project.SNSCurrents;
            
            verifyEqual(testCase, class(SNSCurrents), 'AutoDepomod.Currents.Profile');
            verifyEqual(testCase, SNSCurrents.isSNS, 1);
        end
        
        function testNSNCurrents(testCase)
            NSNCurrents = testCase.Project.NSNCurrents;
            
            verifyEqual(testCase, class(NSNCurrents), 'AutoDepomod.Currents.Profile');
            verifyEqual(testCase, NSNCurrents.isSNS, 0);
        end
        
        function testMeanSpeed(testCase)
             verifyEqual(testCase, testCase.Project.meanCurrentSpeed('s'), 0.1219752, 'AbsTol', 0.00001);
             verifyEqual(testCase, testCase.Project.meanCurrentSpeed('m'), 0.0585977, 'AbsTol', 0.00001);
             verifyEqual(testCase, testCase.Project.meanCurrentSpeed('b'), 0.0264588, 'AbsTol', 0.00001);
        end
        
        function testSolidsLog(testCase)
            solidsLog = testCase.Project.solidsLog;
            
            verifyInstanceOf(testCase, solidsLog, 'AutoDepomod.LogFile');
            verifyEqual(testCase, solidsLog.filePath, [testCase.Path, '\depomod\resus\Gorsten-BENTHIC.log']);
            verifyEqual(testCase, size(solidsLog.table), [8 36]);
        end
        
        function testEmBZLog(testCase)
            EmBZLog = testCase.Project.EmBZLog;
            
            verifyInstanceOf(testCase, EmBZLog,     'AutoDepomod.LogFile');
            verifyEqual(testCase, EmBZLog.filePath, [testCase.Path, '\depomod\resus\Gorsten-EMBZ.log']);
            verifyEqual(testCase, size(EmBZLog.table), [22 24]);
        end
        
        function testTFBZLog(testCase)
            TFBZLog = testCase.Project.TFBZLog;
            
            verifyInstanceOf(testCase, TFBZLog, 'AutoDepomod.LogFile');
            verifyEqual(testCase, TFBZLog.filePath, [testCase.Path, '\depomod\resus\Gorsten-TFBZ.log']);
            verifyEqual(testCase, size(TFBZLog.table), [16 24]);
        end
        
        function testGridgenIniPath(testCase)
            actSolution = testCase.Project.gridgenIniPath;
            expSolution = [testCase.Path, '\depomod\gridgen\Gorsten.ini'];
          
            verifyEqual(testCase, actSolution, expSolution);
        end
        
        function testDomainBounds(testCase)
            [minE, maxE, minN, maxN] = testCase.Project.domainBounds;
          
            verifyEqual(testCase, minE, 205700);
            verifyEqual(testCase, maxE, 206700);
            verifyEqual(testCase, minN, 770200);
            verifyEqual(testCase, maxN, 771200);
        end
        
        function testDomainSouthWest(testCase)
            [e,n] = testCase.Project.southWest;
          
            verifyEqual(testCase, e, 205700);
            verifyEqual(testCase, n, 770200);
        end
        
        function testDomainSouthEast(testCase)
            [e,n] = testCase.Project.southEast;
          
            verifyEqual(testCase, e, 206700);
            verifyEqual(testCase, n, 770200);
        end
        
        function testDomainNorthWest(testCase)
            [e,n] = testCase.Project.northWest;
          
            verifyEqual(testCase, e, 205700);
            verifyEqual(testCase, n, 771200);
        end
        
        function testDomainNorthEast(testCase)
            [e,n] = testCase.Project.northEast;
          
            verifyEqual(testCase, e, 206700);
            verifyEqual(testCase, n, 771200);
        end
        
        function testDomainCentre(testCase)
            [e,n] = testCase.Project.centre;
          
            verifyEqual(testCase, e, 205700 + (206700 - 205700)/2.0);
            verifyEqual(testCase, n, 770200 + (771200 - 770200)/2.0);
        end
        
        function testSolidsRuns(testCase)
            runs = testCase.Project.solidsRuns;
            
            verifyInstanceOf(testCase, runs,   'Depomod.Run.Collection');
            verifyEqual(testCase, runs.type,   'S');
            verifyEqual(testCase, runs.size,    2);
        end
        
        function testEmBZRuns(testCase)
            runs = testCase.Project.EmBZRuns;
            
            verifyInstanceOf(testCase, runs,   'Depomod.Run.Collection');
            verifyEqual(testCase, runs.type,   'E');
            verifyEqual(testCase, runs.size,    2);
        end
        
        function testTFBZRuns(testCase)
            runs = testCase.Project.TFBZRuns;
            
            verifyInstanceOf(testCase, runs,   'Depomod.Run.Collection');
            verifyEqual(testCase, runs.type,   'T');
            verifyEqual(testCase, runs.size,    2);
        end
%         
%         % Static methods
%         
%         function testFindSiteName(testCase)
%             path = testCase.Path;
%             
%             verifyEqual(testCase, AutoDepomod.Package.findSiteName(path), 'Gorsten')
%         end
% 
%         function testPath2RootPathLonger(testCase)
% 
%             actSolution = AutoDepomod.Package.path2RootPath(testCase.Package.resusPath);
%             expSolution = [testCase.Path];
% 
%             verifyEqual(testCase, actSolution,expSolution)
%         end
        
    end
    
end

