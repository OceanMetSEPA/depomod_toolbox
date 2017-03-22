%% Define path

rootDir = 'C:\newdepomod_projects\3_consenting\4_invasion_bay';
projectName = 'invasion_bay_dzr';
projectPath = [rootDir, '\model\full_flow\', projectName];

%% initialize project

project = AutoDepomod.V2.Project.create(projectPath)

%% plot bathymetry

figure;
project.bathymetry.plot

project.bathymetry.adjustSeabedDepths(2)
project.bathymetry.smoothSeabed

%% Inspect run

run = project.benthicRuns.number(1)

run.inputsFile.FeedInputs.biomass
run.inputsFile.FeedInputs.stockingDensity

run.physicalPropertiesFile.Transports.bottomRoughnessLength.smooth
run.physicalPropertiesFile.Transports.resuspension.walker.dispersionCoefficientX

run.cages.consolidatedCages.size
run.cages.consolidatedCages.cageArea
run.cages.consolidatedCages.cageVolume

run.plotImpact

run.sur.area(4) % area at intensity level
run.sur.max     % max intensity level in domain
run.sur.volume  % corresponds to mass balance

%% Create new run

newRun = project.benthicRuns.new

% set biomass
newRun.inputsFile.setBiomass(4000);
% save to file
newRun.inputsFile.toFile;

% Adjust some parameters
newRun.physicalPropertiesFile.Transports.suspension.walker.dispersionCoefficientX = '0.2';
newRun.physicalPropertiesFile.Transports.suspension.walker.dispersionCoefficientY = '0.2';
newRun.physicalPropertiesFile.Transports.resuspension.walker.dispersionCoefficientX = '0.2';
newRun.physicalPropertiesFile.Transports.resuspension.walker.dispersionCoefficientY = '0.2';
% save to file
newRun.physicalPropertiesFile.toFile;

newRun.execute('modelDefaultsFilePath', newRun.physicalPropertiesPath); 


