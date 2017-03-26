classdef ProfileTest < matlab.unittest.TestCase
     properties
        SurfacePath;
        MiddlePath;
        BottomPath;
    end
    
    methods(TestMethodSetup)
        function setup(testCase)

            testDir = what('AutoDepomod\+Test');
            testCase.SurfacePath = [testDir.path,'\Fixtures\Gorsten\depomod\partrack\current-data\Gorsten-NS-s.dat'];
            testCase.MiddlePath  = [testDir.path,'\Fixtures\Gorsten\depomod\partrack\current-data\Gorsten-NS-m.dat'];
            testCase.BottomPath  = [testDir.path,'\Fixtures\Gorsten\depomod\partrack\current-data\Gorsten-NS-b.dat'];
        end
    end
    
    methods (Test)
        
        function testBasicConstructor(testCase)
            profile = AutoDepomod.Currents.Profile();
          
            verifyEqual(testCase, class(profile),         'AutoDepomod.Currents.Profile');
            verifyEqual(testCase, class(profile.s), 'AutoDepomod.Currents.TimeSeries');
            verifyEqual(testCase, class(profile.m),  'AutoDepomod.Currents.TimeSeries');
            verifyEqual(testCase, class(profile.b),  'AutoDepomod.Currents.TimeSeries');
            verifyEqual(testCase, profile.isSNS,   0);
        end    
    
        function testFileConstructorSNS(testCase)
            profile = AutoDepomod.Currents.Profile.fromFile(testCase.SurfacePath, testCase.MiddlePath, testCase.BottomPath);
          
            verifyEqual(testCase, class(profile), 'AutoDepomod.Currents.Profile');
            verifyEqual(testCase, class(profile.s), 'AutoDepomod.Currents.TimeSeries');
            verifyEqual(testCase, class(profile.m),  'AutoDepomod.Currents.TimeSeries');
            verifyEqual(testCase, class(profile.b),  'AutoDepomod.Currents.TimeSeries');
            verifyEqual(testCase, profile.isSNS,   1);
        end  
        
        function testFileConstructorNSN(testCase)
            [~,profile] = AutoDepomod.Currents.Profile.fromFile(testCase.SurfacePath, testCase.MiddlePath, testCase.BottomPath);
          
            verifyEqual(testCase, class(profile), 'AutoDepomod.Currents.Profile');
            verifyEqual(testCase, class(profile.s), 'AutoDepomod.Currents.TimeSeries');
            verifyEqual(testCase, class(profile.m),  'AutoDepomod.Currents.TimeSeries');
            verifyEqual(testCase, class(profile.b),  'AutoDepomod.Currents.TimeSeries');
            verifyEqual(testCase, profile.isSNS,   0);
        end  
    
        function testLength(testCase)
            profile = AutoDepomod.Currents.Profile.fromFile(testCase.SurfacePath, testCase.MiddlePath, testCase.BottomPath);
          
            verifyEqual(testCase, profile.length, 360);
        end
         
        function testRCMProfile(testCase)
            profile = AutoDepomod.Currents.Profile.fromFile(testCase.SurfacePath, testCase.MiddlePath, testCase.BottomPath);
            RCMProfile = profile.toRCMProfile;
            
            verifyEqual(testCase, class(RCMProfile), 'RCM.Current.Profile');
            
            verifyEqual(testCase, RCMProfile.size, 3);
            verifyEqual(testCase, RCMProfile.WaterDepth, 27.19, 'AbsTol', 0.01);
        end
        
        function testScaleSpeed(testCase)
            profile = AutoDepomod.Currents.Profile.fromFile(testCase.SurfacePath, testCase.MiddlePath, testCase.BottomPath);
            
            verifyEqual(testCase, class(profile),   'AutoDepomod.Currents.Profile');
            verifyEqual(testCase, class(profile.s), 'AutoDepomod.Currents.TimeSeries');
            verifyEqual(testCase, class(profile.m), 'AutoDepomod.Currents.TimeSeries');
            verifyEqual(testCase, class(profile.b), 'AutoDepomod.Currents.TimeSeries');
            
            verifyEqual(testCase, profile.s.Speed(1), 0.4671, 'AbsTol', 0.00001);
            verifyEqual(testCase, profile.m.Speed(1), 0.1749, 'AbsTol', 0.00001);
            verifyEqual(testCase, profile.b.Speed(1), 0.0392, 'AbsTol', 0.00001);
            
            profile.scaleSpeed(2);
            
            verifyEqual(testCase, class(profile),   'AutoDepomod.Currents.Profile');
            verifyEqual(testCase, class(profile.s), 'AutoDepomod.Currents.TimeSeries');
            verifyEqual(testCase, class(profile.m), 'AutoDepomod.Currents.TimeSeries');
            verifyEqual(testCase, class(profile.b), 'AutoDepomod.Currents.TimeSeries');
            
            verifyEqual(testCase, profile.s.Speed(1), 0.9342, 'AbsTol', 0.00001);
            verifyEqual(testCase, profile.m.Speed(1), 0.3498, 'AbsTol', 0.00001);
            verifyEqual(testCase, profile.b.Speed(1), 0.0784, 'AbsTol', 0.00001);
        end
    end
end