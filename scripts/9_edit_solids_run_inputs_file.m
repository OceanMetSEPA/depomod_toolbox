%% What?

% The inputs file defines the feed inputs and ultimately the discharges for
% any given model run. Each individual run is associated with an inputs
% file.
%
% The format of the file is a Java Properties format and holds a CSV data
% table at the end. The key-value data at the top of the file defines a
% number of things including the biomass, stocking density and the number of 
% time steps defined in the table below.
%
% The data table contains 6 columns. The rows represent hourly discharge
% quantities. Therefore the resolution of this discharge data is hourly and
% the total number of rows represents the total number of (hourly)
% timesteps. The number of rows should therefore match the number of time
% steps declared in the information above.
%
% The columns in the data table repersent hourly discharge masses (kg) of:
%
%   - wasted feed solids 
%   - wasted feed carbon
%   - wasted feed chemical
%   - faecal feed solids 
%   - faecal feed carbon
%   - faecal feed chemical
%
% This data table can be constructed manually to define any discharge
% scenario desired. (Changing the number of timesteps requires complemetary
% changes to other files too).

%% Initialize inputs file as part of a project

% If you have a whole project set up then an inputs file can be instantiated 
% in MATLAB by taking advantage of the navigation provided by
% the NewDepomod.Project and NewDepomod.Run classes, without needing file paths etc.

% Instantiate project by passing in root directory path
projectDir = 'C:\newdepomod_projects\bay_of_fish';
project = Depomod.Project.create(projectDir)


% then an inputs file can be found via its associated run:
inputs = project.solidsRuns.number(1).inputsFile

% inputs = 
%   InputsPropertiesFile with properties:
% 
%       dataColumnCount: 6
%                   run: [1x1 NewDepomod.Run.Solids]
%                  data: [8760x6 double]
%                  path: [1x103 char]
%     startOfDataMarker: 'startOfDataMarker'
%       endOfDataMarker: 'endOfDataMarker'
%              Particle: [1x1 struct]
%            FeedInputs: [1x1 struct]
           
%% Instantiate an inputs file directly

% Alternatively, an inputs file can be instantiated directly by using
% the direct file path, e.g.

inputs = NewDepomod.InputsPropertiesFile('C:\newdepomod_projects\bay_of_fish\depomod\inputs\bay_of_fish-1-NONE-allCages.depomodinputsproperties')

% inputs = 
%   InputsPropertiesFile with properties:
% 
%       dataColumnCount: 6
%                   run: []
%                  data: [8760x6 double]
%                  path: [1x103 char]
%     startOfDataMarker: 'startOfDataMarker'
%       endOfDataMarker: 'endOfDataMarker'
%              Particle: [1x1 struct]
%            FeedInputs: [1x1 struct]
          
% Now we've got the same object but by simply passing in its individual file 
% path. This can be done for any .depomodinputsproperties file - just
% pass in the path as above to get a MATLAB representation of the file
% which can be read, edited and saved easily.
%
% Incidently, the direct file path can be discovered from a project this
% way:

project.solidsRuns.number(1).inputsFilePath
% ans =
% C:\newdepomod_projects\bay_of_fish\depomod\inputs\bay_of_fish-1-NONE-allCages.depomodinputsproperties

% The drawback of instantiating the file directly like this is that
% linkages to the other run information is missing. For example, the
% associated cages are not in scope and therefore setting the biomass via a
% desired stocking density cannot be done as the total cage volumne is not
% available.

%% Edit the input properties - an example

% Editing the input properties is, in principle, the same as editing the
% bathymetry file. Individual key-value pairs can be accessed and set,
% e.g.,

inputs.FeedInputs.biomass

% ans =
% 1000

% We can change this easily,

inputs.FeedInputs.biomass = '2000' % currently requires a string format

% check it again
inputs.FeedInputs.biomass

% ans =
% 2000

% Okay, its changed, but it should be understood that this does not
% actually change the run scenario in terms of the biomass modelled. For
% this it requires changing the discharge data table to reflect the
% appropriate hourly mass discharges (waste feed and faeces).
%
% Since we need to ensure that the biomass, stocking density and discharge
% data are consistent with one another, let's change it back for now.

inputs.FeedInputs.biomass = '1000' 

%% Edit the cage id

% The feed inputs file has a property which describes a unique identifer to
% the cages that will be the source of the discharge information in the
% file. This identifer needs to match identifiers declared in the
% associated cages file. This can be done manually but can also be done
% easily programatically this way,

inputs.FeedInputs.uuid = solidsRun.cages.consolidatedCages.cage(1).inputsId;

% This simply access the associated cage file and looks at the id for the
% first cage. This requires instantiation of the inputs file via the
% project and run in order for the associated cage file to be in scope.
%
% This step is probably unecessary if the files are already setup correctly
% but is a useful step to ensure consistency between the two files (inputs
% and cages).

%% A simple biomass scenario

% For a simple scenario representing a constant biomass farm operation
% there are some convenience methods for configuring the inputs file. These
% methods alter the biomass, stocking density properties of the file as
% well as reproducing the entire discharge data table according to
% requirements. 
%
% Let's checkout the existing setup first,

inputs.FeedInputs.biomass
% ans =
% 1000
inputs.FeedInputs.stockingDensity
% ans =
% 13.0826
inputs.FeedInputs.numberOfTimeSteps
% ans =
% 8760
size(inputs.data)
% ans =
%         8760           6
inputs.data(1,1)
% ans =
%                     7.9625

% Okay, we have 1000 t, 13 kg m-3, and 8760 time steps which is reflected
% in the discharge data table which is 8760 rows x 6 columns. 8760 hours is
% equivalent to 1 year. We've pulled out the first value in the data table
% too which represents the first hour's waste feed total mass: 7.9 kg.
%
% Let double the biomass.

inputs.setBiomass(2000)

% and check the resultant configuration

inputs.FeedInputs.biomass
% ans =
% 2000
inputs.FeedInputs.stockingDensity
% ans =
% 26.1651
inputs.FeedInputs.numberOfTimeSteps
% ans =
% 8760
size(inputs.data)
% ans =
%         8760           6
inputs.data(1,1)
% ans =
%                     15.925


% Okay, the biomass and stocking density have doubled, as has the hourly
% waste feed (and all the other values in that table, though no need to
% look at them all). The number of timesteps has stayed the same - 1 year.

% Let's say we want to half the run time to 6 months. We cn pass this in to
% the method

inputs.setBiomass(2000, 'days', 180)

% and check the resultant configuration

inputs.FeedInputs.biomass
% ans =
% 2000
inputs.FeedInputs.stockingDensity
% ans =
% 26.1651
inputs.FeedInputs.numberOfTimeSteps
% ans =
% 4320
size(inputs.data)
% ans =
%         4320           6
inputs.data(1,1)
% ans =
%                     15.925

% So the biomass, stocking density and feed data are the same, but the time
% steps have now been changed and reflected in the number of data table
% rows.

% Alternatively, if one wants to define the biomass in terms of a stocking
% density this can be done easily. Let's switch back to the original
% scenario this way

inputs.setStockingDensity(13.0826, 'days', 365)

% and check the resultant configuration

inputs.FeedInputs.biomass
% ans =
% 1000.003
inputs.FeedInputs.stockingDensity
% ans =
% 13.0826
inputs.FeedInputs.numberOfTimeSteps
% ans =
% 8760
size(inputs.data)
% ans =
%         8760           6
inputs.data(1,1)
% ans =
%                     7.96252375392004

% All values back to normal (within rounding errors).

% These functions simply set a constant discharge rate which implies a
% constant feed load. The functions use default values for feed rates (7 kg
% t-1 day-1), water content, digestibility rates, etc. in order to convert the
% biomass into a discharge rate. These paramters can be specified as additional 
% options if the default values are to be overridden.
%
% Note, these methods require the inputs file to be instantiated via the
% parent model run so that the associated cages can be accessed and the
% relation between biomass and stocking density derived.

%% More complicated scenarios

% For complicated scenarios the modeller needs to manually build the
% discharge data table. This could be useful for representing a specific
% historical feed rate or for simulating one or several growth cycles.
%
% In any case, care needs to be taken to ensure that the biomass, stocking
% density and number of time steps are consistent with what is implied by
% the discharge data table. Additionally, values in other files need to be
% altered if the run duration is changed.

%% Writing changes back to file

% Once changes to the data are completed, writing back to file is as simple as:
inputs.toFile

% If you want to save the file somewhere else - say to archive it for
% future use in a different project - simply pass in an alternative path
%
% inputs.toFile('new\file\path')

%%

