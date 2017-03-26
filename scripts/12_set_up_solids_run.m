%% What?

% Setting up a complete run requires editing of several files, depending on
% what is desired.
%
%   - cages file:               each run has a cage file. This might simply be a duplicate
%                               of that used in other runs is a cage layout is certain.
%                               But it could, in principle be altered in each run.
%
%   - inputs file:              each run has an inputs file defining the discharge
%                               scenario, i.e. waste feed, faecal and medicine discharge
%                               rates
%
%   - physical properties file: This describes the physical transport paramters to be used. 
%                               If absent, the model assumes default values. It is considered
%                               good practice to always use a physical properties file as 
%                               this provides a reference to the specific parameters used
%                               in each run.
%
%   - model file:               This describes some of the set up configuration for the run
%                               including the model run duration
%
%   - configuration file:       This describes some of the set up configuration for the run
%                               including the the number of particles and the time points at 
%                               which to output spatial impact results
%
% Each of these can be manipulated and written back to file
% programmatically (except for cages, at the moment).
%
%

%% Instantiate run

% Instantiate project by passing in root directory path
projectDir = 'C:\newdepomod_projects\bay_of_fish';
project = Depomod.Project.create(projectDir)

% get the run
solidsRun = project.solidsRuns.item(1);

%% Set the required biomass in the inputs file

% get the inputs file
solidsInputs = solidsRun.inputsFile;

% Edit the file
% This might already be set correctly and therefore be unecessary
solidsInputs.FeedInputs.uuid = solidsRun.cages.consolidatedCages.cage(1).inputsId;
% set the biomass
solidsInputs.setBiomass(2500.0);
% save to file
solidsInputs.toFile;

%% Set the required run time in the model file

% there are two run times in the model file:
%
%   - releasePeriod: the time over which to release particles (should be
%                    consistent with that described in the inputs file
%
%   - endTime:       the total time of the model run. In the normal case
%                    this should be 4 days longer than the release period
%                    in order that by the end of the model all particles
%                    are consolidated into the bed (consolodation takes 4
%                    days in the model). This ensures that all particles
%                    are counted at the end.
%

% So, first define the additional consolidation time in hours
particleConsolidationTime = 24*4; 

% Now, get the release time from the inputs file
noHours = str2num(solidsInputs.FeedInputs.numberOfTimeSteps);

% instantiate the model file for this run
solidsModel = solidsRun.modelFile;

% Set the relase period and end time paramters in milliseconds!
solidsModel.ModelTime.releasePeriod = num2str(noHours * 60 * 60 * 1000);
solidsModel.ModelTime.endTime       = num2str((noHours + particleConsolidationTime) * 60 * 60 * 1000);

% save to file
solidsModel.toFile; 

% If you want to save the file somewhere else - say to archive it for
% future use in a different project - simply pass in an alternative path
%
% solidsModel.toFile('new\file\path')

%% (Optional) Set multiple time points for spatial outputs (sur files) in the configuration file

% By default, spatial impact results representing the model *end point*
% are written out to .sur files. This is nomrmally desirable but it might
% the case that additional time points needs to be captured.
%
% The time points at which spatial outputs are recorded is determined by
% the following property in the configuration file:
%
%   Transports.recordTimes=10195200000,19267200000
%
% The example above is taken from the default EmBZ set up and represents
% outputs at 118 and 227 days, described from the start of the model un in
% milliseconds. We needs to produce something similar - a comma separated
% list of times in milliseconds
%
% Let's, for example, output spatial impact data for the preceding week
% before the end of the model run in order to perhaps capture any
% variability related to the spring-neap cycle

% Establish the total release period from the inputs file
runPeriodDays = str2num(solidsInputs.FeedInputs.numberOfTimeSteps) / 24.0

% runPeriodDays =
%    365

% We'll step back from 365 days in 2 day increments
samplingShifts = [0 2 4 6 8]

% subtract each from 365 days and convert to milliseconds
samplingDays = floor(runPeriodDays - samplingShifts).*(24*60*60*1000) % seconds

% samplingDays =
%   Column 1
%                31536000000
%   Column 2
%                31363200000
%   Column 3
%                31190400000
%   Column 4
%                31017600000
%   Column 5
%                30844800000

% join together as a comma separate string which we can use in the
% configuration file
samplingString = strjoin(cellfun(@num2str,num2cell(samplingDays(end:-1:1)),'UniformOutput',0),',')

% samplingString =
% 30844800000,31017600000,31190400000,31363200000,31536000000

% Now we're ready to set this in the configuration file

% instantiate the configuration file
solidsConfig = solidsRun.configurationFile

% Alternatively, this file can be instantiated independently of the run
% using the file path
%
% solidsConfig = NewDepomod.PropertiesFile('C:\newdepomod_projects\bay_of_fish\depomod\models\bay_of_fish-NONE-N-1-Configuration.properties')

% and set these values
solidsConfig.Transports.recordSurfaces='true'
solidsConfig.Transports.recordTimes=samplingString

% Other configuration options in this file include
%
% solidsConfig.Model.biomassLimit=Infinity
% solidsConfig.Model.maxNumberOfModelIterations='52'
% solidsConfig.Model.showConsoleOutput=false
% solidsConfig.Model.stockingDensityLimit=Infinity
% solidsConfig.RelseaseManager.numberOfParticlesPerCageFinalRuns='10'
% solidsConfig.RelseaseManager.numberOfParticlesPerCageScopingRuns='1'
% 

% write changes back to the file
solidsConfig.toFile

% If you want to save the file somewhere else - say to archive it for
% future use in a different project - simply pass in an alternative path
%
% solidsConfig.toFile('new\file\path')

%% Create and edit the physical properties

% The physical properties file describes the physical transport parameters
% with which the run is configured. If no file is present, the model simply
% assumes default cofiguration. It is good practice to always create and
% include a physical properties file on each run to ensure runs are always
% set up as required and that that the context of each run performed is 
% tracable when viewing results
%
% Physical properties files for each do not exist at the outset but are
% created as soon as access is attempted like this
solidsPhysicalProperties = solidsRun.physicalPropertiesFile

% Values can be read in the normal way
solidsPhysicalProperties.Transports.bottomRoughnessLength.smooth

% ans =
% 0.00003

% And can be set in the normal way. The following describes what is
% considered to be a default configuration for regulatory purposes in
% Scotland

% Horizontal dispersion in the settling phase
solidsPhysicalProperties.Transports.suspension.walker.dispersionCoefficientX='0.1'
solidsPhysicalProperties.Transports.suspension.walker.dispersionCoefficientY='0.1'
% Vertical dispersion in the settling phase
solidsPhysicalProperties.Transports.suspension.walker.dispersionCoefficientZ='0.005'

% Horizontal dispersion in the bed phase
solidsPhysicalProperties.Transports.bed.walker.dispersionCoefficientX='0.1'
solidsPhysicalProperties.Transports.bed.walker.dispersionCoefficientY='0.1'
% Vertical dispersion in the bed phase
solidsPhysicalProperties.Transports.bed.walker.dispersionCoefficientZ='0.0'

% Horizontal dispersion in the resuspension phase
solidsPhysicalProperties.Transports.resuspension.walker.dispersionCoefficientX='0.1'
solidsPhysicalProperties.Transports.resuspension.walker.dispersionCoefficientY='0.1'
% Vertical dispersion in the resuspension phase
solidsPhysicalProperties.Transports.resuspension.walker.dispersionCoefficientZ='0.005'

% Shear modified settling in settling phase
solidsPhysicalProperties.Transports.suspension.settling.modifiedSettling='false'
solidsPhysicalProperties.Transports.suspension.settling.allowBuoyant='false'

% Shear modified settling in resuspension phase
solidsPhysicalProperties.Transports.resuspension.settling.modifiedSettling='false'
solidsPhysicalProperties.Transports.resuspension.settling.allowBuoyant='false'

% Decay rate of solids
solidsPhysicalProperties.Particle.degradeT50Carbon='Infinity'
% Decay rate of EmBZ
solidsPhysicalProperties.Particle.degradeT50Chemical='21600000'

% Bed roughness
solidsPhysicalProperties.Transports.bottomRoughnessLength.smooth='0.00003'

% Critical shear stress threshold for erosion
solidsPhysicalProperties.Transports.BedModel.tauECritMin='0.02'

% Mass erodibility equation paramters
solidsPhysicalProperties.Transports.BedModel.massErosionCoefficient='0.031'
solidsPhysicalProperties.Transports.BedModel.massErosionExponent='1'

% save to file
solidsPhysicalProperties.toFile

% If you want to save the file somewhere else - say to archive it for
% future use in a different project - simply pass in an alternative path
%
% solidsPhysicalProperties.toFile('new\file\path')

%%

