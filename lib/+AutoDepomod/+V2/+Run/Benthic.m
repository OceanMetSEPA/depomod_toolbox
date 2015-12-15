classdef Benthic < AutoDepomod.V2.Run.Base
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   Benthic.m  $
% $Revision:   1.7  $
% $Author:   andrew.berkeley  $
% $Date:   Jun 24 2014 11:54:30  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Wrapper class for individual benthic model runs in AutoDepomod. This class inherits from 
    % AutoDepomod.Run.Base and provides a number of convenience methods for locating files and handling 
    % model runs and some outputs (e.g. logfiles and sur files). 
    %
    % AutoDepomod.Run.Benthic objects are instantiated by passing in an instance of AutoDepomod.Package,
    % together with a .cfg filename.
    %
    % Usage:
    %
    %    model = AutoDepomod.Run.Base(farm, cfgFileName)
    %
    %  where:
    %    farm: an instance of AutoDepomod.Package
    %    
    %    cfgFileName: is the filename of a .cfg file located within the
    %    /partrack directory of the project (and namespace if provided)
    %    
    %    namespace: the namespace of the data path required.
    % 
    %
    % EXAMPLES:
    %
    %    project = AutoDepomod.Data.Package('Gorsten');
    %    run  = AutoDepomod.Run.Benthic(project, 'Gorsten-BcnstFI-N-1.cfg')
    %
    %    run.project   
    %      >> returns an instance of AutoDepomod.Package
    %
    %    run.cfgFileName   
    %      >> ans = 
    %      Gorsten-BcnstFI-N-1.cfg
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
    %
    
    properties (Hidden = true)
        typeCode = 'B';
    end
    
    methods      
        function BR = Benthic(project, cfgFileName)
            BR = BR@AutoDepomod.V2.Run.Base(project, cfgFileName);
        end
        
        function mb = massReleased(BR)
            % Returns the mass balance for the model run in kg
            mb = BR.log.MASSRELEASED;
        end
        
        function mb = massBalance(BR)
            % Returns the mass balance for the model run in kg
            mb = BR.log.MASSBALANCEG/1000.0;
        end
        
        function mbf = massBalanceFraction(BR)
            % Returns the mass balance for the model run as a decimal fraction of
            % the consent mass
            mbf = BR.massBalance / BR.massReleased;
        end
        
        function mbp = massBalancePercent(CR)
            % Returns the mass balance for the model run as a percentage of
            % the consent mass
            mbp = CR.massBalanceFraction * 100.0;
        end
        
        function e = export(BR)
            % Returns the mass exported for the model run in kg
            e = BR.massReleased - BR.massBalance;
        end
        
        function ef = exportFraction(BR)
            % Returns the mass exported for the model run as a decimal fraction of
            % the consent mass
            ef = BR.export/BR.massReleased;
        end
        
        function ep = exportPercent(BR)
            % Returns the mass exported for the model run as a percentage fraction of
            % the consent mass
            ep = BR.exportFraction * 100.0;
        end
       
    end
end

