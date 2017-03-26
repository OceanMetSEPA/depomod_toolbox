%% What?

% Using the command line tool, a run can be executed programmatically. The code expects 
% the command line package to be installed in the following location
%
%   - C:\newDEPOMOD
%
% with the scripts and Java executables in these subdirectories
%
%   - C:\newDEPOMOD\scripts
%
%   - C:\newDEPOMOD\java
%
% In the future this can be reworked so that any install location can be
% used and configured within the toolbox.

%% Instantiate run

% Instantiate project by passing in root directory path
projectDir = 'C:\newdepomod_projects\bay_of_fish';
project = Depomod.Project.create(projectDir)

% get the run
solidsRun = project.solidsRuns.item(1);

%% Execute run

solidsRun.execute('modelDefaultsFilePath', solidsRun.physicalPropertiesPath); 

% This opens a windows terminal and executes the appropriate command. For a
% 365 day solids run this may take between 10-20 minutes and a couple of
% hours.
%
% The 'modelDefaultsFilePath' refers to the physical properties file for
% the run. This is optional as the underlying model does not require this.
% If it is missing the model applies default values. The command line model
% requires this file to be specified and passed in to the terminal command.
% The toolbox behaviour around this could be improved so that this is
% passed into the command line model without explicitly referencing it
% here.
%

% The command which is executed in the terminal can be returned by passing
% in the 'commandStringOnly' = true (1) option, like thus,

command = solidsRun.execute(...
    'modelDefaultsFilePath', solidsRun.physicalPropertiesPath, ...
    'commandStringOnly', 1 ...
); 

% In this case, no windows terminal is opened and the output of the function
% - assigned to the 'command' variable here - is a string describing the respective
% terminal command for executing the model run. This can be pasted into a terminally 
% manually. Repeated command outputs like this can also be joined together (using " & ")
% and written to a batch file for executing in series.
%
% In this case the command looks like this

disp(command)

% C:\newDEPOMOD\scripts\RunModel.bat ...
%   /dataPath "C:\newdepomod_projects" ...
%   /siteName "bay_of_fish" ...
%   /modelParametersFile "bay_of_fish-NONE-N-1-Model.properties" ...
%   /modelLocationFile "bay_of_fish-Location.properties" ...
%   /modelConfigurationFile "bay_of_fish-NONE-N-1-Configuration.properties" ...
%   /modelDefaultsFilePath "C:\newdepomod_projects\bay_of_fish\depomod\models\bay_of_fish-NONE-N-1.depomodphysicalproperties" ...
%   /verbose ...
%   /singleRunOnly
%
% (This has been purposely split into separate lines to aid readability)
%

%%




