%% What?

% The template project contains sample bathymetry, cage and flow data and is
% initialised with a single solids run configured with a biomass of 1000 t
% and a single EmBZ run configured with a biomass of 1000 t and a treatment
% quantity of 350 g.
%
% In the general case this method can be used to create a new project after
% which the bathymetry, cage and flow files should be edited to reflect the
% required scenario and the initial run files edited to reflect the
% modelling starting point. Additional runs can then be added easily using
% this library.

%% Define name and location

% This is a reasonable default location, but it can be anywhere.
rootDir = 'C:\newdepomod_projects\';
% name of the project, will become the root directory name and prefix of
% all filenames
projectName = 'bay_of_fish';

if ~exist(rootDir, 'dir')
    mkdir(rootDir);
end

%% initialize project

% create from template with desired location and name
project = NewDepomod.Project.createFromTemplate(rootDir, projectName)
 
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

% Notice there includes 1 solids run and 1 EmBZ run

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

%%




















