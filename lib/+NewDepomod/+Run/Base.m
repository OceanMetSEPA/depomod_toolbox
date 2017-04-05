classdef Base < Depomod.Run.Base
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
    %    model = AutoDepomod.V1.Run.Base(farm, modelFileName)
    %
    %  where:
    %    farm: an instance of AutoDepomod.Package
    %    
    %    modelFileName: is the filename of a .cfg file located within the
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
    %    run.modelFileName   
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
        
        function runNo = parseRunNumber(filename)
            
            [bool, ~, number, ~, ~, ~, ~, ~, ~] = NewDepomod.Run.Base.isValidConfigFileName(filename);
            
            if bool
                runNo = number;
            else
                runNo = [];
            end
        end
        
        function [bool, sitename, number, type, tide, output, gmodel, timestamp, ext] = isValidConfigFileName(filename)
            [sitename, number, type, tide, output, gmodel, timestamp, ext] = NewDepomod.Run.Base.cfgFileParts(filename);
            
            bool = ~isempty(sitename) && ...
                   ~isempty(number) && ...
                   ~isempty(type) && ...
                   isequal(ext, 'depomodmodelproperties');
                   
            varargout = cell(8,1);
            
            if bool
                varargout{1} = sitename;
                varargout{2} = number;
                varargout{3} = type;
                varargout{4} = tide;
                varargout{5} = output;
                varargout{6} = gmodel;
                varargout{7} = timestamp;
                varargout{8} = ext;
            end
        end
        
        function [sitename, number, type, tide, output, gmodel, timestamp, ext] = cfgFileParts(filename)
            [~,t]=regexp(filename, NewDepomod.Run.Base.FilenameRegex, 'match', 'tokens');
            
            if isempty(t)
                sitename  = [];
                number    = [];
                type      = [];
                tide      = [];
                output    = [];
                gmodel    = [];
                timestamp = [];
                ext       = [];
            else
                sitename  = t{1}{1};
                number    = t{1}{2};
                type      = t{1}{3};
                tide      = t{1}{4};
                output    = t{1}{5};
                gmodel    = t{1}{6};
                timestamp = t{1}{7};
                ext       = t{1}{8};
            end
        end
        
    end
    
    % Instance
    
    properties (Constant = true, Hidden = true)

        FilenameRegex = [...
            '^(\w+)', ...
            '\-?(\d+)?', ...
            '\-?(NONE|EMBZ|TFBZ)?', ...
            '\-?(S|N)?', ...
            '\-?(carbon|chemical|solids)?', ...
            '\-?(g0|g1)?', ...
            '\-?(\d+)?', ...
            '\.(depomodresultslog|depomodresultssur|depomodruntimeproperties|depomodcagesxml|depomodflowmetryproperties|depomodbathymetryproperties|depomodmodelproperties|depomodphysicalproperties|depomodlocationproperties|depomodconfigurationproperties)$' ...
        ];
    
    end
    
    properties
        modelFile@NewDepomod.PropertiesFile;
        physicalPropertiesFile@NewDepomod.PropertiesFile;
        configurationFile@NewDepomod.PropertiesFile;
        runtimeFile@NewDepomod.PropertiesFile;
        inputsFile@NewDepomod.InputsPropertiesFile;
        iterationInputsFile@NewDepomod.InputsPropertiesFile;
        exportedTimeSeriesFile@NewDepomod.TimeSeriesFile;
        consolidatedTimeSeriesFile@NewDepomod.TimeSeriesFile;
        solidsSur@Depomod.Sur.Solids;
        carbonSur@Depomod.Sur.Solids;
        iterationRunNumber = [];
        modelFileName = '';
    end
    
    properties (Hidden = true)
        clearRunFileProperties = 0;
    end
    
    methods
        function R = Base(project, modelFileName, varargin)
            R.project       = project;
            R.modelFileName = modelFileName; % this property is the -Model.properties file in V2
                                              
            R.runNumber = NewDepomod.Run.Base.parseRunNumber(R.modelFileName);
            
            if isempty(R.runNumber)
                errName = 'Depomod:Run:MissingRunNumber';
                errDesc = 'Cannot instantiate Run object. modelFileName has unexpected format, cannot locate run number.';
                err = MException(errName, errDesc);
                
                throw(err)
            end
            
            R.iterationRunNumber = R.runNumber;
            
            for i = 1:2:length(varargin)
              switch varargin{i}
                case 'iterationRunNumber'
                  R.iterationRunNumber = varargin{i+1};
              end
            end
        end
        
        function name = modelFileRoot(R)
            % Returns just the filename for the model run cfg file, omitting the extension
            [~, name, ~] = fileparts(R.modelFileName);
        end
        
        function name = iterationRunFileRoot(R)
            name = strrep(R.modelFileRoot, ['-', num2str(R.runNumber)], ['-', num2str(R.iterationRunNumber)]);
        end
        
        function p = modelPath(R)
            % Returns full path for the model run cfg file
            p = strcat(R.project.modelsPath, '\', R.modelFileName);
        end
        
        function p = configPath(R)
            % Returns full path for the model run cfg file
            p = strcat(R.project.modelsPath, '\', R.modelFileRoot, '.depomodconfigurationproperties');
        end
        
        function p = runtimePath(R)
            % Returns full path for the model run cfg file
            p = strcat(R.project.modelsPath, '\', R.modelFileRoot, '.depomodruntimeproperties');
        end
        
        function p = physicalPropertiesPath(R)
            % Returns full path for the model physical properties file
            p = strcat(R.project.modelsPath, '\', R.modelFileRoot, '.depomodphysicalproperties');
        end
        
        function p = logFilePath(R)
            % Returns full path for the model log file
            p = strcat(R.project.resultsPath, '\', R.modelFileRoot, '-', R.modelFile.Model.run.tide, '.depomodresultslog');
        end
        
        function p = surPath(R, type, varargin)
            
            gIndex      = 0; % Default is the 0 indexed sur file
            timestamp   = [];
            
            for i = 1:2:length(varargin)
              switch varargin{i}
                case 'g'
                  gIndex = varargin{i+1};
                case 't'
                  timestamp = varargin{i+1};
              end
            end
            
            oldStylePath = strcat(R.project.resultsPath, '\', R.iterationRunFileRoot, ['-g', num2str(gIndex), '.sur']);

            if isempty(timestamp)            
                newStylePath = strcat(R.project.resultsPath, '\', R.iterationRunFileRoot, ['-', R.modelFile.Model.run.tide, '-', type, '-g', num2str(gIndex), '.depomodresultssur']);
            else
                if timestamp < 1000
                    % can't be millsecond output measure
                    outputTimes = strsplit(R.configurationFile.Transports.recordTimes, ',');
                    timestamp = outputTimes{timestamp};
                else
                    timestamp = num2str(timestamp);
                end  
                newStylePath = strcat(R.project.resultsPath, '\', R.iterationRunFileRoot, ['-', R.modelFile.Model.run.tide, '-', type, '-g', num2str(gIndex), '-', timestamp, '.depomodresultssur']);
            end
            
            if exist(oldStylePath, 'file')
                p = oldStylePath;
            else
                p = newStylePath;
            end
        end
        
        function p = solidsSurPath(R)
            p = R.surPath('solids');
        end
        
        function p = carbonSurPath(R)
            p = R.surPath('carbon');
        end
         
        function cpn = cagesPath(R)
            cpn = [R.project.cagesPath, '\', R.project.name, '-' num2str(R.runNumber), '.depomodcagesxml'];
        end
         
        function i = inputsFilePath(R)
            i = [R.project.inputsPath, '\', R.modelFileRoot, '-allCages.depomodinputsproperties'];
        end
         
        function i = iterationInputsFilePath(R)
            i = [R.project.intermediatePath, '\', R.iterationRunFileRoot, '-allCages.depomodinputsproperties'];
        end
        
        function c = consolidatedTimeSeriesFilePath(R)
            c = [R.project.intermediatePath, '\', R.modelFileRoot, '-', R.modelFile.Model.run.tide, '-consolidated-g1.depomodtimeseries'];
        end
        
        function e = exportedTimeSeriesFilePath(R)
            e = [R.project.intermediatePath, '\', R.modelFileRoot, '-', R.modelFile.Model.run.tide, '-exported-g1.depomodtimeseries'];
        end
        
        function set.iterationRunNumber(R, number)
            R.iterationRunNumber = number;
            R.refreshRunFileproperties;
        end
        
        function refreshRunFileproperties(R)
            R.clearRunFileProperties = 1;
            
            R.inputsFile;
            R.iterationInputsFile;
            R.exportedTimeSeriesFile;
            R.consolidatedTimeSeriesFile;
            R.solidsSur;
            R.carbonSur;
            
            R.clearRunFileProperties = 0;
        end
            
        function m = get.modelFile(R)
            if isempty(R.modelFile)
                R.modelFile = NewDepomod.PropertiesFile(R.modelPath);
            end
            
            m = R.modelFile;
        end

        function c = get.configurationFile(R)
            if isempty(R.configurationFile)
                if ~exist(R.configPath, 'file')
                    template = NewDepomod.PropertiesFile(strcat(R.project.modelsPath, '\', R.project.name, '.depomodconfigurationproperties'));
                    template.toFile(R.configPath);
                end
                
                R.configurationFile = NewDepomod.PropertiesFile(R.configPath);
            end
            
            c = R.configurationFile;
        end
        
        function ppf = get.physicalPropertiesFile(R)
            if isempty(R.physicalPropertiesFile)
                if ~exist(R.physicalPropertiesPath, 'file')
                    R.physicalPropertiesFile = NewDepomod.PropertiesFile(strcat(R.project.modelsPath, '\', R.project.name, '.depomodphysicalproperties'));
                    R.physicalPropertiesFile.path = R.physicalPropertiesPath;
                    R.physicalPropertiesFile.toFile;
                else
                    R.physicalPropertiesFile = NewDepomod.PropertiesFile(R.physicalPropertiesPath);
                end
            end
            
            ppf = R.physicalPropertiesFile;
        end
            
        function r = get.runtimeFile(R)
            if isempty(R.runtimeFile)
                R.runtimeFile = NewDepomod.PropertiesFile(R.runtimePath);
            end
            
            r = R.runtimeFile;
        end

        function i = get.inputsFile(R)
            if isempty(R.inputsFile) | R.clearRunFileProperties
                R.inputsFile = NewDepomod.InputsPropertiesFile(R.inputsFilePath);
                R.inputsFile.run = R;
            end
            
            i = R.inputsFile;
        end

        function i = get.iterationInputsFile(R)
            if isempty(R.iterationInputsFile) | R.clearRunFileProperties
                if exist(R.iterationInputsFilePath, 'file')
                    R.iterationInputsFile = NewDepomod.InputsPropertiesFile(R.iterationInputsFilePath);
                
                end
            end
            
            i = R.iterationInputsFile;
        end

        function e = get.exportedTimeSeriesFile(R)
            if isempty(R.exportedTimeSeriesFile) | R.clearRunFileProperties
                if exist(R.exportedTimeSeriesFilePath, 'file')
                    R.exportedTimeSeriesFile = NewDepomod.TimeSeriesFile(R.exportedTimeSeriesFilePath);
                end
            end
            
            e = R.exportedTimeSeriesFile;
        end

        function c = get.consolidatedTimeSeriesFile(R)
            if isempty(R.consolidatedTimeSeriesFile) | R.clearRunFileProperties
                if exist(R.consolidatedTimeSeriesFilePath, 'file')
                    R.consolidatedTimeSeriesFile = NewDepomod.TimeSeriesFile(R.consolidatedTimeSeriesFilePath);
                end
            end
            
            c = R.consolidatedTimeSeriesFile;
        end
        
        function s = sur(R) % shortcut method/backwards compatibility
            s = R.solidsSur;
        end
        
        function ss = get.solidsSur(R)
            if isempty(R.solidsSur) | R.clearRunFileProperties
                if exist(R.solidsSurPath, 'file')
                    R.solidsSur = R.initializeSur(R.solidsSurPath);
                end
            end
            
            ss = R.solidsSur;
        end
        
        function cs = get.carbonSur(R)
            if isempty(R.carbonSur) | R.clearRunFileProperties
                if exist(R.carbonSurPath, 'file')
                    R.carbonSur = R.initializeSur(R.carbonSurPath);
                end
            end
            
            cs = R.carbonSur;
        end
        
        function b = biomass(R)
            % Returns the modelled biomass in t
            if isempty(R.iterationInputsFile)
                b = str2num(R.inputsFile.FeedInputs.biomass);
            else
                b = str2num(R.iterationInputsFile.FeedInputs.biomass);
            end
        end
        
        function rdd = runDurationDays(R)
            rdd = str2num(R.inputsFile.FeedInputs.numberOfTimeSteps)/24.0;
        end
        
        function cmd = execute(R, varargin)
            % Invokes Depomod on the model run configuration, overwriting
            % any output files  
            
            if Depomod.Java.isValidProject(R.project)
                dataPath = R.project.parentPath;
                
                jv = NewDepomod.Java;
                
                commandStringOnly = 0;
                useCurrentRelease = 0;
                modelDefaultsFilePath = '';
                singleRunOnly = 1;
                logOutput = 0;
                            
                for i = 1:2:length(varargin)
                  switch varargin{i}
                    case 'release'
                      release = varargin{i+1};
                    case 'commandStringOnly'
                      commandStringOnly = varargin{i+1};
                    case 'useCurrentRelease'
                      useCurrentRelease = varargin{i+1};
                    case 'modelDefaultsFilePath'
                      modelDefaultsFilePath = varargin{i+1};
                    case 'singleRunOnly'
                      singleRunOnly = varargin{i+1};
                    case 'logOutput'
                      logOutput = varargin{i+1};
                  end
                end
            
                if exist('release', 'var')
                    jv.release = release; 
                end
                
                cmd = jv.run(...
                    'singleRunOnly', singleRunOnly, ...
                    'useCurrentRelease', useCurrentRelease, ...
                    'commandStringOnly', commandStringOnly, ...
                    'modelDefaultsFilePath', modelDefaultsFilePath, ...
                    'siteName', R.project.name, ...
                    'dataPath', dataPath, ...
                    'modelParametersFile',    R.modelFileName, ...
                    'modelLocationFile',      [R.project.name, '-Location.properties'], ...
                    'modelConfigurationFile', [R.modelFileRoot, '-Configuration.properties'], ...
                    'logOutput', logOutput ...
                    );
            else
               error('Depomod:Java', ...
                    [ 'This is not a valid project for running the Java module. ', ...
                      'The parent directory must be named after the project.' ...
                      ]);
            end
        end
                 
        function initializeCages(R)
            R.cages = Depomod.Layout.Site.fromXMLFile(R.cagesPath); 
        end
        
        function initializeLog(R)
            R.log = NewDepomod.PropertiesFile(R.logFilePath); % R.iterationRunNumber presumably added at some point
        end
                
    end

end
