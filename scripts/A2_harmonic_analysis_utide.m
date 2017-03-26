%% What?

% This script describes the conversion of raw flow dataset to the tidal
% only component using harmonic analysis provided by the UTide MATLAB
% library, which can be downloaded from here:
%
% - https://uk.mathworks.com/matlabcentral/fileexchange/46523--utide--unified-tidal-analysis-and-prediction-functions)
% 
% This is a simple example only in order to demonstrate the basic steps. It
% assumes data is extracted from an excel file and therefore includes some
% steps for ensuring datetime references are of the required format. If
% data is taken from, say, a CSV file or is otherwise already formatted
% correctly these steps can be ignored.

%% Read in data from excel file

% We assume the data is contained in the first sheet and the first rows and
% columns as such:
%
% column 1: timestamp
% column 2: u velocty (m/s)
% column 3: v velocity (m/s)
%
% Flow speed needs to be decomposed into orthogonal vector components. This
% can be done using the built-in MATLAB pol2cart() function or the
% rcm_toolbox found here (https://github.com/OceanMetSEPA/rcm_toolbox)
%

% read the xls file
[numData,strData,~] = xlsread('\\path\to\data.xls')


% numData is the numeric data only - columns 2-3
% strData is the string data - column 1 (the time is in string
% format)

%% reformat time data

% Midnight values in xls omit the time, i.e. the specify the date only.
% Add the time to these values explicitly so all values are a consistent
% format

% Find the indexes of the midnight values - the ones which have shorter
% string lengths
midnightIdxs = find(cellfun(@length, strData(:,1)) == 10)

% Now iterate through all and add the time string (00:00:00)
for i = 1:length(midnightIdxs)
    idx = midnightIdxs(i)

    strData(idx,1) = {[strData{idx,1}, ' 00:00:00' ]};
end

% Finally, convert to MATLAB datenum format
datenums = cellfun(@(x) datenum(x, 'dd/mm/yyyy HH:MM:SS'), strData(:,1))

%% Specify the site latitude - required for harmonic analysis

latitude = 60.7

%% Generate tidal harmonic constituents (uses uTide)

% u and v velocities - columns 1 and 2 of the numeric file data
tidalConstituents = ut_solv(datenums, numData(:,1), numData(:,2), latitude, 'auto', 'ols', 'white', 'LinCI', 'NoTrend');

%% Reconstruct the flow timeseries using only the harmonic consituents
% This produces the tidal only component of the flow

[reconstructedU,reconstructedV] = ut_reconstr(datenums,tidalConstituents)

%% Calculate tidal only speed and direction from tidal-only u and v values

% cart2pol built in function - converts cartesian vector (x,y) to polar
% vector (mag, dir)
[reconstructedDir, reconstructedSpeed] = cart2pol(reconstructedU,reconstructedV)

%% Scatter plot

figure
plot(numData(:,3), numData(:,4), 'ro')
hold on
plot(reconstructedU,reconstructedV, 'b+')
grid on

%% Time series plot

figure
plot(datenums, numData(:,1), 'r')
hold on
plot(datenums, reconstructedSpeed, 'b')
grid on


