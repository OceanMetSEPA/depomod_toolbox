function [ minE, maxE, minN, maxN ] = readGridgenIni( path )
    % Reads in a Depomod /gridgen/<site name>.ini file and returns the
    % model domain description as 4 outputs, minimum east, maximum east,
    % minimum north and maximum north.
    %
    % Usage:
    %
    %    [ minE, maxE, minN, maxN ] = Depomod.Inputs.Readers.readGridgenIni(path);
    %
    %      where path is the full, absolute path of the <site name>.ini file located under
    %      the /depomod/gridgen directory of a modelling package
    % 
    %
    % EXAMPLES:
    %
    %    filePath = 'C:\...\ArdmairN\Modelling\Ardmair (north)\depomod\gridgen\Ardmair (north).ini'
    %    [minE, maxE, minN, maxN] = Depomod.Inputs.Readers.readGridgenIni(path);
    %
    %    minE =
    %          209750
    %    maxE =
    %          210750
    %    minN =
    %          898930
    %    maxN =
    %          899930
    % 

    % Iterate through each line and split into cell array representing the
    % label and the value
    data = cellfun(@(x) strsplit(char(x),  '='), Depomod.FileUtils.readTxtFile(path), 'UniformOutput', false);

    % Anonymous function - find the easting/northing which corresponds to the passed label
    % Compare strings after lowercasing them. This avoids any case
    % sensitivity
    parseNumber = @(label) str2double(data{cellfun(@(x) isequal(lower(x{1}), lower(label)), data(:,1))}{2});
   
    % Get and set the values
    minE = parseNumber('DataAreaXMin');
    maxE = parseNumber('DataAreaXMax');
    minN = parseNumber('DataAreaYMin');
    maxN = parseNumber('DataAreaYMax');
end

