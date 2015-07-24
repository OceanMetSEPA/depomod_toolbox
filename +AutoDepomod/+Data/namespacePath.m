function [ p ] = namespacePath(path, namespace)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   namespacePath.m  $
% $Revision:   1.2  $
% $Author:   ted.schlicke  $
% $Date:   May 28 2014 13:03:24  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Returns a namespaced version of the Autodepomod data root path. Naespaced
    % paths are used to created isolated testing environments for model runs.
    %
    % Usage:
    % 
    %    AutoDepomod.Data.namespacePath(namespace);
    %
    % OUTPUT:
    %    
    %    p: a new "namespaced" version of the AutoDepomod data root path.
    %
    % EXAMPLES:
    %
    %    AutoDepomod.Data.namespacePath('20140414');
    %    >> ans = 
    %      'C:\SEPA Consent\DATA-20140414'
    %
    %    AutoDepomod.Data.namespacePath('benthic_test');
    %    >> ans = 
    %      'C:\SEPA Consent\DATA-benthic_test'
    %    
    
    p = regexprep(path,'DATA[\w\-]*(\\)?',['DATA-', namespace, '$1']);
end