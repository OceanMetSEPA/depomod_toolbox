%% What?

% One of the output file written by the model is termed a "sur" file which
% shorthand for "surface". This file describes the spatial distribution of
% a seabed impact at a particular point in time, often the model end point
% but potentially other points in the model duration. This file is written
% to the \intermediate directory in the case of single runs and/or the
% \results directory for optimised runs.
%
% The sur file describes information on the seabed impact on a cell by
% cell basis. For solids runs this represents cumulative grams of solids per 
% m2 up to that point in time in the model. For chemical runs it represents
% ug of chemical per kg of sediment at that point in the model run.
%
% For solids runs two sur files are written
%
%   - solids sur (total solids mass)
%
%   - carbon sur (solids carbon mass)
%
% Some useful ways to analyse this information that are provide in the toolbox
% are:
%
%   - plot the impact
%   - calculate the area of the impact at a particular intensity level
%   - calculate the total mass across the domain or within a particular
%     intensity level
%   - find the size and location of the maximum intensity of impact
%   - find the value at a specific location
%

%% Initialise a Sur file as part of a project

% If you have a whole project set up then a sur file can be instantiated 
% in MATLAB by taking advantage of the navigation provided by the 
% NewDepomod.Project and NewDepomod.Run classes, without needing file paths etc.

% Instantiate project by passing in root directory path
projectDir = 'C:\newdepomod_projects\bay_of_fish';
project = Depomod.Project.create(projectDir)

% then an inputs file can be found via its associated run:
sur = project.solidsRuns.number(1).solidsSur

% sur = 
%   Solids with properties:
% 
%      rawDataValueCol: 'outCol1'
%                 path: [1x90 char]
%              rawData: [1x1 struct]
%     interpolatedGrid: []
%                    X: [87x1 double]
%                    Y: [87x1 double]
%                    Z: [87x87 double]
%        GeoReferenced: 1

% The properties on this object are less intuitive which reflects the
% awkward nature of how the data is serialised in the file. Useful
% functionality is not based directly on these properties but on soem of
% the functions that are included in this class and described below.
           
%% Instantiate a sur file directly

% Alternatively, a sur file can be instantiated directly by using
% the direct file path, e.g.

sur = Depomod.Sur.Solids.fromFile('C:\newdepomod_projects\bay_of_fish\depomod\intermediate\bay_of_fish-NONE-N-1-solids-g0.sur', 'version', 2)

% sur = 
%   Solids with properties:
% 
%      rawDataValueCol: 'outCol1'
%                 path: [1x90 char]
%              rawData: [1x1 struct]
%     interpolatedGrid: []
%                    X: [87x1 double]
%                    Y: [87x1 double]
%                    Z: [87x87 double]
%        GeoReferenced: 1

% The 'version' = 2 parameter tells the toolbox that this is a NewDepomod
% sur file rather than an AutoDepomod sur file.
%
% Now we've got the same object but by simply passing in its individual file 
% path. This can be done for any .depomodcagesxml file - just
% pass in the path as above to get a MATLAB representation of the file
% which can be read, edited and saved easily.
%
% Incidently, the direct file path can be discovered from a project this
% way:
project.solidsRuns.number(1).solidsSurPath

% ans =
% C:\newdepomod_projects\bay_of_fish\depomod\intermediate\bay_of_fish-NONE-N-1-solids-g0.sur

%% Find the maximum impact intensity

% A number of functions are available for deriving pertinent information
% from the sur file. For example, the maximum intensity of impact can be
% foundusing

maxVal = sur.max

% maxVal =
%               49500.629453

% In this case, the result is 49.5 kg of solids per m2 per year (since the
% run is 365 days)

% By specifying three outputs, the location of the maximum impact can be
% discerned.

[maxVal, maxEasting, maxNorthing] = sur.max

% maxVal =
%               49500.629453
% maxEasting =
%                   350427.5
% maxNorthing =
%                  1069097.5

%% Calculate the area of impact

% The area of the impact can be calculated. This requires are particular
% intensity level for the impact to be specified, e.g.:

sur.area(4)     % g m-2
sur.area(192)   % g m-2
sur.area(1553)  % g m-2
sur.area(10000) % g m-2

% ans =
%           536986.621056892  % m2
% ans =
%           158867.252195808  % m2
% ans =
%            56685.0004043411 % m2
% ans =
%            29192.3903474528 % m2

% If no intensity level is passed in the function has no basis for discriminating 
% what is or isnt and impact and simply returns to total area in the domain

sur.area()

% ans =
%      4622500
     
% This includes padding cells around the domain

% To estiamte the maximum areal extent of any impact, the intensity passed
% can be some implausibly small level

sur.area(0.0001) % g m-2
     
% ans =
%           992888.181197206

% Which in this case amounts to just under a quarter of the domain.

%% Calculate the total mass of an impact

% In order to calculate total masses, rather than per m2 masses, we can
% integrate over the spatial impact described in the sur file. To do this
% we use the .volume() method.

% For example, if we want to know the total mass in the model domain as
% described by the sur file...

sur.volume

% ans =
%           1008269179.51625

% This integrates over the whole domain and returns the total mass, which
% in this case is just over 1 million kg of solids. Notice that this value
% is the same as that found within the run log file for the mass balance of
% solids over the course of the run (the balance in lieu of solids exported
% out of the domain)

solidsRun.log.Masses.solids.balance.run

% ans =
% 1008269179.5260 % g

% We can also pass in an intensity level to the volume method to return the
% mass within the area above that intensity

sur.volume(4)

% ans =
%              1007907799.11

% So practically all of the mass is concentrated at intensities above 4 g
% m-2.

sur.volume(192)

% ans =
%           995817844.923125


sur.volume(1553)

% ans =
%           937723434.79375

% So ~93% of the mass is concentrated above a flux level of 1553 g m-2 y-1

%% Find the average value 

% The mean value within a particular intensity contour can also be derived

sur.mean(4)

% ans =
%            1876.9700390789 % g m-2

% The average over the whole domain can be arrived at thus:
sur.mean(0)

% ans =
%            218.12205073364
           
%% Find the value at a particular location

% Finding the value at a particular location is useful if there are
% sensitive features to be protected or if model values are to be
% explicitly compared with seabed measurements. This can be done as
% follows:

sur.valueAt(351000,1068800) % easting, northing

% ans =
%           15.3138942064463 % g m-2

% A useful way to characterise the accuracy of a model output is to
% determine how far - in spatial distance - a given location is from a
% particular value. This helps in cases where an impact is particularly
% steep and therefore errors in magnitude between modelled and sample
% values simply represent arguably smaller errors in location

sur.distanceToValue(351000,1068800, 4)

% ans =
%           28.6286013749386

% In this case the nearest location with a value of 4 g m-2 is only 28 m away 
% the specified location (which could represent a sample exhibiting a value
% of 4 g m-2)

%% Plot the spatial impact

% The .plot() function can produce 3 types of plot

sur.plot('type','pcolor') % default in nothing passed in
sur.plot('type','contour') 
sur.plot('type','surf') 

% These are useful for giving a quick idea of the impact and can be
% manipultated using the standard MATLAB plotting functions, for example 
% by altering the colourmap 

%% Alter colour map to render impact levels

sur.plot('type','surf') 

% divide max by 10 so colourmap represent 10 g increments
map = zeros(int32(ceil(sur.max)/10),3); 

% Adjust colourmap
for m = 1:1 % 0-10 g, white
    map(m,1:3) = [1 1 1];
end
for m = 2:19 % 10-190 g, green
    map(m,1:3) = [0 1 0];
end
for m = 20:155 % 190-1550 g, blue
    map(m,1:3) = [0 0 1];
end
for m = 156:size(map,1) % >1550 g, red
    map(m,1:3) = [1 0 0];
end

colormap(map);
colorbar;

%% Generate impact contours

% Contours can be generated from the sur file around specific impact levels

c = sur.contour(4)
% c =
%   Column 1
%                          4
%                        229
%   Column 2
%                   351302.5
%           1068379.58701752
%   Column 3
%                   351277.5
%           1068381.21398831
%           
%           ...
% 
% Column 327
%           350824.049838912
%                  1068672.5
%   Column 328
%                   350827.5
%           1068672.12288308

% This is a MATLAB contour object describing the polygons of the contours
% around the specified impact level. This output can be used in further
% manupulations. For example, this output is used in the .area() function
% to calculcate impact level areas and is also used to plot the impact
% contours in the .plot() of the parent run, i.e.

solidsRun.plot

% For a quick and dirty contour plot, pass in the 'plot' = true (1) option
% to the contour function

sur.contour(4, 'plot', 1)

%% Other sur manipulations

% The cell-by-cell values can be easily scaled by a desired factor. For
% example,

sur.scale(2)

% will double all of the values, whereas

sur.scale(0.5)

% will halve all of the values. This might be useful, for example, for
% experimenting with the effects of increasing or decreasing biomass,
% though care must be taken as the response of the spatial impact to
% changes in loading is not always linear.

% sur files can be "added" to each other. This is useful when modelling
% neighbouring sites and allows their overlapping impacts to be added
% together. The domains described by the two sur files need not be the
% same, the function will combine the two domains into a new expanded
% sur domain.
%
% combinedSur = sur.add(otherSur)
%
% The areas and intensities of the combined impact can then be derived
% using the functions described above.

%%
