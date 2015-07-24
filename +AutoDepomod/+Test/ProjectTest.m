classdef ProjectTest < matlab.unittest.TestCase
    properties
        V1Path;
        V2Path;
        InvalidPath;
    end
    
    methods(TestMethodSetup)
        function setup(testCase)

            testDir = what('AutoDepomod\+Test');
            testCase.V1Path = [testDir.path,'\Fixtures\Gorsten'];
            testCase.V2Path = [testDir.path,'\Fixtures\Basta Voe South'];
            testCase.InvalidPath = testDir.path;
            
        end
    end
    
    methods (Test)
        
        function testVersionClassMethodForV1(testCase)
            actSolution = AutoDepomod.Project.version(testCase.V1Path);
            expSolution = 1;
          
            verifyEqual(testCase, actSolution, expSolution);
        end
        
        function testVersionClassMethodForV2(testCase)
            actSolution = AutoDepomod.Project.version(testCase.V2Path);
            expSolution = 2;
          
            verifyEqual(testCase, actSolution, expSolution);
        end
        
        function testVersionClassMethodForInvalidPath(testCase)
            actSolution = AutoDepomod.Project.version(testCase.InvalidPath);
            expSolution = [];
          
            verifyEqual(testCase, actSolution, expSolution);
        end
                
        function testCreateClassMethodForV1(testCase)
            actSolution = class(AutoDepomod.Project.create(testCase.V1Path));
            expSolution = 'AutoDepomod.V1.Project';
          
            verifyEqual(testCase, actSolution, expSolution);
        end
                
        function testCreateClassMethodForV2(testCase)
            actSolution = class(AutoDepomod.Project.create(testCase.V2Path));
            expSolution = 'AutoDepomod.V2.Project';
          
            verifyEqual(testCase, actSolution, expSolution);
        end   
        
        function testCreateClassMethodForInvalidPath(testCase)            
            try
                AutoDepomod.Project.create(testCase.InvalidPath);
                verifyTrue(testCase, false, 'No error raised.')
            catch Err
                verifyEqual(testCase, Err.identifier, 'AutoDepomod:InvalidArgument')
            end
        end
    end


    
end