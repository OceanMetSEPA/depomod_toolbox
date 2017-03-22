classdef LayoutTest < matlab.unittest.TestCase
    
    properties
        Project;
        Run;
        Path;
        Site;
    end
    
    methods(TestMethodSetup)
        function setup(testCase)
            testDir = what('AutoDepomod\+Test');
            testCase.Path = [testDir.path,'\Fixtures\Gorsten'];
            testCase.Project = AutoDepomod.Project.create(testCase.Path);
            
            testCase.Run = testCase.Project.benthicRuns.number(1);
            testCase.Site = AutoDepomod.Layout.Site.fromCSV(testCase.Run.cagesPath);
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
            verifyEqual(testCase, testCase.Site.cageGroups{1}.size, 24); 
        end
        
        function testGroupProperties(testCase)
            group = testCase.Site.cageGroups{1};
            verifyEqual(testCase, group.layoutType, ''); 
            verifyEqual(testCase, group.name,       ''); 
            verifyEqual(testCase, group.x,          []); 
            verifyEqual(testCase, group.y,          []); 
            verifyEqual(testCase, group.xSpacing,   []); 
            verifyEqual(testCase, group.ySpacing,   []); 
            verifyEqual(testCase, group.Nx,         []); 
            verifyEqual(testCase, group.Ny,         []); 
            verifyEqual(testCase, group.length,     []); 
            verifyEqual(testCase, group.width,      []);
            verifyEqual(testCase, group.height,     []);
            verifyEqual(testCase, group.depth,      []);
            verifyEqual(testCase, group.bearing,    []);
            verifyEqual(testCase, group.cageType,   '');
        end
        
        function testCageClass(testCase)
            cageA = testCase.Site.cageGroups{1}.cages{1};
            cageB = testCase.Site.cageGroups{1}.cages{20};
            
            verifyEqual(testCase, class(cageA), 'AutoDepomod.Layout.Cage.Square');
            verifyEqual(testCase, class(cageB), 'AutoDepomod.Layout.Cage.Square'); 
        end
        
        function testCageProperties(testCase)
            cageA = testCase.Site.cageGroups{1}.cages{1};
            cageB = testCase.Site.cageGroups{1}.cages{20};
            
            verifyEqual(testCase, cageA.x,            206307); 
            verifyEqual(testCase, cageA.y,            770893); 
            verifyEqual(testCase, cageA.length,       24); 
            verifyEqual(testCase, cageA.width,        24); 
            verifyEqual(testCase, cageA.height,       12); 
            verifyEqual(testCase, cageA.depth,        []); 
            verifyEqual(testCase, cageA.inputsId,     ''); 
            verifyEqual(testCase, cageA.proportion,   []); 
            verifyEqual(testCase, cageA.inProduction, logical([])); 
            
            verifyEqual(testCase, cageB.x,            206105.043362586); 
            verifyEqual(testCase, cageB.y,            770661.206260632); 
            verifyEqual(testCase, cageB.length,       24); 
            verifyEqual(testCase, cageB.width,        24); 
            verifyEqual(testCase, cageB.height,       12); 
            verifyEqual(testCase, cageB.depth,        []); 
            verifyEqual(testCase, cageB.inputsId,     ''); 
            verifyEqual(testCase, cageB.proportion,   []); 
            verifyEqual(testCase, cageB.inProduction, logical([])); 
        end
        
        function testCageArea(testCase)
            verifyEqual(testCase,  testCase.Site.cageGroups{1}.cages{1}.area, 24*24); 
        end
        
        function testCageVolume(testCase)
            verifyEqual(testCase, testCase.Site.cageGroups{1}.cages{1}.volume, 24*24*12); 
        end
        
        function testGroupShorthand(testCase)
             verifyEqual(testCase, testCase.Site.cageGroups{1}, testCase.Site.group(1)); 
        end
        
        function testCageShorthand(testCase)
             verifyEqual(testCase, testCase.Site.cageGroups{1}.cages{1}, testCase.Site.group(1).cage(1)); 
        end
    end
    
end

