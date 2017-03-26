%% What?

% This script does not use the toolbox functionality but simply describes
% one way to convert xyz bathymetry data into an interpolated regular grid
% of size 2 km x 2 km and a resolution of 25 m.
%
% Note this process *does not* include any reference to land values. These
% are assumed to be part of the xyz data but in reality it is likely that
% xyz bathymetry data is separate from land/coastline data. If this
% procedure is used using bathymetry data only then the interpolation may
% not accurately describe the location of land and the shape of the
% coastline. One useful approach is to establish polygons describing the
% land areas, perhaps from a shapefile or digitising of coastline using
% Admirailty charts of Google Earth. Once polygons describing the land
% regions are availabile each cell in the grid can be determined to be in
% the land or the sea using the MATLAB inpolygon() function during the
% cell-by-cell iteration described below. If it *is* in any of the
% polygons, the cell value is set to 10, for land.
%

%%

xyzData = dlmread('path\to\bathyData.xyz', ',');

% set number of grid cells
nx = 79; % 2km grid
ny = 79; % 2km grid

% set size of grid cells (m)
dx = 25
dy = 25

% define south west and north east bounds
ne = [205580, 630470];
sw = [203580, 628470];

x1 = sw(1); 
x2 = ne(1);
y1 = sw(2); 
y2 = ne(2);

% set the resolution for the interpolation (m) 
resolution = 5;

% create a grid of eastings and northings meshgrid:
[EX1,NY1]=meshgrid(x1:resolution:x2,y1:resolution:y2); % 5 m resolution

% use griddata to interpolate xyz data on a new grid at 5 m resolution:
griddedData = griddata(xyzData(:,1),xyzData(:,2),xyzData(:,3),(x1:resolution:x2),(y1:resolution:y2)','v4'); % 1m resolution

% create interpolation object which can be sampled at any location (i.e. 25
% m cells for NewDepomod)
xyzInterpolatedGrid = griddedInterpolant(NY1,EX1, griddedData, 'cubic');
        
% plot the xyz data along with the gridded-interpolated data
figure
contourf(EX1,NY1,griddedData.*-1.0)
colormap(bone)
colorbar
hold on
plot(xyzData(:,1),xyzData(:,2), 'r+')
hold off
title('')
        
% Now we want to sample the interpolated bathy data to produce a 25 m
% resolution grid of bathy data

% create a container for the new data
newData = nan(ny, nx);

% initialize easting and northing references for each cell using new
% grid origin and cell size
easting = sw(1) + (1:nx).*dx;
northing = sw(2) + (1:ny).*dy;

        
% Iterate through each cell of new grid and populate bathy data using
% the interpolated xyz data
for j = 1:length(easting) % columns
    for i = 1:length(northing) % rows

        % get easting and nothing for this cell
        e = easting(j);
        n = northing(i);
        depth = newData(j,i);
        
%         % If a land polygon exists, something like this helps (see
%         comments above)
%         if inpolygon(e, n, polygon.X, polygon.Y)
%             depth = 10;
%         end

        if isnan(depth)
            % sample interpolated data for this cell
            % multiply by -1 to change positive depth to negative depth
            depth = xyzInterpolatedGrid(n, e) * -1.0;
        end  
 
        % If we have a depth value, set it in the grid
        if ~isnan(depth)
            newData(j,i) = depth; 
        end
    end
end 
        
   
 
% Plot new bathy as 3D surface plot
% use the 3D rotate to inspect
[Y, X] = ndgrid(northing, easting);
figure
surf(X,Y, newData')
shading flat
colorbar
hold on

% if the data is noisey then it can be smoothed by iterating over each cell
% and adjusting it relative to the surrounding cells. This prevents
% features in the bathymetry arising that are below the resolution of the
% source data, but needs to be used appropriately.
%
% This step can be done using the depomod_toolbox NewDepomod.BathymetryFile
% class if desired.
%
for y = 1:ny % columns
    for x = 1:nx % rows

        if x ~= 1 & x ~= size(newData,1) & y ~= 1 & y ~= size(newData,2)
            newData(x,y) = (newData(x+1,y) + newData(x-1,y) + newData(x,y+1) + newData(x,y-1))/4.0;
        elseif x == 1 & y == 1
            newData(x,y) = (newData(x+1,y) + newData(x,y+1))/2.0;
        elseif x == 1 & y == size(newData,2)
            newData(x,y) = (newData(x+1,y) + newData(x,y-1))/2.0;
        elseif x == size(newData,1) & y == 1
            newData(x,y) = (newData(x-1,y) + newData(x,y+1))/2.0;
        elseif x == size(newData,1) & y == size(newData,2)
            newData(x,y) = (newData(x-1,y) + newData(x,y-1))/2.0;
        elseif x == 1
            newData(x,y) = (newData(x+1,y) + newData(x,y-1) + newData(x,y+1))/3.0;
        elseif y == 1
            newData(x,y) = (newData(x+1,y) + newData(x-1,y) + newData(x,y+1))/3.0;
        elseif x == size(newData,1) 
            newData(x,y) = (newData(x-1,y) + newData(x,y-1) + newData(x,y+1))/3.0;
         elseif y == size(newData,2)
            newData(x,y) = (newData(x+1,y) + newData(x-1,y) + newData(x,y-1))/3.0;
        end
    end
end

% use flipud to change order or rows to match NewDepomod requirements
data = flipud(newData');

% write out to csv file
csvwrite('file\path\for\bathy\data', data);

%% Write data to NewDepomod bathy file

projectDir = 'C:\newdepomod_projects\bay_of_fish';
project    = Depomod.Project.create(projectDir)
bathy      = project.bathymetry

% set the bounds
bathy.Domain.spatial.minX = num2str(x1)
bathy.Domain.spatial.maxX = num2str(x2)
bathy.Domain.spatial.minY = num2str(y1)
bathy.Domain.spatial.maxY = num2str(y2)

% set the cell resolution
bathy.Domain.data.numberOfElementsX = num2str(nx)
bathy.Domain.data.numberOfElementsY = num2str(ny)

% assign the new data grid
bathy.data = data

% take a look
figure; bathy.plot

% save
bathy.toFile
