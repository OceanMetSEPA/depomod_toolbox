classdef Base < AutoDepomod.Run.Base
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
        
        function runNo = parseRunNumber(filename)
            runNo = AutoDepomod.Run.Base.parseRunNumber(filename, 2);
        end
        
        function [bool, sitename, type, tide, number, filetype, ext] = isValidConfigFileName(filename)
            [bool, sitename, type, tide, number, filetype, ext] = AutoDepomod.Run.Base.isValidConfigFileName(filename, 2);            
        end
        
        function [sitename, type, tide, number, filetype, ext] = cfgFileParts(filename)
            [sitename, type, tide, number, filetype, ext] = AutoDepomod.Run.Base.cfgFileParts(filename, 2);
        end
        
        function str = dispersionCoefficientReplaceString(dim,value)
            str = [num2str(value), '   k', dim,'  {m2/s'];
        end
    end
    
    % Instance
    
    properties (Constant = true, Hidden = true)
        FilenameRegex = '^(.+)\-(NONE|EMBZ|TFBZ)\-(S|N)\-(\d+)-(\w+)?\.(properties)$';
    end
    
    properties
        modelFile@AutoDepomod.V2.PropertiesFile;
        configurationFile@AutoDepomod.V2.PropertiesFile;
        inputsFile@AutoDepomod.V2.InputsPropertiesFile;
        iterationInputsFile@AutoDepomod.V2.InputsPropertiesFile;
        exportedTimeSeriesFile@AutoDepomod.V2.TimeSeriesFile;
        consolidatedTimeSeriesFile@AutoDepomod.V2.TimeSeriesFile;
        solidsSur@AutoDepomod.Sur.Benthic;
        carbonSur@AutoDepomod.Sur.Benthic;
        iterationRunNumber = [];
    end
    
    properties (Hidden = true)
        clearRunFileProperties = 0;
    end
    
    methods
        function R = Base(project, cfgFileName, varargin)
            R.project     = project;
            R.cfgFileName = cfgFileName; % this property is the -Model.properties file in V2
                                              
            R.runNumber = AutoDepomod.V2.Run.Base.parseRunNumber(R.cfgFileName);
            
            if isempty(R.runNumber)
                errName = 'AutoDepomod:Run:MissingRunNumber';
                errDesc = 'Cannot instantiate Run object. cfgFileName filename has unexpected format, cannot locate run number.';
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
        
        function name = configFileRoot(R)
            % Returns just the filename for the model run cfg file, omitting the extension
            [~, filename, ~] = fileparts(R.cfgFileName);
            name = strrep(filename, '-Model','');
        end
        
        function name = iterationRunFileRoot(R)
            name = strrep(R.configFileRoot, ['-', num2str(R.runNumber)], ['-', num2str(R.iterationRunNumber)]);
        end
        
        function p = modelPath(R)
            % Returns full path for the model run cfg file
            p = strcat(R.project.modelsPath, '\', R.cfgFileName);
        end
        
        function p = configPath(R)
            % Returns full path for the model run cfg file
            p = strcat(R.project.modelsPath, '\', R.configFileRoot, '-Configuration.properties');
        end
        
        function p = surPath(R, type, index)
            
            if ~exist('index', 'var')
                index = 0; % Default is the 0 indexed sur file
            end
            
            oldStylePath = strcat(R.project.intermediatePath, '\', R.iterationRunFileRoot, ['-g', num2str(index), '.sur']);
            newStylePath = strcat(R.project.intermediatePath, '\', R.iterationRunFileRoot, ['-', type, '-g', num2str(index), '.sur']);

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
            cpn = [R.project.cagesPath, '\', R.configFileRoot, '.xml'];
        end
         
        function i = inputsFilePath(R)
            i = [R.project.inputsPath, '\', R.configFileRoot, '-allCages.depomodinputsproperties'];
        end
         
        function i = iterationInputsFilePath(R)
            i = [R.project.intermediatePath, '\', R.iterationRunFileRoot, '-allCages.depomodinputsproperties'];
        end
        
        function c = consolidatedTimeSeriesFilePath(R)
            c = [R.project.intermediatePath, '\', R.iterationRunFileRoot, '-consolidated-g1.depomodtimeseries'];
        end
        
        function e = exportedTimeSeriesFilePath(R)
            e = [R.project.intermediatePath, '\', R.iterationRunFileRoot, '-consolidated-g1.depomodtimeseries'];
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
                R.modelFile = AutoDepomod.V2.PropertiesFile(R.modelPath);
            end
            
            m = R.modelFile;
        end

        function c = get.configurationFile(R)
            if isempty(R.configurationFile)
                R.configurationFile = AutoDepomod.V2.PropertiesFile(R.configPath);
            end
            
            c = R.configurationFile;
        end

        function i = get.inputsFile(R)
            if isempty(R.inputsFile) | R.clearRunFileProperties
                R.inputsFile = AutoDepomod.V2.InputsPropertiesFile(R.inputsFilePath);
            end
            
            i = R.inputsFile;
        end

        function i = get.iterationInputsFile(R)
            if isempty(R.iterationInputsFile) | R.clearRunFileProperties
                if exist(R.iterationInputsFilePath, 'file')
                    R.iterationInputsFile = AutoDepomod.V2.InputsPropertiesFile(R.iterationInputsFilePath);
                
                end
            end
            
            i = R.iterationInputsFile;
        end

        function e = get.exportedTimeSeriesFile(R)
            if isempty(R.exportedTimeSeriesFile) | R.clearRunFileProperties
                if exist(R.exportedTimeSeriesFilePath, 'file')
                    R.exportedTimeSeriesFile = AutoDepomod.V2.TimeSeriesFile(R.exportedTimeSeriesFilePath);
                end
            end
            
            e = R.exportedTimeSeriesFile;
        end

        function c = get.consolidatedTimeSeriesFile(R)
            if isempty(R.consolidatedTimeSeriesFile) | R.clearRunFileProperties
                if exist(R.consolidatedTimeSeriesFilePath, 'file')
                    R.consolidatedTimeSeriesFile = AutoDepomod.V2.TimeSeriesFile(R.consolidatedTimeSeriesFilePath);
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
            b = str2num(R.iterationInputsFile.FeedInputs.biomass);
        end
        
        function cmd = execute(R, varargin)
            % Invokes Depomod on the model run configuration, overwriting
            % any output files  
            
            if AutoDepomod.Java.isValidProject(R.project)
                dataPath = R.project.parentPath;
                
                jv = AutoDepomod.V2.Java;
                
                commandStringOnly = 0;
                useCurrentRelease = 0;
                modelDefaultsFilePath = '';
                singleRunOnly = 1;
                            
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
                    'modelParametersFile',    R.cfgFileName, ...
                    'modelLocationFile',      [R.project.name, '-Location.properties'], ...
                    'modelConfigurationFile', [R.configFileRoot, '-Configuration.properties'] ...
                    );
            else
               error('AutoDepomod:Java', ...
                    [ 'This is not a valid project for running the Java module. ', ...
                      'The parent directory must be named after the project.' ...
                      ]);
            end
        end
                 
        function initializeCages(R)
            R.cages = AutoDepomod.Layout.Site.fromXMLFile(R.cagesPath); 
        end
        
        function initializeLog(R)
            R.log = R.project.log(R.typeCode, R.tide); % R.iterationRunNumber presumably added at some point
        end
                
    end

end

