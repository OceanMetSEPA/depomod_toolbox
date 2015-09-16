function cloneAll(namespace)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   cloneAll.m  $
% $Revision:   1.2  $
% $Author:   ted.schlicke  $
% $Date:   May 28 2014 13:03:24  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Creates a clone of all packages contained within the /SEPA Consent/DATA directory using a 
    % new directory with the name format /SEPA Consent/DATA-namespace. The required namespace 
    % suffix can be passed in as an argument. If no namespace is passed in then the current 
    % datetime is used as a namespace for the cloned data.
    %
    % Usage:
    % 
    %    AutoDepomod.Data.cloneAll(namespace);
    % 
    %
    % OUTPUT:
    %    
    %    There is no explicit matlab output for this function. It creates the
    %    requisite new data directory containing clones of all files in the
    %    standard /DATA directory. Absolute path references in the cloned
    %    files are updated as appropriate.
    %
    % EXAMPLES:
    %
    %    AutoDepomod.Data.cloneAll();
    %
    %    AutoDepomod.Data.cloneAll('test');
    %
    % DEPENDENCIES:
    %
    %  - +AutoDepomod/+Data/packages.m
    % 
    
    if ~exist('namespace', 'var')
        % if no new namespace explicitly passed in, just use the current
        % time
        namespace = datestr(now, 'yyyymmddHHMMSS');
    end
    
    projects = AutoDepomod.Data.projects();
    
    for i = 1:length(projects)
        projects{i}.clone(namespace);
    end
end