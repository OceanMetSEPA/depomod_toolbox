classdef CollectionTest < matlab.unittest.TestCase
    
    % These tests test the AutoDepomod.Project project
    %
    
    properties
        Project;
        Collection;
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

        function testFullCollectionIni(testCase)
            collection = Depomod.Run.Collection(testCase.Project);
          
            verifyEqual(testCase, collection.project.name, 'Gorsten');
            verifyEqual(testCase, collection.type, []);
            verifyEqual(testCase, class(collection.list{1}), 'AutoDepomod.Run.Solids');
            verifyEqual(testCase, class(collection.list{3}), 'AutoDepomod.Run.EmBZ');
            verifyEqual(testCase, class(collection.list{5}), 'AutoDepomod.Run.TFBZ');
            verifyEqual(testCase, size(collection.list, 1), 6);
        end
        
        function testSolidsCollectionIni(testCase)
            collection = Depomod.Run.Collection(testCase.Project, 'type', 'S');
          
            verifyEqual(testCase, collection.project.name, 'Gorsten');
            verifyEqual(testCase, collection.type, 'S');
            verifyEqual(testCase, class(collection.list{1}), 'AutoDepomod.Run.Solids');
            verifyEqual(testCase, size(collection.list, 1), 2);
        end
        
        function testEmBZCollectionIni(testCase)
            collection = Depomod.Run.Collection(testCase.Project, 'type', 'E');
          
            verifyEqual(testCase, collection.project.name, 'Gorsten');
            verifyEqual(testCase, collection.type, 'E');
            verifyEqual(testCase, class(collection.list{1}), 'AutoDepomod.Run.EmBZ');
            verifyEqual(testCase, size(collection.list, 1), 2);
        end
        
        function testTFBZCollectionIni(testCase)
            collection = Depomod.Run.Collection(testCase.Project, 'type', 'T');
          
            verifyEqual(testCase, collection.project.name, 'Gorsten');
            verifyEqual(testCase, collection.type, 'T');
            verifyEqual(testCase, class(collection.list{1}), 'AutoDepomod.Run.TFBZ');
            verifyEqual(testCase, size(collection.list, 1), 2);
        end
        
        function testCustomSizeMethod(testCase)
            collection = Depomod.Run.Collection(testCase.Project);
            verifyEqual(testCase, collection.size, 6);
        end
        
        function testGetByItem(testCase)
            collection = Depomod.Run.Collection(testCase.Project);
            benthicRun = collection.item(1);
            EmBZRun    = collection.item(3);
            
            verifyInstanceOf(testCase, benthicRun, 'AutoDepomod.Run.Solids');
            verifyEqual(testCase, benthicRun.runNumber, '1');
            
            verifyInstanceOf(testCase, EmBZRun, 'AutoDepomod.Run.EmBZ');
            verifyEqual(testCase, EmBZRun.runNumber, '20');
        end
        
        function testInvalidGetByItem(testCase)
            collection = Depomod.Run.Collection(testCase.Project);

            verifyError(testCase, @() collection.item(10), 'MATLAB:badsubscript');
        end
        
        function testGetByNumberFullCollection(testCase)
            collection = Depomod.Run.Collection(testCase.Project);
            run = collection.number(1);
                      
            % if 2 runs in this general collection have run number of 1,
            % the first (usually benthic) is returned
            verifyInstanceOf(testCase, run, 'AutoDepomod.Run.Solids');
            verifyEqual(testCase, run.runNumber, '1');
        end
        
        function testGetByNumberSolidsOnly(testCase)
            collection = Depomod.Run.Collection(testCase.Project, 'type', 'S');
            run = collection.number(1);

            
            verifyInstanceOf(testCase, run, 'AutoDepomod.Run.Solids');
            verifyEqual(testCase, run.runNumber, '1');
        end
        
        function testGetByNumberEmBZOnly(testCase)
            collection = Depomod.Run.Collection(testCase.Project, 'type', 'E');
            run = collection.number(21);
                        
                        
            verifyInstanceOf(testCase, run, 'AutoDepomod.Run.EmBZ');
            verifyEqual(testCase, run.runNumber, '21');
        end
        
        function testInvalidGetByNumber(testCase)
            collection = Depomod.Run.Collection(testCase.Project);
            run = collection.number(5);
                        
            verifyInstanceOf(testCase, run, 'cell');
            verifyTrue(testCase, isempty(run));
        end
        
        
    end
    
    
end
