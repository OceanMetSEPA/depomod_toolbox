classdef LayoutTest < matlab.unittest.TestCase
    
    properties
        Project;
        Run;
        Path;
        Site;
    end
    
    methods(TestMethodSetup)
        function setup(testCase)

            testDir       = what('AutoDepomod\+Test');
            testCase.Path = [testDir.path,'\Fixtures\Basta Voe South'];
            testCase.Project = AutoDepomod.Project.create(testCase.Path);
            
            
            testCase.Run = testCase.Project.benthicRuns.number(243);
            testCase.Site = AutoDepomod.Layout.Site.fromXMLFile(testCase.Run.cagesPath);
        end
    end
    
    methods (Test)
        
        function testSiteClass(testCase)
           verifyEqual(testCase, class(testCase.Site), 'AutoDepomod.Layout.Site'); 
        end
        
        function testSiteSize(testCase)
            verifyEqual(testCase, testCase.Site.size, 1); 
        end
        
        function testGroupClass(testCase)
            verifyEqual(testCase, class(testCase.Site.cageGroups{1}), 'AutoDepomod.Layout.Cage.Group'); 
        end
        
        function testGroupSize(testCase)
            verifyEqual(testCase, testCase.Site.cageGroups{1}.size, 10); 
        end
        
        function testGroupProperties(testCase)
            group = testCase.Site.cageGroups{1};
            
            verifyEqual(testCase, group.layoutType, 'REGULARGRID'); 
            verifyEqual(testCase, group.name,       'CageGroup1'); 
            verifyEqual(testCase, group.x,          453154.954536785); 
            verifyEqual(testCase, group.y,          1194667.33747754); 
            verifyEqual(testCase, group.xSpacing,   50.00000000169572); 
            verifyEqual(testCase, group.ySpacing,   50.00000000370977); 
            verifyEqual(testCase, group.Nx,         2); 
            verifyEqual(testCase, group.Ny,         5); 
            verifyEqual(testCase, group.length,     28.66); 
            verifyEqual(testCase, group.width,      28.66);
            verifyEqual(testCase, group.height,     10.0);
            verifyEqual(testCase, group.depth,      5.0);
            verifyEqual(testCase, group.bearing,    314.500000003841);
            verifyEqual(testCase, group.cageType,   'CIRCULAR');
        end
        
        function testCageClass(testCase)
            cageA = testCase.Site.cageGroups{1}.cages{1};
            cageB = testCase.Site.cageGroups{1}.cages{10};
            
            verifyEqual(testCase, class(cageA), 'AutoDepomod.Layout.Cage.Circle');
            verifyEqual(testCase, class(cageB), 'AutoDepomod.Layout.Cage.Circle'); 
        end
        
        function testCageProperties(testCase)
            cageA = testCase.Site.cageGroups{1}.cages{1};
            cageB = testCase.Site.cageGroups{1}.cages{10};
            
            verifyEqual(testCase, cageA.x,            453190.0); 
            verifyEqual(testCase, cageA.y,            1194703.0); 
            verifyEqual(testCase, cageA.length,       28.66); 
            verifyEqual(testCase, cageA.width,        28.66); 
            verifyEqual(testCase, cageA.height,       10.0); 
            verifyEqual(testCase, cageA.depth,        5.0); 
            verifyEqual(testCase, cageA.inputsId,     '08dc2070-a8da-4694-91a1-8f019839471a'); 
            verifyEqual(testCase, cageA.proportion,   0.1); 
            verifyEqual(testCase, cageA.inProduction, logical(1)); 
            
            verifyEqual(testCase, cageB.x,            453012.304446954); 
            verifyEqual(testCase, cageB.y,            1194807.5193304); 
            verifyEqual(testCase, cageB.length,       28.66); 
            verifyEqual(testCase, cageB.width,        28.66); 
            verifyEqual(testCase, cageB.height,       10); 
            verifyEqual(testCase, cageB.depth,        5); 
            verifyEqual(testCase, cageB.inputsId,     '08dc2070-a8da-4694-91a1-8f019839471a'); 
            verifyEqual(testCase, cageB.proportion,   0.1); 
            verifyEqual(testCase, cageB.inProduction, logical(1)); 
        end
        
        function testCageArea(testCase)
            verifyEqual(testCase,  testCase.Site.cageGroups{1}.cages{1}.area, pi*(28.66/2)^2); 
        end
        
        function testCageVolume(testCase)
            verifyEqual(testCase, testCase.Site.cageGroups{1}.cages{1}.volume, pi*(28.66/2)^2*10.0); 
        end
        
        function testGroupShorthand(testCase)
             verifyEqual(testCase, testCase.Site.cageGroups{1}, testCase.Site.group(1)); 
        end
        
        function testCageShorthand(testCase)
             verifyEqual(testCase, testCase.Site.cageGroups{1}.cages{1}, testCase.Site.group(1).cage(1)); 
        end
        
    end
    
end
