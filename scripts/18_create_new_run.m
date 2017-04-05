%% What?

% A new run can be created using the toolbox. This is premised on the runs
% being organised by number which is how AutoDepomod and the command-line
% NewDepomod models work, but is different from how the NewDepomod
% Graphical User Interface (GUI) works. The GUI works on the basis of run
% *names* or *labels* - with the concept that the cage layout is defined and
% named first and becomes the starting point for a specific run. In effect,
% the cage layout label becomes the label for a run. However, these labels 
% can, if chosen, take the form of a number and so the number based run system
% can be employed if the modeller chooses. When working with the depomod_toolbox
% this approach is prefereable and the only one currently supported.


%% Instantiate project

projectDir = 'C:\newdepomod_projects\bay_of_fish';
project    = Depomod.Project.create(projectDir)

%% Inspect the last run

% Let's just look at the last run in the project in order to demonstrate
% how this works

% Select the first solids run
lastSolidsRun = project.solidsRuns.last

% lastSolidsRun = 
%   Solids with properties:
% 
%              defaultPlotLevels: [4 192 1553 10000]
%                    defaultUnit: 'g m^{-2} y^{-1}'
%                      modelFile: [1x1 NewDepomod.PropertiesFile]
%         physicalPropertiesFile: [1x1 NewDepomod.PropertiesFile]
%              configurationFile: [1x1 NewDepomod.PropertiesFile]
%                     inputsFile: [1x1 NewDepomod.InputsPropertiesFile]
%            iterationInputsFile: [1x1 NewDepomod.InputsPropertiesFile]
%         exportedTimeSeriesFile: [1x1 NewDepomod.TimeSeriesFile]
%     consolidatedTimeSeriesFile: [1x1 NewDepomod.TimeSeriesFile]
%                      solidsSur: [1x1 Depomod.Sur.Solids]
%                      carbonSur: [1x1 Depomod.Sur.Solids]
%             iterationRunNumber: '1'
%                  modelFileName: [1x37 char]
%                        project: [1x1 NewDepomod.Project]
%                    cfgFileName: []
%                      runNumber: '1'
%                            log: [1x1 NewDepomod.PropertiesFile]
%                          cages: [2 Depomod.Layout.Site]

lastSolidsRun.runNumber

% ans =
% 1

lastSolidsRun.inputsFile.FeedInputs.biomass

% ans =
% 2500

% Okay, the last run was run #1 with a biomass of 2500 t

%% Create new run

newSolidsRun = project.solidsRuns.new

% newSolidsRun = 
%   Solids with properties:
% 
%              defaultPlotLevels: [4 192 1553 10000]
%                    defaultUnit: 'g m^{-2} y^{-1}'
%                      modelFile: [1x1 NewDepomod.PropertiesFile]
%         physicalPropertiesFile: [1x1 NewDepomod.PropertiesFile]
%              configurationFile: [1x1 NewDepomod.PropertiesFile]
%                     inputsFile: [1x1 NewDepomod.InputsPropertiesFile]
%            iterationInputsFile: []
%         exportedTimeSeriesFile: []
%     consolidatedTimeSeriesFile: []
%                      solidsSur: []
%                      carbonSur: []
%             iterationRunNumber: '2'
%                  modelFileName: [1x37 char]
%                        project: [1x1 NewDepomod.Project]
%                    cfgFileName: []
%                      runNumber: '2'
%                          cages: [2 Depomod.Layout.Site]
                     
newSolidsRun.runNumber

% ans =
% 2

newSolidsRun.inputsFile.FeedInputs.biomass

% ans =
% 2500

% The new run is a clone of the last run (according to run number) with the
% run number incremented and the results files cleared.
                         
%% Configure and execute the new run

% Now we can configure the run in whatever ways necessary and execute it,
% e.g.

% set biomass
newSolidsRun.inputsFile.setBiomass(4000);
% save to file
newSolidsRun.inputsFile.toFile;

% Adjust some parameters
newSolidsRun.physicalPropertiesFile.Transports.suspension.walker.dispersionCoefficientX = '0.2';
newSolidsRun.physicalPropertiesFile.Transports.suspension.walker.dispersionCoefficientY = '0.2';
newSolidsRun.physicalPropertiesFile.Transports.resuspension.walker.dispersionCoefficientX = '0.2';
newSolidsRun.physicalPropertiesFile.Transports.resuspension.walker.dispersionCoefficientY = '0.2';
% save to file
newSolidsRun.physicalPropertiesFile.toFile;


%%
