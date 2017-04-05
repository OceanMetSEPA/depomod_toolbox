classdef EmBZ < NewDepomod.Run.Chemical
    % Wrapper class for individual EmBZ model runs in AutoDepomod. This class inherits from 
    % AutoDepomod.Run.Chemical and provides a number of convenience methods for locating files and handling 
    % model runs and some outputs (e.g. logfiles and sur files) specifically related to EmBZ. 
    %
    % AutoDepomod.Run.EmBZ objects are instantiated by passing in an instance of AutoDepomod.Package,
    % together with a .cfg filename.
    %
    % Usage:
    %
    %    model = AutoDepomod.Run.EmBZ(project, cfgFileName)
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
    %    run  = AutoDepomod.Run.EmBZ(project, 'Gorsten-E-N-1.cfg')
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
    %  - +AutoDepomod/+Run/Chemical.m
    %
    
    properties (Hidden = true)
        typeCode = 'E';
    end
    
    properties
        % The quantity which is estiamted to be in the environment as of the 118 day mark (which is the 
        % compliance interval). It is a function of the excretion rate and the decay rate.
        exportFactor = 0.74;
        chemicalSurWithDecay@Depomod.Sur.Residue;
        defaultPlotLevels = [0.1, 0.763, 2.0, 10.0 25.0];
        defaultUnit = 'ug kg^{-1}';
    end
    
    methods      
        function EBR = EmBZ(project, cfgFileName)
            EBR = EBR@NewDepomod.Run.Chemical(project, cfgFileName);
        end  
         
        function p = chemicalSurWithDecayPath(R)
            p = R.surPath('chemical', 1);
        end
        
        function cs = get.chemicalSurWithDecay(R)
            if isempty(R.chemicalSurWithDecay)
                R.chemicalSurWithDecay = R.initializeSur(R.chemicalSurWithDecayPath);
            end
            
            cs = R.chemicalSurWithDecay;
        end
        
        function s = surWithDecay(R) % shortcut method/backwards compatibility
            s = R.chemicalSurWithDecay;
        end
        
        function p = prnPath(EBR, index)
            % Returns the path to the model run prn file. By default, the
            % 0-index prn file path is returned. Pass in the index to
            % return a different prn file (e.g. 1, for decay)
            
            if ~exist('index', 'var')
                index = 0; % Default is the 0 indexed .prn file
            end

            p = strcat(EBR.project.intermediatePath, '\', EBR.modelFileRoot, ['-consolidated-g', num2str(index), '.depomodtimeseries']);
        end
        
        function p = prn(EBR)
            % Returns an instance of Depomod.Outputs.PrnSeries representing
            % the 0-indexed prn file for the model run
            
            p = EBR.initializePrn(0);
        end
        
        function p = prnWithDecay(EBR)
            % Returns an instance of Depomod.Outputs.PrnSeries representing
            % the 1-indexed prn file for the model run, i.e. including
            % decay
            
            p = EBR.initializePrn(1);
        end
        
        function p = initializePrn(EBR, index)            
            if exist(EBR.prnPath(index), 'file') == 2
                p = Depomod.TimeSeries.createFromTimeSeriesFile(EBR.prnPath(index), 4); % column 4 in depomodtimeseries file
            else
                p = [];
                disp(['File: ', EBR.prnPath(index), ' does not exist.']);
            end
        end
        
        function tq = impliedTreatmentQuantity(EBR)
            % this outputs treatment quantity in grams
            massReleased    = EBR.massReleased;
            runDurationDays = EBR.runDurationDays;
            tq = Depomod.EmBZ.massReleased2MassTreated(massReleased,runDurationDays)*1000.0;
        end
        
        function tf = treatmentFactor(EBR)
            tf = Depomod.EmBZ.grams2Biomass(EBR.impliedTreatmentQuantity)/EBR.biomass;
        end
        
    end 
    
end