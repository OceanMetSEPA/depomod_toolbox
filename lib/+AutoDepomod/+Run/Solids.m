classdef Solids < AutoDepomod.Run.Base
    % Wrapper class for individual solids model runs in AutoDepomod. This class inherits from 
    % AutoDepomod.Run.Base and provides a number of convenience methods for locating files and handling 
    % model runs and some outputs (e.g. logfiles and sur files). 
    %
    % AutoDepomod.Run.Solids objects are instantiated by passing in an instance of AutoDepomod.Package,
    % together with a .cfg filename.
    %
    % Usage:
    %
    %    model = AutoDepomod.Run.Solids(farm, cfgFileName)
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
    %    run  = AutoDepomod.Run.Solids(project, 'Gorsten-BcnstFI-N-1.cfg')
    %
    %    run.project   
    %      >> returns an instance of AutoDepomod.Package
    %
    %    run.cfgFileName   
    %      >> ans = 
    %      Gorsten-BcnstFI-N-1.cfg
    %    
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
        typeCode = 'S';
    end
    
    methods      
        function SR = Solids(project, cfgFileName)
            SR = SR@AutoDepomod.Run.Base(project, cfgFileName);
        end
        
        function mb = massReleased(SR)
            % Returns the mass balance for the model run in kg
            mb = SR.log.MassRelease;
        end
        
        function mb = massBalance(SR)
            % Returns the mass balance for the model run in kg
            mb = SR.log.MassBalance/1000.0;
        end
        
        function mbf = massBalanceFraction(SR)
            % Returns the mass balance for the model run as a decimal fraction of
            % the consent mass
            mbf = SR.massBalance / SR.massReleased;
        end
        
        function mbp = massBalancePercent(CR)
            % Returns the mass balance for the model run as a percentage of
            % the consent mass
            mbp = CR.massBalanceFraction * 100.0;
        end
        
        function e = export(SR)
            % Returns the mass exported for the model run in kg
            e = SR.massReleased - SR.massBalance;
        end
        
        function ef = exportFraction(SR)
            % Returns the mass exported for the model run as a decimal fraction of
            % the consent mass
            ef = SR.export/SR.massReleased;
        end
        
        function ep = exportPercent(SR)
            % Returns the mass exported for the model run as a percentage fraction of
            % the consent mass
            ep = SR.exportFraction * 100.0;
        end
       
    end
end

