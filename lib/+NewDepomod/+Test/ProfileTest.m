classdef ProfileTest < matlab.unittest.TestCase
     properties
        SurfacePath;
        MiddlePath;
        BottomPath;
    end
    
    methods(TestMethodSetup)
        function setup(testCase)

            testDir = what('NewDepomod\+Test');
            testCase.SurfacePath = [testDir.path,'\Fixtures\Basta Voe South\depomod\flowmetry\Basta Voe South-S-s.depomodflowmetryproperties'];
            testCase.MiddlePath  = [testDir.path,'\Fixtures\Basta Voe South\depomod\flowmetry\Basta Voe South-S-m.depomodflowmetryproperties'];
            testCase.BottomPath  = [testDir.path,'\Fixtures\Basta Voe South\depomod\flowmetry\Basta Voe South-S-b.depomodflowmetryproperties'];
        end
    end
    
    methods (Test)
        
        function testBasicConstructor(testCase)
            profile = NewDepomod.Currents.Profile();
          
            verifyEqual(testCase, class(profile),   'NewDepomod.Currents.Profile');
            verifyEqual(testCase, class(profile.s), 'NewDepomod.Currents.TimeSeries');
            verifyEqual(testCase, class(profile.m), 'NewDepomod.Currents.TimeSeries');
            verifyEqual(testCase, class(profile.b), 'NewDepomod.Currents.TimeSeries');
            verifyEqual(testCase, profile.isSNS,   0);
        end    
    
        function testFileConstructor(testCase)
            profile = NewDepomod.Currents.Profile.fromFile(testCase.SurfacePath, testCase.MiddlePath, testCase.BottomPath);
          
            verifyEqual(testCase, class(profile),   'NewDepomod.Currents.Profile');
            verifyEqual(testCase, class(profile.s), 'NewDepomod.Currents.TimeSeries');
            verifyEqual(testCase, class(profile.m), 'NewDepomod.Currents.TimeSeries');
            verifyEqual(testCase, class(profile.b), 'NewDepomod.Currents.TimeSeries');
            verifyEqual(testCase, profile.isSNS,   1);
        end  
        
        function testLength(testCase)
            profile = NewDepomod.Currents.Profile.fromFile(testCase.SurfacePath, testCase.MiddlePath, testCase.BottomPath);
          
            verifyEqual(testCase, profile.length, 360);
        end
         
        function testRCMProfile(testCase)
            profile = NewDepomod.Currents.Profile.fromFile(testCase.SurfacePath, testCase.MiddlePath, testCase.BottomPath);
            RCMProfile = profile.toRCMProfile;
            
            verifyEqual(testCase, class(RCMProfile), 'RCM.Current.Profile');
            
            verifyEqual(testCase, RCMProfile.size, 3);
            verifyEqual(testCase, RCMProfile.WaterDepth, 22.3, 'AbsTol', 0.01);
        end
        
    end
end