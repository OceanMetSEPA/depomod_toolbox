classdef Chemical < AutoDepomod.V1.Run.Base
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   Chemical.m  $
% $Revision:   1.2  $
% $Author:   ted.schlicke  $
% $Date:   May 28 2014 13:03:28  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Wrapper class for individual chemical model runs in AutoDepomod. This class inherits from 
    % AutoDepomod.Run.Base and provides a number of convenience methods for locating files and handling 
    % model runs and some outputs (e.g. logfiles and sur files), specifically in the context of chemical runs.
    %
    % This class is not intended to be used directly but is intended to be subclassed with the 
    % introduction of a exportFactor property (see Run.EmBZ, Run.TFBZ)
    %
    % AutoDepomod.Run.Chemical objects are instantiated by passing in an instance of AutoDepomod.Package,
    % together with a .cfg filename.
    %
    % Usage:
    %
    %    model = AutoDepomod.Run.Chemical(project, cfgFileName)
    %
    %  where:
    %    project: an instance of AutoDepomod.Package
    %    
    %    cfgFileName: is the filename of a .cfg file located within the
    %    /partrack directory of the project (and namespace if provided)
    % 
    %
    % EXAMPLES:
    %
    %    project = AutoDepomod.Data.Package('Gorsten');
    %    run  = AutoDepomod.Run.Chemical(project, 'Gorsten-E-N-1.cfg')
    %
    %    run.project   
    %      >> returns an instance of AutoDepomod.Package
    %
    %    run.cfgFileName   
    %      >> ans = 
    %      Gorsten-E-N-1.cfg
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
    
    properties
    end
    
    methods     
        function CR = Chemical(project, cfgFileName)
            CR = CR@AutoDepomod.V1.Run.Base(project, cfgFileName);
        end  
        
        function cm = consentMass(CR)
            % Returns the consent mass for the model run
            cm = CR.log.ConsentMass;
        end
        
        function mb = massBalance(CR)
            % Returns the mass balance for the model run
            mb = CR.log.MassBalance;
        end
        
        function mbf = massBalanceFraction(CR)
            % Returns the mass balance for the model run as a decimal fraction of
            % the consent mass
            mbf = CR.massBalance / CR.consentMass;
        end
        
        function mbp = massBalancePercent(CR)
            % Returns the mass balance for the model run as a percentage of
            % the consent mass
            mbp = CR.massBalanceFraction * 100.0;
        end
        
        function e = export(CR)
            % Returns the mass exported for the model run
            e = CR.consentMass * CR.exportFactor - CR.massBalance;
        end
        
        function ef = exportFraction(CR)
            % Returns the mass exported for the model run as a decimal fraction of
            % the consent mass
            ef = CR.export/CR.consentMass;
        end
        
        function ep = exportPercent(CR)
            % Returns the mass exported for the model run as a percentage fraction of
            % the consent mass
            ep = CR.exportFraction * 100.0;
        end
        
        function ffa= farFieldImpactArea(CR)
            % Returns the area imapcted at the fari-field compliance level in the model run
            diff = CR.log.FarFieldAreadiff;
            ffa  = CR.AZE + diff;
        end
        
        function a = AZE(CR)
            % Returns the AZE associated with the model run
            a = CR.log.FarFieldArea;
        end
    end
    
end

