%% What?

% Existing projects represent directories of files on the file system which
% conform to the expected NewDepomod structure. The file structure is roughly
% as follows
%
%   - \bathymetry
%       - bay_of_fish.depomodbathymetryproperties 
%           (domain/bathymetry/land data)
%
%   - \cages
%       - bay_of_fish-NONE-1.depomodcagesxml
%       - bay_of_fish-NONE-2.depomodcagesxml
%       - bay_of_fish-EMBZ-1.depomodcagesxml
%       - bay_of_fish-EMBZ-2.depomodcagesxml
%       - etc...
%           (cage definitions for every run)
%
%   - \flowmetry
%       - bay_of_fish.depomodflowmetryproperties
%           (flow data)
%
%   - \inputs
%       - bay_of_fish-NONE-1-allCages.depomodinputsproperties
%       - bay_of_fish-NONE-2-allCages.depomodinputsproperties
%       - bay_of_fish-EMBZ-1-allCages.depomodinputsproperties
%       - bay_of_fish-EMBZ-2-allCages.depomodinputsproperties
%       - etc...
%           (discharge definitions for every run (feed inputs, etc.))
%
%   - \intermediate
%       - bay_of_fish-NONE-1.depomodcagesxml
%       - bay_of_fish-NONE-1.depomodrunlog
%       - bay_of_fish-EMBZ-1-carbon-g0.sur
%       - bay_of_fish-EMBZ-1-carbon-g1.sur
%       - bay_of_fish-EMBZ-2-consolidated-g1.depomodtimeseries
%       - bay_of_fish-EMBZ-2-exported-g1.depomodtimeseries
%       - etc...
%           (results files for every run (surface, time series, summary log, etc.); only
%            exist following successful run completion)
%
% - \models
%       - bay_of_fish-NONE-1-Configuration.properties
%       - bay_of_fish-NONE-1-Model.properties
%       - bay_of_fish-NONE-1.depomodphysicalproperties
%       - bay_of_fish-Location.properties
%       - bay_of_fish-EMBZ-1-Configuration.properties
%       - bay_of_fish-EMBZ-1-Model.properties
%       - bay_of_fish-EMBZ-1.depomodphysicalproperties
%       - etc...
%           (set up definitions for every run)
%
%   - \results
%       - bay_of_fish-NONE-1.depomodrunlog
%       - bay_of_fish-EMBZ-1-carbon-g0.sur
%       - bay_of_fish-EMBZ-1-carbon-g1.sur
%       - etc...
%           (results files for optimised runs; only exist following successful run 
%            completion)
%

% Such packages can be represented by NewDepomod.Project objects in order to 
% aid the navigation and manipulation of the project files. This alow files
% to be accessed without explicitly handling their filenames or paths - to
% code understands where each file resides.

%% Define location of existing NewDepomod package

projectDir = 'C:\newdepomod_projects\bay_of_fish';

%% Initialise NewDepomod.Project

project = Depomod.Project.create(projectDir)

% project = 
%   Project with properties:
% 
%         version: 2
%        location: [1x1 NewDepomod.PropertiesFile]
%      bathymetry: [1x1 NewDepomod.BathymetryFile]
%            name: 'bay_of_fish'
%            path: [1x34 char]
%      solidsRuns: [1 Depomod.Run.Collection]
%        EmBZRuns: [1 Depomod.Run.Collection]
%        TFBZRuns: [0 Depomod.Run.Collection]
%     SNSCurrents: [1x1 NewDepomod.Currents.Profile]
%     NSNCurrents: [1x1 NewDepomod.Currents.Profile]

% This object is the MATLAB representation of the NewDepomod project file
% structure. The project object understands all of the file relations and
% therefore can be used to navigate the files in the project, edit and save
% them, and ultimately to execute the model

%% Access project properties

% We can easily access properties of the project by calling them

project.name

% ans =
% bay_of_fish

project.path

% ans =
% C:\newdepomod_projects\bay_of_fish

project.parentPath

% ans =
% C:\newdepomod_projects

project.EmBZRuns.size

% ans =
%      1

project.flowmetryPath

% ans =
% C:\newdepomod_projects\bay_of_fish\depomod\flowmetry

project.bathymetry

% ans = 
%   BathymetryFile with properties:
% 
%     GridgenBathymetryFile: []
%         GridgenDomainFile: []
%                      data: [79x79 double]
%                      path: [1x93 char]
%         startOfDataMarker: 'startOfDataMarker'
%                    Domain: [1x1 struct]
%           endOfDataMarker: 'endOfDataMarker'
          
project.EmBZRuns  

% ans = 
%   Collection with properties:
% 
%     project: [1x1 NewDepomod.Project]
%        type: 'E'
%        list: {[1x1 NewDepomod.Run.EmBZ]}


project.EmBZRuns.number(1)

%   EmBZ with properties:
% 
%                   exportFactor: 0.74
%              defaultPlotLevels: [0.1 0.763 2 10 25]
%                    defaultUnit: 'ug kg^{-1}'
%                    chemicalSur: []
%                      modelFile: [1x1 NewDepomod.PropertiesFile]
%         physicalPropertiesFile: [1x1 NewDepomod.PropertiesFile]
%              configurationFile: [1x1 NewDepomod.PropertiesFile]
%                     inputsFile: [1x1 NewDepomod.InputsPropertiesFile]
%            iterationInputsFile: []
%         exportedTimeSeriesFile: []
%     consolidatedTimeSeriesFile: []
%                      solidsSur: []
%                      carbonSur: []
%             iterationRunNumber: '1'
%                  modelFileName: [1x37 char]
%                        project: [1x1 NewDepomod.Project]
%                    cfgFileName: []
%                      runNumber: '1'
%                          cages: [2 Depomod.Layout.Site]

% Notice this last output represents a single run (EmBZ run #1). It has
% several input files but no output files as it has not be executed yet.
%%