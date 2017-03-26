classdef Chemical < NewDepomod.Run.Base
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
        chemicalSur@Depomod.Sur.Residue
    end
    
    methods     
        function CR = Chemical(project, cfgFileName)
            CR = CR@NewDepomod.Run.Base(project, cfgFileName);
        end  
        
        function p = chemicalSurPath(R)
            p = R.surPath('chemical');
        end
        
        function cs = get.chemicalSur(R)
            if isempty(R.chemicalSur)
                if exist(R.chemicalSurPath, 'file')
                    R.chemicalSur = R.initializeSur(R.chemicalSurPath);
                end
            end
            
            cs = R.chemicalSur;
        end
        
        function s = sur(R) % shortcut method/backwards compatibility
            s = R.chemicalSur;
        end
        
        function cm = consentMass(CR)
            % Returns the consent mass for the model run
            cm = CR.log.CONSENTMASS;
        end
        
        function mb = massBalance(CR)
            % Returns the mass balance for the model run
            mb = CR.log.MASSBALANCEG;
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
            diff = CR.log.FARFIELDAREADIFFERENCE;
            ffa  = CR.AZE + diff;
        end
        
        function a = AZE(CR)
            % Returns the AZE associated with the model run
            a = CR.log.FARFIELDAREA;
        end
        
        function refreshRunFileproperties(R)
            R.clearRunFileProperties = 1;
            
            R.inputsFile;
            R.iterationInputsFile;
            R.exportedTimeSeriesFile;
            R.consolidatedTimeSeriesFile;
            R.solidsSur;
            R.carbonSur;
            R.chemicalSur;
            
            R.clearRunFileProperties = 0;
        end
    end
    
end

