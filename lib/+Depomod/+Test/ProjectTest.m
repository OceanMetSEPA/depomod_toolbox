classdef ProjectTest < matlab.unittest.TestCase
    properties
        AutoDepomodPath;
        NewDepomodPath;
        InvalidPath;
    end
    
    methods(TestMethodSetup)
        function setup(testCase)

            AutoDepomodTestDir = what('AutoDepomod\+Test');
            testCase.AutoDepomodPath = [AutoDepomodTestDir.path,'\Fixtures\Gorsten'];
            
            NewDepomodTestDir = what('NewDepomod\+Test');
            testCase.NewDepomodPath = [NewDepomodTestDir.path,'\Fixtures\Basta Voe South'];
            testCase.InvalidPath = NewDepomodTestDir.path;
            
        end
    end
    
    methods (Test)
        
        function testVersionClassMethodForAutoDepomod(testCase)
            actSolution = Depomod.Project.version(testCase.AutoDepomodPath);
            expSolution = 1;
          
            verifyEqual(testCase, actSolution, expSolution);
        end
        
        function testVersionClassMethodForNewDepomod(testCase)
            actSolution = Depomod.Project.version(testCase.NewDepomodPath);
            expSolution = 2;
          
            verifyEqual(testCase, actSolution, expSolution);
        end
        
        function testVersionClassMethodForInvalidPath(testCase)
            actSolution = Depomod.Project.version(testCase.InvalidPath);
            expSolution = [];
          
            verifyEqual(testCase, actSolution, expSolution);
        end
                
        function testCreateClassMethodForAutoDepomod(testCase)
            actSolution = class(Depomod.Project.create(testCase.AutoDepomodPath));
            expSolution = 'AutoDepomod.Project';
          
            verifyEqual(testCase, actSolution, expSolution);
        end
                
        function testCreateClassMethodForNewDepomod(testCase)
            actSolution = class(Depomod.Project.create(testCase.NewDepomodPath));
            expSolution = 'NewDepomod.Project';
          
            verifyEqual(testCase, actSolution, expSolution);
        end   
        
        function testCreateClassMethodForInvalidPath(testCase)            
            try
                Depomod.Project.create(testCase.InvalidPath);
                verifyTrue(testCase, false, 'No error raised.')
            catch Err
                verifyEqual(testCase, Err.identifier, 'Depomod:InvalidArgument')
            end
        end
    end


    
end