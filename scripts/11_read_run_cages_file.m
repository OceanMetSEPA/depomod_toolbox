%% What?

% Cage definitions are found in the \cage directory of the project. There
% is 1 cage file for each individual run, they are described in XML format
% and take the file extension .depomodcagesxml. 
%
% Each cage group and individual cage is described in the XML data
% structure. Each cage has an easting and northing location description as
% well as dimensions, a feed proprtion, and an id.
%
% The cage id must match that reference in the run inputs file for a run to
% be successful.
%
% Cage depth - that is the length of the vertical cage dimension - is, perhaps 
% confusingly, described in the "height" property (mis-spelled "hieght" in
% the XML), whereas the "depth" property refers to the depth in the water
% column of the midpoint of the cage. This is intended to support submerged
% cages. Ordinarily, for cages at the water surface, the depth will be half
% of the value of the height, i.e. a 12 m cage at the surface has a height of 
% 12 m and a depth of 6 m (the midpoint).
%
% Cage file can be read programmatically. They can, in principle, be
% manipulated programmatically, but writing back to file is *not currently
% supported* so manipulating in MATLAB is mostly pointless. Writing back to
% file will be supported ASAP.

%% Initialize cage file as part of a project

% If you have a whole project set up then a cage file can be instantiated 
% in MATLAB by taking advantage of the navigation provided by
% the NewDepomod.Project and NewDepomod.Run classes, without needing file paths etc.

% Instantiate project by passing in root directory path
projectDir = 'C:\newdepomod_projects\bay_of_fish';
project = Depomod.Project.create(projectDir)

% then an inputs file can be found via its associated run:
cages = project.solidsRuns.number(1).cages

% cages = 
%   2 Site array with properties:
% 
%     cageGroups: {1x2 cell}
           
%% Instantiate a cages file directly

% Alternatively, a cages file can be instantiated directly by using
% the direct file path, e.g.

cages = Depomod.Layout.Site.fromXMLFile ('C:\newdepomod_projects\bay_of_fish\depomod\cages\bay_of_fish-NONE-N-1.depomodcagesxml')

% cages = 
%   2 Site array with properties:
% 
%     cageGroups: {1x2 cell}
          
% Now we've got the same object but by simply passing in its individual file 
% path. This can be done for any .depomodcagesxml file - just
% pass in the path as above to get a MATLAB representation of the file
% which can be read, edited and saved easily.
%
% Incidently, the direct file path can be discovered from a project this
% way:

project.solidsRuns.number(1).cagesPath
% ans =
% C:\newdepomod_projects\bay_of_fish\depomod\cages\bay_of_fish-NONE-N-1.depomodcagesxml

%% Inspect the cages

% Some aggregate information can be derived about the entirety of cages
cages.cageArea
cages.cageVolume

% ans =
%           6369.80278655024
% ans =
%           76437.6334386029
          
% Or, the object can be drilled into to resolve individual cage groups or
% cages

% The first cage group
cages.group(1)

% ans = 
%   4 Group array with properties:
% 
%          cages: {1x4 cell}
%     layoutType: 'REGULARGRID'
%           name: 'CageGroup1'
%              x: 350367.322727118
%              y: 1069105.66316785
%       xSpacing: 49.9999999981326
%       ySpacing: 49.9999999983128
%             Nx: 2
%             Ny: 2
%         length: 31.84
%          width: 31.84
%         height: 12
%          depth: 6
%        bearing: 246.000000004037
%       cageType: 'CIRCULAR'

% Just the area and volume of this group
cages.group(1).cageArea
cages.group(1).cageVolume

% ans =
%           3184.90139327512
% ans =
%           38218.8167193015

% And the first cage in the first cage group
cages.group(1).cage(1)

% ans = 
%   Circle with properties:
% 
%                x: 350413
%                y: 1069126
%           length: 31.84
%            width: 31.84
%           height: 12
%            depth: 6
%         inputsId: [1x36 char]
%       proportion: 0.125
%     inProduction: 1
    
% Accessing individual properties for a single cage 
cages.group(1).cage(1).area
cages.group(1).cage(1).volume
cages.group(1).cage(1).x        % easting
cages.group(1).cage(1).y        % northing
cages.group(1).cage(1).height   % cage vertical dimension
cages.group(1).cage(1).inputsId % cage vertical dimension
    
% ans =
%            796.22534831878
% ans =
%           9554.70417982536
% ans =
%       350413
% ans =
%      1069126
% ans =
%     12
% ans =
% 4c97b36c-bd67-44db-bfe7-15d6b3b298d2
    
% The cage volumne calculations made in the above examples are used to
% convert biomass to stocking density and vice versa in the .setBiomass() 
% and .setStockingDensity() function in the related inputs file
    
%%
