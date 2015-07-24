function [ p ] = root(namespace)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   root.m  $
% $Revision:   1.2  $
% $Author:   ted.schlicke  $
% $Date:   May 28 2014 13:03:24  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Returns the AutoDepomod data root path.
    % 
    % By default the standard data path (C:\SEPA Consent\DATA) is returned. To 
    % return a non-standard, namespaced path, pass in the namespace as an argument.
    %
    % Usage:
    %
    %    AutoDepomod.Data.root(namespace);
    %
    % OUTPUT:
    %    
    %    p: a string describing the AutoDepomod root path or namespaced path.
    %
    % EXAMPLES:
    %
    %    AutoDepomod.Data.root
    %      >> ans =
    %      'C:\SEPA Consent\DATA'
    %
    %    AutoDepomod.Data.root('benthic_test')
    %      >> ans =
    %      'C:\SEPA Consent\DATA-benthic_test'
    %
    % DEPENDENCIES:
    %
    %  - +AutoDepomod/+Data/namespacePath.m
    % 

    p = 'C:\SEPA Consent\DATA';
    
    if exist('namespace', 'var') && ~isempty(namespace)
        p = AutoDepomod.Data.namespacePath(p, namespace);
    end
end

