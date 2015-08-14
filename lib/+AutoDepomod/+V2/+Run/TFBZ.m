classdef TFBZ < AutoDepomod.V2.Run.Chemical
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   TFBZ.m  $
% $Revision:   1.2  $
% $Author:   ted.schlicke  $
% $Date:   May 28 2014 13:03:28  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Wrapper class for individual TFBZ model runs in AutoDepomod. This class inherits from 
    % AutoDepomod.Run.Chemical and provides a number of convenience methods for locating files and handling 
    % model runs and some outputs (e.g. logfiles and sur files) specifically related to TFBZ. 
    %
    % AutoDepomod.Run.TFBZ objects are instantiated by passing in an instance of AutoDepomod.Package,
    % together with a .cfg filename.
    %
    % Usage:
    %
    %    model = AutoDepomod.Run.TFBZ(project, cfgFileName)
    %
    %  where:
    %    project: an instance of AutoDepomod.Package
    %    
    %    cfgFileName: is the filename of a .cfg file located within the
    %    /partrack directory of the project
    % 
    %
    % EXAMPLES:
    %
    %    project = AutoDepomod.Data.Package('Gorsten');
    %    run  = AutoDepomod.Run.TFBZ(project, 'Gorsten-T-N-1.cfg')
    %
    %    run.project   
    %      >> returns an instance of AutoDepomod.Package
    %
    %    run.cfgFileName   
    %      >> ans = 
    %      Gorsten-T-N-1.cfg
    %    
    %    run.execute()    
    %      >> runs Java depomod if located under AutoDepomod.Data.root path
    %    
    %    sur = run.sur    
    %      >> returns instance of Depomod.Outputs.Sur representing the
    %      g0.sur file associated with the model run
    %    
    % DEPENDENCIES:
    %
    %  - +AutoDepomod/+Run/Base.m
    %  - +AutoDepomod/+Run/Chemical.m
    %
    
    properties
        typeCode = 'T';
    end
    
    properties
        
        % The quantity which is estiamted to be in the environment as of the 118 day mark (which is the 
        % compliance interval). It is a function of the excretion rate and the decay rate.
        exportFactor = 0.9;
    end
    
    methods      
        function TR = TFBZ(farm, cfgFileName)
            TR = TR@AutoDepomod.V2.Run.Chemical(farm, cfgFileName);
        end     
        
    end
    
end

