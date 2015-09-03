classdef (Abstract) Base < handle
    % Wrapper class for a individual model runs in AutoDepomod. This class provides a
    % number of convenience methods for locating files and handling model runs and some outputs. 
    %
    % This class is not intended to be used directly but is intended to be subclassed with the 
    % introduction of a typeCode property (see Run.Benthic, Run.EmBZ, Run.TFBZ)
    %
    % Model objects are instantiated by passing in an instance of AutoDepomod.Package, together with
    % a .cfg filename.
    %
    % Usage:
    %
    %    model = AutoDepomod.V1.Run.Base(farm, cfgFileName)
    %
    %  where:
    %    farm: an instance of AutoDepomod.Package
    %    
    %    cfgFileName: is the filename of a .cfg file located within the
    %    /partrack directory of the project (and namespace if provided)
    % 
    %
    % EXAMPLES:
    %
    %    project = AutoDepomod.Data.Package('Gorsten');
    %    run  = AutoDepomod.V1.Run.Benthic(project, 'Gorsten-BcnstFI-N-1.cfg') % SUBCLASS
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
    %  - +AutoDepomod/+Data/root.m
    %  - +AutoDepomod/Package.m
    %  - +AutoDepomod/Logfile.m
    %  - +Depomod/+Outputs/Sur.m
    % 
    
    % Class
    
    methods (Static = true)
        
        function runNo = parseRunNumber(filename, version)
            % Returns the run number from a given filename. This can be
            % used to obtain the run number form most AutoDepomod files
            % including .cfg, .cfh, .sur, .grd, .prn, etc.
            %
            % Usage:
            %
            %    runNo = AutoDepomod.V1.Run.Base.parseRunNumber(filename)
            %
            % EXAMPLES:
            %
            %    AutoDepomod.V1.Run.Base.parseRunNumber('Gorsten-E-S-4.cfg')
            %    ans = 
            %        4
            %
            %    AutoDepomod.V1.Run.Base.parseRunNumber('Gorsten-E-S-5g1.prn')
            %    ans = 
            %        5
            %    
            
            [bool, ~, ~, ~, number, ~, ~] = AutoDepomod.(['V', num2str(version)]).Run.Base.isValidConfigFileName(filename);
            
            if bool
                runNo = number;
            else
                runNo = [];
            end
        end
        
        function [bool, varargout] = isValidConfigFileName(filename, version)
            % Returns true if the given filename is a valid AutoDepomod configuration or output filename.
            % If the filename is valid, the fileparts are returned as per
            % AutoDepomod.V1.Run.Base.cfgFileParts.
            %
            % Usage:
            %
            %    bool = AutoDepomod.V1.Run.Base.isValidConfigFileName(filename)
            %
            % EXAMPLES:
            %
            %    AutoDepomod.V1.Run.Base.isValidConfigFileName('Gorsten-E-S-5g1.sur')
            %    ans = 
            %        1
            %
            %    AutoDepomod.V1.Run.Base.isValidConfigFileName('Gorsten-ES5g1.prn')
            %    ans = 
            %        0
            %    
            
            [sitename, type, tide, number, filetype, ext] = AutoDepomod.(['V', num2str(version)]).Run.Base.cfgFileParts(filename);
            bool = ~isempty(sitename) && ~isempty(type) && ~isempty(tide) && ~isempty(number) && ~isempty(ext);
            varargout = cell(6,1);
            
            if bool
                varargout{1} = sitename;
                varargout{2} = type;
                varargout{3} = tide;
                varargout{4} = number;
                varargout{5} = filetype;
                varargout{6} = ext;
            end
        end
        
        function [sitename, type, tide, number, filetype, ext] = cfgFileParts(filename, version)
            % Returns the fileparts associated with AutoDepomod
            % configuration or output filenames. These
            % parts are as follows:
            %
            %   1. site name
            %   2. model run type (BcnstFI, E, T)
            %   3. Tidal context (S,N)
            %   4. Run number
            %   5. G-Model status (0,1,2,3)
            %   6. file extension
            %
            % Usage:
            %
            %    [sitename, type, tide, number, g, ext] = cfgFileParts(filename)
            %
            % EXAMPLES:
            %
            %    [sitename, type, tide, number, g, ext] = cfgFileParts('Gorsten-E-S-5g1.sur')
            %    sitename = 
            %        'Gorsten'
            %    type = 
            %        'E'
            %    tide = 
            %        'S'
            %    number = 
            %        5
            %    g = 
            %        'g1'
            %    ext = 
            %        'sur'
            %    
            
            [~,t]=regexp(filename, AutoDepomod.(['V', num2str(version)]).Run.Base.FilenameRegex, 'match', 'tokens');
            
            if isempty(t)
                sitename = [];
                type     = [];
                tide     = [];
                number   = [];
                filetype = [];
                ext      = [];
            else
                sitename = t{1}{1};
                type     = t{1}{2};
                tide     = t{1}{3};
                number   = t{1}{4};
                filetype        = t{1}{5};
                ext      = t{1}{6};
            end
        end
        
        function str = dispersionCoefficientReplaceString(dim,value)
            str = [num2str(value), '   k', dim,'  {m2/s'];
        end
    end
    
    % Instance
    
    properties
        project;     % owning modelling project
        cfgFileName; % filename of cfg file, indicates run number
        runNumber;   % model run number
        log;         % property for memoizing log information for this run, saves multiple calls
        cages;
        tide;
    end
    
    methods
        
        function bool = isBenthic(R)
            % Returns true if the model run is a benthic run
            bool = ~isempty(regexp(class(R), 'Benthic', 'ONCE'));
        end

        function bool = isEmBZ(R)
            % Returns true if the model run is a EmBZ run
            bool = ~isempty(regexp(class(R), 'EmBZ', 'ONCE'));
        end

        function bool = isTFBZ(R)
            % Returns true if the model run is a TFBZ run
            bool = ~isempty(regexp(class(R), 'TFBZ', 'ONCE'));
        end
        
        function t = get.tide(R)
            [~, ~, t, ~, ~, ~] = AutoDepomod.Run.Base.cfgFileParts(R.cfgFileName, R.project.version);
        end

        function l = get.log(R)
            % Returns a struct representing the model run log data
            if isempty(R.log)
                R.initializeLog;
            end
            
            l = R.log;
        end
        
        function c = get.cages(R)
            if isempty(R.cages)
               R.initializeCages; 
            end
            
            c = R.cages;
        end
        
        function s = initializeSur(R, surPath) 
            % Returns an instance of Depomod.Outputs.Sur representing the
            % model run sur file associated with the passed in index. The
            % index relates to the G-model status of the sur file, as
            % indicated by the 'g-' sequence in the filename.
            
            [e, n] = R.project.southWest;
            version = R.project.version;
                        
            if ~isempty(e) && ~isempty(n) && ~isnan(e) && ~isnan(n)
                s = AutoDepomod.Sur.Base.fromFile(surPath, 'version', version, 'Easting', num2str(e), 'Northing', num2str(n));
            else
                s = AutoDepomod.Sur.Base.fromFile(surPath, 'version', version);
            end
        end
    end

end

