%% What?

% The NewDepomod bathymetry file(s) *defines* the model domain. 
% The file is located with the \bathymetry folder of the project, is named 
% after the project name and has a file extension .depomodbathymetryproperties.
%
% The file is the Java Properties format and includes a CSV-style data table at
% the end containing the cell-by-cell bathymetry data.
%
% Specifically, the information in the files includes:
%
%       - the domain bounds (OSGB easting/northing)
%       - the grid resolution (i.e. number of grid cells in x and y 
%         dimensions)
%       - data grid of water depth values for each cell (i.e. the
%         bathymetry)
%
% The data grid is negative downwards and values of 10 denote land.

% The NewDepomod.BathymetryFile object in the depomod_toolbox can be used to read, 
% view, edit and save the bathymetry information and data. %

%% Instantiate bathymetry file as part of existing project

% If you have a whole project set up then the bathymetry file can be
% instantiated in MATLAB by taking advantage of the navigation provided by
% the NewDepomod.Project class, without needing file paths etc.

% Instantiate project by passing in root directory path
projectDir = 'C:\newdepomod_projects\bay_of_fish';
project = Depomod.Project.create(projectDir)


% then the bathymetry file can be found here:
bathy = project.bathymetry

% bathy = 
%   BathymetryFile with properties:
% 
%     GridgenBathymetryFile: []
%         GridgenDomainFile: []
%                      data: [79x79 double]
%                      path: [1x93 char]
%                    Domain: [1x1 struct]
%         startOfDataMarker: 'startOfDataMarker'
%           endOfDataMarker: 'endOfDataMarker'

%% Instantiate the bathymetry file directly

% Alternatively, a bathymetry file can be instantiated directly by using
% the direct file path, e.g.

bathy = NewDepomod.BathymetryFile('C:\newdepomod_projects\bay_of_fish\depomod\bathymetry\bay_of_fish.depomodbathymetryproperties')

% bathy = 
%   BathymetryFile with properties:
% 
%     GridgenBathymetryFile: []
%         GridgenDomainFile: []
%                      data: [79x79 double]
%                      path: [1x93 char]
%         startOfDataMarker: 'startOfDataMarker'
%                    Domain: [1x1 struct]
%           endOfDataMarker: 'endOfDataMarker'
          
% Now we've got the same object but by simply passing in its individual file 
% path. This can be done for any .depomodbathymetryproperties file - just
% pass in the path as above to get a MATLAB representation of the file
% which can be read, edited and saved easily.
%
% Incidently, the direct file path can be discovered from a project this
% way:

project.bathymetryDataPath

% ans =
% C:\newdepomod_projects\bay_of_fish\depomod\bathymetry\bay_of_fish.depomodbathymetryproperties

%% Read the bathy object

% Once the bathy data has been erad in, the pertinent information is held 
% in the .Domain and .data properties

bathy.Domain.spatial

% ans = 
%     reference: [1x1 struct]
%          minX: '349340'
%          maxX: '351340'
%          minY: '1067960'
%          maxY: '1069960'

% These are the domain bounds in OSGB easting/northings

bathy.Domain.data

% ans = 
%         elementFormat: 'csvRegularGrid'
%     numberOfElementsX: '79'
%     numberOfElementsY: '79'

% These are the number of cells in either direction (i.e. resolution).

size(bathy.data)

% ans =
%     79    79

% This is a 79 x 79 matric of water depth values

%% View the bathymetry

% plot the raw cell-by-cell bathymetry values
figure;
bathy.plot

% or pass in the 'contour' option to make a tider plot
bathy.plot('contour',1)

%%
          
