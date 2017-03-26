%% What?

% NewDepmod outputs time series files detailing the daily cumulative
% masses that remain in the domain and have been exported out of the
% domain. These files are in CSV format and have the file extension
% .depomodtimeseries. For each run the following files types are 
% outputted by the command line version of NewDepomod
%
%   bay_of_fish-EMBZ-S-1-consolidated-g1.depomodtimeseries
%   bay_of_fish-EMBZ-S-1-exported-g1.depomodtimeseries
%
% That is, a timeseries of "consolidated" mass in the domain and a
% timeseries of exported mass.
%
% The columns in these files are as follows:
%
%   Time (Day)
%   Total Mass (Kg)
%   Total Carbon Mass (Kg)
%   Total Chemical Mass (Kg)
%   Total Feed Mass (Kg)
%   Total Feed Carbon Mass (Kg)
%   Total Feed Chemical Mass (Kg)
%   Total Faeces Mass (Kg)
%   Total Faeces Carbon Mass (Kg)
%   Total Faeces Chemical Mass (Kg)
%
% These files are *not* currently written by the GUI.
%
% These files are useful for understanding variations through time in the
% impact of the farm discharges. These may be in repsonse to the
% spring-neap cycle for example, or other events described within the flow
% dataset. Periods of particularly high or low domain masses might be
% examined more closely to understand the range of impacts that may occur
% and the associated risks. One approach to this might be to re-run the
% model having specified additional spatial output time points in the
% run configuration file so that the spatial impact variability in response
% to these time-dependent events can be measured.
%

%% Initialise a time series file as part of a project

% If you have a whole project set up then a time series output file can 
% be instantiated in MATLAB by taking advantage of the navigation 
% provided by the NewDepomod.Project and NewDepomod.Run classes, 
% without needing file paths etc.

% Instantiate project by passing in root directory path
projectDir = 'C:\newdepomod_projects\bay_of_fish';
project = Depomod.Project.create(projectDir)

% then an inputs file can be found via its associated run:
consolidatedTS = project.solidsRuns.number(1).consolidatedTimeSeriesFile
exportedTS     = project.solidsRuns.number(1).exportedTimeSeriesFile

% consolidatedTS = 
%   TimeSeriesFile with properties:
% 
%                           path: [1x110 char]
%                        headers: {1x10 cell}
%                          units: {1x10 cell}
%                           data: [369x10 double]
%                      propnames: {1x10 cell}
%       Total_Feed_Chemical_Mass: [369x1 double]
%                           Time: [369x1 double]
%                Total_Feed_Mass: [369x1 double]
%                     Total_Mass: [369x1 double]
%       Total_Faeces_Carbon_Mass: [369x1 double]
%              Total_Carbon_Mass: [369x1 double]
%         Total_Feed_Carbon_Mass: [369x1 double]
%            Total_Chemical_Mass: [369x1 double]
%              Total_Faeces_Mass: [369x1 double]
%     Total_Faeces_Chemical_Mass: [369x1 double]

% These properties represent the 10 file columns as well as other metadata
% such as units.
           
%% Instantiate a time series file directly

% Alternatively, a time series file can be instantiated directly by using
% the direct file path, e.g.

ts = NewDepomod.TimeSeriesFile('C:\newdepomod_projects\bay_of_fish\depomod\intermediate\bay_of_fish-NONE-N-1-consolidated-g1.depomodtimeseries')

% ts = 
%   TimeSeriesFile with properties:
% 
%                           path: [1x110 char]
%                        headers: {1x10 cell}
%                          units: {1x10 cell}
%                           data: [369x10 double]
%                      propnames: {1x10 cell}
%       Total_Feed_Chemical_Mass: [369x1 double]
%                           Time: [369x1 double]
%                Total_Feed_Mass: [369x1 double]
%                     Total_Mass: [369x1 double]
%       Total_Faeces_Carbon_Mass: [369x1 double]
%              Total_Carbon_Mass: [369x1 double]
%         Total_Feed_Carbon_Mass: [369x1 double]
%            Total_Chemical_Mass: [369x1 double]
%              Total_Faeces_Mass: [369x1 double]
%     Total_Faeces_Chemical_Mass: [369x1 double]

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



%% Extract the time series information

% The columns of data can be extracted directed from the object properties,
% e.g.

consolidatedTS.Time

% ans =
%      0
%      1
%      2
%      3
%    ...
%    366
%    367
%    368 % days
   
consolidatedTS.Total_Faeces_Mass

% ans =
%                          0
%                          0
%                          0
%                          0
%                          0
%                    2317.09
%                    4634.17
%                    6951.26
%                        ...
%                     827896
%                     830213
%                     832365 % kg

% Notice that the total mass at the end of the run is within half a percent
% of the mass balance described in the log file (its not clear why it is
% slightly different)
consolidatedTS.Total_Mass(end)
str2num(solidsRun.log.Masses.solids.balance.run)/1000.0


%% Plot time series data

% These can be used to easily produce a plot, e.g. in-domain cumulative
% mass versus cumulative exported mass

figure
plot(consolidatedTS.Time, consolidatedTS.Total_Mass, 'r')
hold on
plot(exportedTS.Time, exportedTS.Total_Mass, 'b')
grid on
legend('balance', 'exported')

%% Extract single column for convenient manipulation

% An individual column of the time series file can be converted to
% TimeSeries object which provides a few simply operations. To do this use
% the .toTimeSeries() method and pass in the index of the column required.
% For example for the total mass, pass in index = 2, as this is the second
% column, the first being the Time column.

totalMass = consolidatedTS.toTimeSeries(2)

% totalMass = 
%   TimeSeries with properties:
% 
%          Time: [369x1 double]
%         Value: [369x1 double]
%     ValueName: 'Total Mass'
%      TimeUnit: 'Day'
%     ValueUnit: 'Kg'
%        source: [1x1 NewDepomod.TimeSeriesFile]
       
% (The order of the columns can be found easily by looking at the .headers property)

consolidatedTS.headers

% ans = 
%   Columns 1 through 3
%     'Time'    'Total Mass'    'Total Carbon Mass'
%   Columns 4 through 5
%     'Total Chemical Mass'    'Total Feed Mass'
%   Columns 6 through 7
%     'Total Feed Carbon Mass'    'Total Feed Chemical Mass'
%   Columns 8 through 9
%     'Total Faeces Mass'    'Total Faeces Carbon Mass'
%   Column 10
%     'Total Faeces Chemical Mass'
       
% Once a column has been converted to a TimeSeries object a few things can
% be readily done.

% Get the value on a particular day:

totalMass.valueAt(200)

% ans =
%       540020

      
% Scale the whole series by a factor

totalMass.scale(2)

% Plot the time series

totalMass.plot
      
%%
      
      