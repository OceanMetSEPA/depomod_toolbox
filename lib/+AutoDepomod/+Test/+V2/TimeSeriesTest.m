classdef TimeSeriesTest < matlab.unittest.TestCase
     properties
        Path;
    end
    
    methods(TestMethodSetup)
        function setup(testCase)

            testDir = what('AutoDepomod\+Test');
            testCase.Path = [testDir.path,'\Fixtures\Basta Voe South\depomod\flowmetry\Basta Voe South-S-s.depomodflowmetryproperties'];
        end
    end
    
    methods (Test)
        
        % Instances

        function testBasicConstructor(testCase)
            timeSeries = AutoDepomod.V2.Currents.TimeSeries([],[],[]);
          
            verifyEqual(testCase, class(timeSeries), 'AutoDepomod.V2.Currents.TimeSeries');
            verifyEqual(testCase, timeSeries.Time,       []);
            verifyEqual(testCase, timeSeries.Speed,      []);
            verifyEqual(testCase, timeSeries.Direction,  []);
            verifyEqual(testCase, timeSeries.u,          []);
            verifyEqual(testCase, timeSeries.v,          []);
            verifyEqual(testCase, timeSeries.MeterDepth, []);
            verifyEqual(testCase, timeSeries.SiteDepth,  []);
            verifyEqual(testCase, timeSeries.DeltaT,     []);
            verifyEqual(testCase, timeSeries.NumberOfTimeSteps, []);
            verifyEqual(testCase, timeSeries.SiteTide, []);
            verifyEqual(testCase, timeSeries.LengthUnitSIConversionFactor, 1);
            verifyEqual(testCase, timeSeries.TimeUnitSIConversionFactor,   1);
            verifyEqual(testCase, timeSeries.isSNS, []);
        end
        
        function testBasicConstructorWithArgs(testCase)
            timeSeries = AutoDepomod.V2.Currents.TimeSeries([],[],[], ...
                'MeterDepth', 20.5, ...
                'isSNS',       1 ...
            );
          
            verifyEqual(testCase, class(timeSeries), 'AutoDepomod.V2.Currents.TimeSeries');
            verifyEqual(testCase, timeSeries.Time,       []);
            verifyEqual(testCase, timeSeries.Speed,      []);
            verifyEqual(testCase, timeSeries.Direction,  []);
            verifyEqual(testCase, timeSeries.u,          []);
            verifyEqual(testCase, timeSeries.v,          []);
            verifyEqual(testCase, timeSeries.MeterDepth, 20.5);
            verifyEqual(testCase, timeSeries.SiteDepth,  []);
            verifyEqual(testCase, timeSeries.DeltaT,     []);
            verifyEqual(testCase, timeSeries.NumberOfTimeSteps, []);
            verifyEqual(testCase, timeSeries.SiteTide, []);
            verifyEqual(testCase, timeSeries.LengthUnitSIConversionFactor, 1);
            verifyEqual(testCase, timeSeries.TimeUnitSIConversionFactor,   1);
            verifyEqual(testCase, timeSeries.isSNS, 1);
        end
        
        function testFileConstructor(testCase)
            timeSeries = AutoDepomod.V2.Currents.TimeSeries.fromFile(testCase.Path);
          
            verifyEqual(testCase, class(timeSeries), 'AutoDepomod.V2.Currents.TimeSeries');
            verifyEqual(testCase, length(timeSeries.Time),       360);
            verifyEqual(testCase, length(timeSeries.Speed),      360);
            verifyEqual(testCase, length(timeSeries.Direction),  360);
            verifyEqual(testCase, length(timeSeries.u),          360);
            verifyEqual(testCase, length(timeSeries.v),          360);
            
            verifyEqual(testCase, timeSeries.Time(1),               0,  'AbsTol', 0.0001);
            verifyEqual(testCase, timeSeries.Speed(1),       0.018099,  'AbsTol', 0.0001);
            verifyEqual(testCase, timeSeries.Direction(1),      276.81, 'AbsTol', 0.0001);
            verifyEqual(testCase, timeSeries.u(1),          -0.0179723, 'AbsTol', 0.0001);
            verifyEqual(testCase, timeSeries.v(1),          0.00214625, 'AbsTol', 0.0001);
            
            verifyEqual(testCase, timeSeries.MeterDepth,           -5);
            verifyEqual(testCase, timeSeries.SiteDepth,         -22.3);
            verifyEqual(testCase, timeSeries.DeltaT,             3600);
            verifyEqual(testCase, timeSeries.NumberOfTimeSteps,   360);
            verifyEqual(testCase, timeSeries.SiteTide,            1.5);
            verifyEqual(testCase, timeSeries.LengthUnitSIConversionFactor, 1);
            verifyEqual(testCase, timeSeries.TimeUnitSIConversionFactor,   1);
            verifyEqual(testCase, timeSeries.isSNS, 1);
        end
        
        function testTimeIndexes(testCase)
            timeSeries = AutoDepomod.V2.Currents.TimeSeries.fromFile(testCase.Path);
            timeIndexes = timeSeries.timeIndexes;
            
            verifyEqual(testCase, length(timeIndexes), 360);
            verifyEqual(testCase, timeIndexes(1), 1);
            verifyEqual(testCase, timeIndexes(end), 360);
            verifyEqual(testCase, unique(diff(timeIndexes)), 1); % test all diffs = 1
        end
        
        function testTimeInContext(testCase)
            timeSeries = AutoDepomod.V2.Currents.TimeSeries.fromFile(testCase.Path);
            times      = timeSeries.contextualiseTime(719529);
            
            verifyEqual(testCase, length(times), 360);
            verifyEqual(testCase, times(1), 719529);
            verifyEqual(testCase, times(end), 719529 + 15 - (1/24));
        end
        
        function testToRCMNoArg(testCase)
            timeSeries    = AutoDepomod.V2.Currents.TimeSeries.fromFile(testCase.Path);
            RCMTimeSeries = timeSeries.toRCMTimeSeries;
            
            verifyEqual(testCase, class(RCMTimeSeries), 'RCM.Current.TimeSeries');
            
            verifyEqual(testCase, RCMTimeSeries.length, 360);
            verifyEqual(testCase, RCMTimeSeries.Time(1), 719529);
            verifyEqual(testCase, RCMTimeSeries.Time(end), 719529 + 15 - (1/24));
            
            verifyEqual(testCase, RCMTimeSeries.Speed(1),       0.018099, 'AbsTol', 0.0001);
            verifyEqual(testCase, RCMTimeSeries.Direction(1),     276.81, 'AbsTol', 0.0001);
            verifyEqual(testCase, RCMTimeSeries.u(1),         -0.0179723, 'AbsTol', 0.0001);
            verifyEqual(testCase, RCMTimeSeries.v(1),         0.00214625, 'AbsTol', 0.0001);
            
            verifyEqual(testCase, RCMTimeSeries.HeightAboveBed,  17.3, 'AbsTol', 0.0001);
        end
        
        function testToRCMWithArg(testCase)
            timeSeries    = AutoDepomod.V2.Currents.TimeSeries.fromFile(testCase.Path);
            RCMTimeSeries = timeSeries.toRCMTimeSeries('startTime', 736119);
            
            verifyEqual(testCase, class(RCMTimeSeries), 'RCM.Current.TimeSeries');
            
            verifyEqual(testCase, RCMTimeSeries.length, 360);
            verifyEqual(testCase, RCMTimeSeries.Time(1), 736119);
            verifyEqual(testCase, RCMTimeSeries.Time(end), 736119 + 15 - (1/24));
            
            verifyEqual(testCase, RCMTimeSeries.Speed(1),       0.018099, 'AbsTol', 0.0001);
            verifyEqual(testCase, RCMTimeSeries.Direction(1),     276.81, 'AbsTol', 0.0001);
            verifyEqual(testCase, RCMTimeSeries.u(1),         -0.0179723, 'AbsTol', 0.0001);
            verifyEqual(testCase, RCMTimeSeries.v(1),         0.00214625, 'AbsTol', 0.0001);
            
            verifyEqual(testCase, RCMTimeSeries.HeightAboveBed,  17.3, 'AbsTol', 0.0001);
        end
        
        function testMean(testCase)
            timeSeries    = AutoDepomod.V2.Currents.TimeSeries.fromFile(testCase.Path);
            verifyEqual(testCase, timeSeries.meanSpeed, 0.035817, 'AbsTol', 0.00001)
        end
    end
    
end

