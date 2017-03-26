classdef ProjectTest < matlab.unittest.TestCase
     properties
        Project;
        Path;
    end
    
    methods(TestMethodSetup)
        function setup(testCase)

            testDir = what('NewDepomod\+Test');
            testCase.Path = [testDir.path,'\Fixtures\Basta Voe South'];
            
            testCase.Project = NewDepomod.Project.create(testCase.Path);
        end
    end
    
    methods (Test)
        
        % Instances

        function testProjectName(testCase)
            actSolution = testCase.Project.name;
            expSolution = 'Basta Voe South';
          
            verifyEqual(testCase, actSolution, expSolution);
        end
        
        function testProjectPath(testCase)
            actSolution = testCase.Project.path;
            expSolution = testCase.Path;
          
            verifyEqual(testCase, actSolution, expSolution);
        end
        
        function testProjectVersion(testCase)
            actSolution = testCase.Project.version;
            expSolution = 2;
          
            verifyEqual(testCase, actSolution, expSolution);
        end
        
        function testPackageDepomodPath(testCase)
            actSolution = testCase.Project.depomodPath;
            expSolution = [testCase.Path, '\depomod'];
          
            verifyEqual(testCase, actSolution, expSolution);
        end
        
        function testPackageModelsPath(testCase)
            actSolution = testCase.Project.modelsPath;
            expSolution = [testCase.Path, '\depomod\models'];
          
            verifyEqual(testCase, actSolution, expSolution);
        end
        
        function testPackageIntermediatePath(testCase)
            actSolution = testCase.Project.intermediatePath;
            expSolution = [testCase.Path, '\depomod\intermediate'];
          
            verifyEqual(testCase, actSolution, expSolution);
        end
        
        function testLocationPropertiesPath(testCase)
            actSolution = testCase.Project.locationPropertiesPath;
            expSolution = [testCase.Path, '\depomod\models\Basta Voe South-Location.properties'];
          
            verifyEqual(testCase, actSolution, expSolution);
        end
        
        function testCurrentFilePath(testCase)
            verifyEqual(testCase, testCase.Project.currentFilePath('s', 'S'), ...
                [testCase.Path, '\depomod\flowmetry\Basta Voe South-S-s.depomodflowmetryproperties']);
            verifyEqual(testCase, testCase.Project.currentFilePath('m', 'S'), ...
                [testCase.Path, '\depomod\flowmetry\Basta Voe South-S-m.depomodflowmetryproperties']);
            verifyEqual(testCase, testCase.Project.currentFilePath('b', 'S'), ...
                [testCase.Path, '\depomod\flowmetry\Basta Voe South-S-b.depomodflowmetryproperties']);
            verifyEqual(testCase, testCase.Project.currentFilePath('s', 'N'), ...
                [testCase.Path, '\depomod\flowmetry\Basta Voe South-N-s.depomodflowmetryproperties']);
            verifyEqual(testCase, testCase.Project.currentFilePath('m', 'N'), ...
                [testCase.Path, '\depomod\flowmetry\Basta Voe South-N-m.depomodflowmetryproperties']);
            verifyEqual(testCase, testCase.Project.currentFilePath('b', 'N'), ...
                [testCase.Path, '\depomod\flowmetry\Basta Voe South-N-b.depomodflowmetryproperties']);
        end
        
        function testCurrentFilePathCaseInsensitive(testCase)
            % Alter case of arguments
            verifyEqual(testCase, testCase.Project.currentFilePath('S', 's'), ...
                [testCase.Path, '\depomod\flowmetry\Basta Voe South-S-s.depomodflowmetryproperties']);
            verifyEqual(testCase, testCase.Project.currentFilePath('m', 'S'), ...
                [testCase.Path, '\depomod\flowmetry\Basta Voe South-S-m.depomodflowmetryproperties']);
            verifyEqual(testCase, testCase.Project.currentFilePath('B', 'S'), ...
                [testCase.Path, '\depomod\flowmetry\Basta Voe South-S-b.depomodflowmetryproperties']);
            verifyEqual(testCase, testCase.Project.currentFilePath('s', 'n'), ...
                [testCase.Path, '\depomod\flowmetry\Basta Voe South-N-s.depomodflowmetryproperties']);
            verifyEqual(testCase, testCase.Project.currentFilePath('m', 'N'), ...
                [testCase.Path, '\depomod\flowmetry\Basta Voe South-N-m.depomodflowmetryproperties']);
            verifyEqual(testCase, testCase.Project.currentFilePath('b', 'n'), ...
                [testCase.Path, '\depomod\flowmetry\Basta Voe South-N-b.depomodflowmetryproperties']);
        end
        
        function testSNSCurrents(testCase)
            SNSCurrents = testCase.Project.SNSCurrents;
            
            verifyEqual(testCase, class(SNSCurrents), 'NewDepomod.Currents.Profile');
            verifyEqual(testCase, SNSCurrents.isSNS, 1);
        end
        
        function testNSNCurrents(testCase)
            NSNCurrents = testCase.Project.NSNCurrents;
            
            verifyEqual(testCase, class(NSNCurrents), 'NewDepomod.Currents.Profile');
            verifyEqual(testCase, NSNCurrents.isSNS, 0);
        end
        
        function testMeanSpeed(testCase)
             verifyEqual(testCase, testCase.Project.meanCurrentSpeed('s'), 0.0358177, 'AbsTol', 0.00001);
             verifyEqual(testCase, testCase.Project.meanCurrentSpeed('m'), 0.0332619, 'AbsTol', 0.00001);
             verifyEqual(testCase, testCase.Project.meanCurrentSpeed('b'), 0.0497949, 'AbsTol', 0.00001);
        end
        
        function testGridgenIniPath(testCase)
            actSolution = testCase.Project.gridgenIniPath;
            expSolution = [testCase.Path, '\depomod\bathymetry\Basta Voe South.depomodbathymetrygridgenini'];
          
            verifyEqual(testCase, actSolution, expSolution);
        end
        
        function testDomainBounds(testCase)
            [minE, maxE, minN, maxN] = testCase.Project.domainBounds;
          
            verifyEqual(testCase, minE, 452700);
            verifyEqual(testCase, maxE, 453700);
            verifyEqual(testCase, minN, 1194300);
            verifyEqual(testCase, maxN, 1195300);
        end
        
        function testDomainSouthWest(testCase)
            [e,n] = testCase.Project.southWest;
          
            verifyEqual(testCase, e, 452700);
            verifyEqual(testCase, n, 1194300);
        end
        
        function testDomainSouthEast(testCase)
            [e,n] = testCase.Project.southEast;
          
            verifyEqual(testCase, e, 453700);
            verifyEqual(testCase, n, 1194300);
        end
        
        function testDomainNorthWest(testCase)
            [e,n] = testCase.Project.northWest;
          
            verifyEqual(testCase, e, 452700);
            verifyEqual(testCase, n, 1195300);
        end
        
        function testDomainNorthEast(testCase)
            [e,n] = testCase.Project.northEast;
          
            verifyEqual(testCase, e, 453700);
            verifyEqual(testCase, n, 1195300);
        end
        
        function testDomainCentre(testCase)
            [e,n] = testCase.Project.centre;
          
            verifyEqual(testCase, e, 452700 + (453700 - 452700)/2.0);
            verifyEqual(testCase, n, 1194300 + (1195300 - 1194300)/2.0);
        end
        
        function testSolidsRuns(testCase)
            runs = testCase.Project.solidsRuns;
            
            verifyInstanceOf(testCase, runs,   'Depomod.Run.Collection');
            verifyEqual(testCase, runs.type,   'S');
            verifyEqual(testCase, runs.size,    1);
        end
        
        function testEmBZRuns(testCase)
            runs = testCase.Project.EmBZRuns;
            
            verifyInstanceOf(testCase, runs,   'Depomod.Run.Collection');
            verifyEqual(testCase, runs.type,   'E');
            verifyEqual(testCase, runs.size,    1);
        end
        
        function testTFBZRuns(testCase)
            runs = testCase.Project.TFBZRuns;
            
            verifyInstanceOf(testCase, runs,   'Depomod.Run.Collection');
            verifyEqual(testCase, runs.type,   'T');
            verifyEqual(testCase, runs.size,    0);
        end
        
        
    end
end
