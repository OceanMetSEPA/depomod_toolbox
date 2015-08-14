classdef EmBZ < AutoDepomod.V1.Run.Chemical
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   EmBZ.m  $
% $Revision:   1.5  $
% $Author:   andrew.berkeley  $
% $Date:   May 29 2014 09:34:46  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
        surWithDecay;
    end
    
    methods      
        function EBR = EmBZ(project, cfgFileName)
            EBR = EBR@AutoDepomod.V1.Run.Chemical(project, cfgFileName);
        end  
        
        function p = prnPath(EBR, index)
            % Returns the path to the model run prn file. By default, the
            % 0-index prn file path is returned. Pass in the index to
            % return a different prn file (e.g. 1, for decay)
            
            if ~exist('index', 'var')
                index = 0; % Default is the 0 indexed .prn file
            end

            p = strcat(EBR.project.resusPath, '\', EBR.configFileRoot, ['g', num2str(index), '.prn']);
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
        
        function s = get.surWithDecay(EBR) 
            % Returns an instance of Depomod.Outputs.Sur representing the
            % 1-indexed model run sur file, i.e. including decay
            
            if isempty(EBR.surWithDecay)
               EBR.surWithDecay = EBR.initializeSur(1);
            end
            
            s = EBR.surWithDecay;
        end
        
        function p = initializePrn(EBR, index)
            % Generic method for initializing instances of
            % Depomod.Outputs.PrnSeries based on the passed in index.
            
            if exist(EBR.prnPath(index), 'file') == 2
                p = AutoDepomod.TimeSeries.createFromPrnFile(EBR.prnPath(index)); % 0 indexed file
            else
                p = [];
                disp(['File: ', EBR.prnPath(index), ' does not exist.']);
            end
        end
        
        function days = duration(EBR)
            % Returns the number of days represented by the model run (118,
            % 223)
            [~, t] = regexp(EBR.log.FeedFile, '\-(\d+)\.csv', 'match','tokens');            
            days = str2double(cell2mat(t{1}));
        end
        
    end 
    
end