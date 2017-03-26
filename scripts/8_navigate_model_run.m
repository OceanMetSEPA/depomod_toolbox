%% What?

% The Project object allows easy navigation of all of the runs in the
% project and with each run to navigate the various associated input and
% output files

%% Initialise a run object

% Let's assume we're working with the sample project 

projectDir = 'C:\newdepomod_projects\bay_of_fish';
project    = Depomod.Project.create(projectDir)

% Select the first solids run
solidsRun = project.solidsRuns.item(1)

% solidsRun = 
%   Solids with properties:
% 
%              defaultPlotLevels: [4 192 1553 10000]
%                    defaultUnit: 'g m^{-2} y^{-1}'
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

% Notice this references all of the input (e.g. cages, inputs, physical)
% files and all of the output files (sur(face), time series) which will be
% written when the mdoel is executed. So this object can be used to
% navigate all of the information related to a particular run.
%
% The pertinent properties on this run object are
%
%     physicalPropertiesFile: Properties file describing configuration of
%                             physical transport parameters
%
%          configurationFile: Properties file describing run configuration options
%
%                 inputsFile: Properties file describing feed inputs and
%                             particulate discharges
%
%                  modelFile: Properties file  run configuration options
%
%                      cages: Representation of the run cage definition
%
%                  solidsSur: Sur(face) file describing the distribution of
%                             organic solids predicted by the model
%
%                  carbonSur: Sur(face) file describing the distribution of
%                             organic carbon predicted by the model
%  
% consolidatedTimeSeriesFile: Time series file describing the daily total
%                             masses (solids, carbon) predicted within the model domain
%  
%     exportedTimeSeriesFile: Time series file describing the daily cumulative
%                             masses (solids, carbon) predicted to have left the model domain
%
%                        log: Properties file describing summary statistics
%                             about the completed model run (e.g. EQS info)
%
% The final 5 *only exist following the successful completion* of a model run.
% Each of these files can be examined programatically

%% Read the input files

% Check out the biomass and stocking density
solidsRun.inputsFile.FeedInputs.biomass
solidsRun.inputsFile.FeedInputs.stockingDensity

% ans =
% 1000
% ans =
% 13.0826

% And some of the physical properties
solidsRun.physicalPropertiesFile.Transports.bottomRoughnessLength.smooth
solidsRun.physicalPropertiesFile.Transports.resuspension.walker.dispersionCoefficientX

% ans =
% 0.00003
% ans =
% 0.1

% And some of the cage properties
solidsRun.cages.consolidatedCages.size       % count
solidsRun.cages.consolidatedCages.cageArea   % m2
solidsRun.cages.consolidatedCages.cageVolume % m3

% ans =
%      8
% ans =
%           6369.80278655024
% ans =
%           76437.6334386029    

%% Read the output files

% maximum flux (g m-2 y-1)
solidsRun.solidsSur.max 

% ans =
%       12637.622633

% area of 4 g m-2 y-1 contour
solidsRun.solidsSur.area(4) 
              
% ans =
%       639597.933953862

% get the value at a specific location
solidsRun.solidsSur.valueAt(351000,1068800)
              
              
%% Plot the run spatial impact

solidsRun.plot
              
%% Plot the in and out domain mass time series

solidsRun.consolidatedTimeSeriesFile.toTimeSeries(2).plot
solidsRun.exportedTimeSeriesFile.toTimeSeries(2).plot
              
              
              
              
              