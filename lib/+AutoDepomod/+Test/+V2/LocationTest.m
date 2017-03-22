classdef LocationTest < matlab.unittest.TestCase
     properties
        Path;
    end
    
    methods(TestMethodSetup)
        function setup(testCase)

            testDir = what('AutoDepomod\+Test');
            testCase.Path = [testDir.path,...
                '\Fixtures\Basta Voe South\depomod\models\Basta Voe South-Location.properties'];
        end
    end
    
    methods (Test)
        
        % Instances

        function testFromFileClassMethod(testCase)
            loc = AutoDepomod.V2.PropertiesFile(testCase.Path);
          
            verifyEqual(testCase, loc.ant.directory, './depomod/ant');
            verifyEqual(testCase, loc.bathymetry.data.dat.extension, 'depomodbathymetrygridgendata');
            verifyEqual(testCase, loc.bathymetry.data.directory, './depomod/bathymetry');
            verifyEqual(testCase, loc.bathymetry.data.ing.extension, 'depomodbathymetrygridgening');
            verifyEqual(testCase, loc.bathymetry.data.ini.extension, 'depomodbathymetrygridgenini');
            verifyEqual(testCase, loc.bathymetry.data.type, 'GRIDGEN');
            verifyEqual(testCase, loc.cages.data.directory, './depomod/cages');
            verifyEqual(testCase, loc.cages.data.extension, 'xml');
            verifyEqual(testCase, loc.cages.data.type, 'XML');
            verifyEqual(testCase, loc.component.name.separator, '-');
            verifyEqual(testCase, loc.flowmetry.data.cal.extension, 'depomodflowmetrysepacal');
            verifyEqual(testCase, loc.flowmetry.data.dat.extension, 'depomodflowmetrysepadata');
            verifyEqual(testCase, loc.flowmetry.data.directory, './depomod/flowmetry');
            verifyEqual(testCase, loc.flowmetry.data.propertiesBased.extension, 'depomodflowmetryproperties');
            verifyEqual(testCase, loc.flowmetry.data.type, 'DEPOMODFLOWMETRYPROPERTIESBASEDDATA');
            verifyEqual(testCase, loc.inputs.data.directory, './depomod/inputs');
            verifyEqual(testCase, loc.inputs.data.endOfDataMarker, 'endOfDataMarker');
            verifyEqual(testCase, loc.inputs.data.properties.extension, 'depomodinputsproperties');
            verifyEqual(testCase, loc.inputs.data.startOfDataMarker, 'startOfDataMarker');
            verifyEqual(testCase, loc.inputs.data.type, 'PROPERTIESBASED');
            verifyEqual(testCase, loc.intermediate.directory, './depomod/intermediate');
            verifyEqual(testCase, loc.logs.directory, './depomod/intermediate');
            verifyEqual(testCase, loc.logs.iteration.extension, 'log');
            verifyEqual(testCase, loc.logs.runtime.extension, 'xml');
            verifyEqual(testCase, loc.models.directory, './depomod/models');
            verifyEqual(testCase, loc.particles.data.directory, './depomod/particles');
            verifyEqual(testCase, loc.particles.data.type, './depomod/particles');
            verifyEqual(testCase, loc.private.directory, './depomod/private');
            verifyEqual(testCase, loc.project.directory, 'C\:\\SEPA Consent\\DATA-new-model-consenting\\Basta Voe South');
            verifyEqual(testCase, loc.project.format, 'depomod');
            verifyEqual(testCase, loc.project.name, 'Basta Voe South');
            verifyEqual(testCase, loc.results.data.directory, './depomod/results');
            verifyEqual(testCase, loc.results.data.prn.extension, 'depomodresultsprn');
            verifyEqual(testCase, loc.results.data.sur.extension, 'depomodresultssur');
            verifyEqual(testCase, loc.working.directory, './depomod/working');
        end
    end
    
end

