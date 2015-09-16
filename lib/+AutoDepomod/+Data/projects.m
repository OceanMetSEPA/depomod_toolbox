function [ list ] = projects( namespace )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   packages.m  $
% $Revision:   1.2  $
% $Author:   ted.schlicke  $
% $Date:   May 28 2014 13:03:24  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Returns a cell array of all packages under the AutoDepomod data root path
    % as instances of the classAutoDepomod.Data.Package.
    % 
    % By default the list of packages are those that appearbeneath the
    % standard data path (C:\SEPA Consent\DATA). To return the packagesfrom 
    % a non-standard, namespaced path, pass in the namespace as an argument.
    %
    %
    % Usage:
    %
    %    packages = AutoDepomod.Data.packages(namespace);
    %
    % OUTPUT:
    %    
    %    list: a cell array of AutoDepomod.Data.Package instances.
    %
    % EXAMPLES:
    %
    %    packages = AutoDepomod.Data.packages();
    %
    %    packages{1}.name
    %      >> ans =
    %      Gorsten
    %
    %    packages{1}.path
    %      >> ans =
    %      C:\SEPA Consent\DATA\Gorsten
    %
    %    packages = AutoDepomod.Data.packages('benthic_tests');
    %
    %    packages{1}.name
    %      >> ans =
    %      Gorsten
    %
    %    packages{1}.path
    %      >> ans =
    %      C:\SEPA Consent\DATA-benthic_tests\Gorsten
    %
    % DEPENDENCIES:
    %
    %  - fileFinder.m
    %  - +AutoDepomod/+Data/root.m
    %  - +AutoDepomod/Package.m
    %  - +AutoDepomod/+Data/Package.m
    % 
    
    % default path
    dataPath = AutoDepomod.Data.root;
    
    % If no namespace explicitly passed in, just use the default
    % Otherwise, namespace it
    if(nargin~=0)
        dataPath = strcat(dataPath, '-', namespace);
    else
        % Make sure the namespace variable exists
        namespace = [];
    end
    
    % Get all contents within data root directory
    % Only return directories, not ReadMe's, etc.
    dataContents       = fileFinder(dataPath);
    subDirectoriesOnly = dataContents(cellfun(@(x) isdir(x), dataContents)); 
    
    % Instantiate all as Data.Package instances
    list = cell(length(subDirectoriesOnly), 1);
    
    for i = 1:length(subDirectoriesOnly)
        paths = strsplit(subDirectoriesOnly{i},'\');
        name  = paths{end};
        
        list{i} = AutoDepomod.Project.createFromDataDir(name, namespace);
    end
end

