%% What?

% The bathymetry file can be edited and written back to file via the BathymetryFile
% object

%% Initialise bathymetry object

% Let's assume we're working with the sample project (though the
% functionality described below is equally avaialble when instantiating
% reading in the file directly or from AutoDepomod-style files)

projectDir = 'C:\newdepomod_projects\bay_of_fish';
project    = Depomod.Project.create(projectDir)
bathy      = project.bathymetry

%% Edit the domain bounds

% First, let's look at the domain bounds

bathy.Domain.spatial

% ans = 
%     reference: [1x1 struct]
%          minX: '349340'
%          maxX: '351340'
%          minY: '1067960'
%          maxY: '1069960'

% We can access individual values like this, e.g.,

bathy.Domain.spatial.minX

% ans =
% 349340

% To edit we simply set it "=" to a new value. However, these properties
% files require a string value for the value to be written successfully back
% to file, so we use num2str (or we could simply wrap the number in single 
% quotes).

% Let's shift the whole domain northwards by 1000 m.

bathy.Domain.spatial.minY = num2str(1068960)
bathy.Domain.spatial.maxY = num2str(1070960)

% This requirement to supply strings rather than numbers is awkward and
% should be improved in the library eventually.

%% Edit the grid resolution

% The grid resolution, described in these properties 

bathy.Domain.data.numberOfElementsX
bathy.Domain.data.numberOfElementsY

% ans =
% 79
% ans =
% 79

% can be edited in the same way. 79 x 79 is appropriate for a 2 km x 2 km
% domain at a resolution of 25 m, so we'll just leave it here.

%% Edit the depth data

% The depth data is found in the following property of the BathymetryFile
% object

bathy.data

% and is a 79 x 79 matrix. This can simply be overwritten using any valid
% MATLAB operations and manipulations. In a real modelling scenario it
% needs to be populated with accurate bathymetry and land data for which 
% there is no general solution. 
%
% Here we'll just set a straight coastline on the west and an eastward 
% sloping seabed.

% initialise a new container with the right size
newBathyData = zeros(79,79);

% set the first few columns as land (value = +10)
newBathyData(:,1:5) = 10

% Iterate through the existing columns
for c = 6:79
    % increase depth by a meter for every cell
    newBathyData(:,c) = -10 - c;
end

% assign the new data to the BathymetryFile object
bathy.data = newBathyData

% let's take a look
figure; bathy.plot

%% Datum shift

% We can very easily increase or decrease all the seabed depth values in the
% domain. Let's increase all depths by 5 m,

bathy.adjustSeabedDepths(5)

% and take a look
figure; bathy.plot

% It is discernable from the depth key that the depths have been shifted.
% Passing in a nevative value to this function shallows the bathymetry.

%% Smoothing the bathymetry

% The seabed can be smoothed easily, which is useful if the bathymetry data
% generated from raw data is noisy and/or includes features that are
% artifacts of the interpolation process rather than the real data.

% First let's add some noise to the bathy to demonstrate the point
% We can make use of the .seabedIndexes method to operate only on the
% seabed and not the land
[seabedIndexX,seabedIndexY] = find(bathy.seabedIndexes);

for c = 1:length(seabedIndexY)
    XIdx = seabedIndexX(c);
    YIdx = seabedIndexY(c);
    
    % alter the cell water depth a random value between +2 m and -2 m
    bathy.data(XIdx,YIdx) = bathy.data(XIdx,YIdx) + (rand*4-2)
end

figure; bathy.plot

% Okay, that's noisy. Now we can smooth it. This iterates through each cell
% and recomputes the water depth based on the average of the 4 surrounding
% cells (or 2 or 3 cells if on domain edge or corner, or next to land).

bathy.smoothSeabed

figure; bathy.plot

% Okay, smoother. Let's do it a few more times
for s = 1:3
    project.bathymetry.smoothSeabed;
end

figure; bathy.plot

% That's arguably better.

%% Write new information and data back to file

% Once we've finished editing the data, writing back to file is as simple as:
bathy.toFile

% If you want to save the file somewhere else - say to archive it for
% future use in a different project - simply pass in an alternative path
%
% bathy.toFile('new\file\path')

%% Writing new information and data to *AutoDepomod* bathy files

% The newly edited data can also be written back to old-style AutoDepomod
% bathymetry files. If the BathymetryFile object was instantiated using
% AutoDepomod bathy files then these will be memoised on the object in the
% following properties

bathy.GridgenBathymetryFile
bathy.GridgenDomainFile

% If so, these can be overwritten with the new information like this,

bathy.toGridgenFiles;

% If not, the object needs to be told where the old-style files are like
% this

bathy.GridgenBathymetryFile = AutoDepomod.BathymetryFile(gridgenDataPath);
bathy.GridgenDomainFile     = AutoDepomod.DomainFile(gridgenIniPath);

% If no gridgen bathy files exist but are required, then these can be found
% in the template, copied to the requisite location and the above code
% pointed to them. Then, do this

bathy.toGridgenFiles;

% This requirement occurs because of the current status of the command-line
% NewDepomod tool.

%%
