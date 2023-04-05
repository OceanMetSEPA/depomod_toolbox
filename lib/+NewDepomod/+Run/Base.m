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
        
        function label = parseRunLabel(filename)
            [bool, ~, label, ~, ~, ~, ~, ~, ~] = NewDepomod.Run.Base.isValidConfigFileName(filename);
            
            if ~bool
                label = [];
            end
        end
        
        function [bool, sitename, label, type, tide, output, gmodel, timestamp, ext] = isValidConfigFileName(filename)
            [sitename, label, type, tide, output, gmodel, timestamp, ext] = NewDepomod.Run.Base.cfgFileParts(filename);
            
            bool = ~isempty(sitename) && ...
                   ~isempty(label) && ...
                   ~isempty(type) && ...
                   isequal(ext, 'depomodmodelproperties');
                   
            varargout = cell(8,1);
            
            if bool
                varargout{1} = sitename;
                varargout{2} = label;
                varargout{3} = type;
                varargout{4} = tide;
                varargout{5} = output;
                varargout{6} = gmodel;
                varargout{7} = timestamp;
                varargout{8} = ext;
            end
        end
        
        function [sitename, label, type, tide, output, gmodel, timestamp, ext] = cfgFileParts(filename)
            [~,t]=regexp(filename, NewDepomod.Run.Base.FilenameRegex, 'match', 'tokens');
            
            if isempty(t)
                sitename  = [];
                label    = [];
                type      = [];
                tide      = [];
                output    = [];
                gmodel    = [];
                timestamp = [];
                ext       = [];
            else
                sitename  = t{1}{1};
                label    = t{1}{2};
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
            '\-?(\w+)?', ...
            '\-?(NONE|EMBZ|TFBZ)?', ...
            '\-?(S|N)?', ...
            '\-?(carbon|chemical|solids)?', ...
            '\-?(g0|g1)?', ...
            '\-?(\d+)?', ...
            '\.(depomodresultslog|depomodresultssur|depomodruntimeproperties|depomodcagesxml|depomodflowmetryproperties|depomodbathymetryproperties|depomodmodelproperties|depomodphysicalproperties|depomodlocationproperties|depomodconfigurationproperties)$' ...
        ];
    
    end
    
    properties
        modelFile NewDepomod.PropertiesFile;
        physicalPropertiesFile NewDepomod.PropertiesFile;
        configurationFile NewDepomod.PropertiesFile;
        runtimeFile NewDepomod.PropertiesFile;
        inputsFile NewDepomod.InputsPropertiesFile;
        iterationInputsFile NewDepomod.InputsPropertiesFile;
        exportedTimeSeriesFile NewDepomod.TimeSeriesFile;
        consolidatedTimeSeriesFile NewDepomod.TimeSeriesFile;
        solidsSur Depomod.Sur.Solids;
        carbonSur Depomod.Sur.Solids;
        label; % generalisation of run number
        iterationRunNumber = [];
        modelFileName = '';
        tide;
        log; 
        resultsPath;
    end
    
    properties (Hidden = true)
        clearRunFileProperties = 0;
    end
    
    methods
        function R = Base(project, modelFileName, varargin)
            R.project       = project;
            R.modelFileName = modelFileName; % this property is the -Model.properties file in V2
                                              
            R.label = NewDepomod.Run.Base.parseRunLabel(R.modelFileName);
            
            if isempty(R.label)
                errName = 'Depomod:Run:MissingRunLabel';
                errDesc = 'Cannot instantiate Run object. modelFileName has unexpected format, cannot locate run label.';
                err = MException(errName, errDesc);
                
                throw(err)
            end
            
%             R.iterationRunNumber = R.runNumber;
%             
%             for i = 1:2:length(varargin)
%               switch varargin{i}
%                 case 'iterationRunNumber'
%                   R.iterationRunNumber = varargin{i+1};
%               end
%             end
        end
        
        function name = modelFileRoot(R)
            % Returns just the filename for the model run cfg file, omitting the extension
            [~, name, ~] = fileparts(R.modelFileName);
        end
        
        function name = iterationRunFileRoot(R)
            name = strrep(R.modelFileRoot, ['-', num2str(R.label)], ['-', num2str(R.iterationRunNumber)]);
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
        
        function p = logFilePath(R, varargin)
            % Returns full path for the model log file
            
            resultsPath = R.resultsPath;
            
            for i = 1:2:length(varargin)
              switch varargin{i}
                case 'resultsPath'
                  resultsPath = varargin{i+1};
              end
            end
            
            p = strcat(resultsPath, '\', R.modelFileRoot, '-', R.modelFile.Model.run.tide, '.depomodresultslog');
        end
        
        function p = surPath(R, type, varargin)
            
            gIndex      = 0; % Default is the 0 indexed sur file
            timestamp   = [];
            resultsPath = R.resultsPath;
            
            for i = 1:2:length(varargin)
              switch varargin{i}
                case 'g'
                  gIndex = varargin{i+1};
                case 't'
                  timestamp = varargin{i+1};
                case 'resultsPath'
                  resultsPath = varargin{i+1};
              end
            end
            
            oldStylePath = strcat(resultsPath, '\', R.modelFileRoot, ['-g', num2str(gIndex), '.sur']);

            if isempty(timestamp)            
                newStylePath = strcat(resultsPath, '\', R.modelFileRoot, ['-', R.modelFile.Model.run.tide, '-', type, '-g', num2str(gIndex), '.depomodresultssur']);
            else
                if timestamp < 1000
                    % can't be millsecond output measure
                    outputTimes = strsplit(R.configurationFile.Transports.recordTimes, ',');
                    timestamp = outputTimes{timestamp};
                else
                    timestamp = num2str(timestamp);
                end  
                newStylePath = strcat(resultsPath, '\', R.modelFileRoot, ['-', R.modelFile.Model.run.tide, '-', type, '-g', num2str(gIndex), '-', timestamp, '.depomodresultssur']);
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
            cpn = [R.project.cagesPath, '\', R.project.name, '-' num2str(R.label), '.depomodcagesxml'];
        end
         
        function i = inputsFilePath(R)
            i = [R.project.inputsPath, '\', R.modelFileRoot, '-allCages.depomodinputsproperties'];
        end
         
        function i = iterationInputsFilePath(R)
            i = [R.project.intermediatePath, '\', R.iterationRunFileRoot, '-allCages.depomodinputsproperties'];
        end
        
        function c = consolidatedTimeSeriesFilePath(R)
            c = [R.project.intermediatePath, '\', R.modelFileRoot, '-', R.modelFile.Model.run.tide, '-consolidated-g1-1.depomodtimeseriesdata'];
        end
        
        function e = exportedTimeSeriesFilePath(R)
            e = [R.project.intermediatePath, '\', R.modelFileRoot, '-', R.modelFile.Model.run.tide, '-exported-g1-1.depomodtimeseriesdata'];
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
        
        function rp = get.resultsPath(R)
            if isempty(R.resultsPath)
                R.resultsPath = R.project.resultsPath;
            end
            
            rp = R.resultsPath;
        end
            
        function rp = setResultsPath(R, resultsPath)
            R.resultsPath = resultsPath;
            rp = R.resultsPath;
        end
            
        function clearResultsPath(R)
            R.resultsPath = [];
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
              
        function l = get.log(R)
            % Returns a struct representing the model run log data
            
            if isempty(R.log)
                R.log = NewDepomod.PropertiesFile(R.logFilePath);
            end
            
            l = R.log;
        end  
        
        function t = get.tide(R)
            if isempty(R.tide) | R.clearRunFileProperties
                R.tide = R.modelFile.Model.run.tide;
            end
            
            t = R.tide;
        end
        
        function useSpecificPhysicalFile(R) 
            runtimeFile = R.runtimeFile;
            runtimeFile.Runtime.modelPhysicalFile = [R.project.modelsPath, '\', R.modelFileRoot, '.depomodphysicalproperties'];
            runtimeFile.toFile;
        end
        
        function useGenericPhysicalFile(R)
            runtimeFile = R.runtimeFile;
            runtimeFile.Runtime.modelPhysicalFile = [R.project.modelsPath, '\', R.project.name, '.depomodphysicalproperties'];
            runtimeFile.toFile;
        end
        
        function useSpecificConfigurationFile(R)
            runtimeFile = R.runtimeFile;
            runtimeFile.Runtime.modelConfigurationFile = ...
                    [R.project.modelsPath, '\', R.modelFileRoot, '.depomodconfigurationproperties'];
            runtimeFile.toFile;
        end
        
        function useGenericConfigurationFile(R)
            runtimeFile = R.runtimeFile;
            runtimeFile.Runtime.modelConfigurationFile = [R.project.modelsPath, '\', R.project.name, '.depomodconfigurationproperties'];
            runtimeFile.toFile;
        end
                            
        function setRunDurationDays(R, days, varargin)
            consolidationDays = 0;
            
            for i = 1:2:length(varargin)
              switch varargin{i}
                case 'consolidationDays'
                  consolidationDays = varargin{i+1};
              end
            end
            
            % model
            particleConsolidationTime = 24.0*consolidationDays; 
            noHours = 24.0*days;

            model = R.modelFile;
            model.ModelTime.startTime = num2str(0);
            model.ModelTime.endTime = num2str(ceil((noHours + particleConsolidationTime) * 60 * 60 * 1000));  % milliseconds
            model.ModelTime.releasePeriod = num2str(ceil(noHours * 60 * 60 * 1000)); % milliseconds

            model.toFile;             
        end
        
        function syncRunDurationWithInputs(R, varargin)
            hours = str2num(R.inputsFile.FeedInputs.numberOfTimeSteps);
            
            R.setRunDurationDays(hours/24.0, varargin{:});
        end
        
        function syncCageID(R)            
            Inputs = R.inputsFile;
            Inputs.FeedInputs.uuid = R.cages.consolidatedCages.cage(1).inputsId;

            Inputs.toFile;
        end
        
        function clearOutputTimes(R)
            Config = R.configurationFile;
            Config.Transports.recordTimes='';
            Config.toFile;
        end

        function setDailyOutputTimes(R)
            R.setOutputTimes('resolution', 3600*24);
        end

        function setOutputTimesFromEnd(R, days, resolution)
            startTime = str2num(R.modelFile.ModelTime.endTime)/1000.0 - days*24*3600; 
            R.setOutputTimes('startTime', startTime, 'resolution', resolution);
        end

        function setOutputTimes(R, varargin) 
            ot = R.outputTimestamps;
            
            startTime  = str2num(R.modelFile.ModelTime.startTime)/1000.0; % ms to s
            endTime    = str2num(R.modelFile.ModelTime.endTime)/1000.0;   % ms to s
            resolution = 3*3600; % 3 hours
            
            for i = 1:2:length(varargin)
              switch varargin{i}
                case 'startTime'
                  startTime = varargin{i+1};
                case 'endTime'
                  endTime = varargin{i+1};
                case 'resolution'
                  resolution = varargin{i+1};
              end
            end
            
            if startTime == str2num(R.modelFile.ModelTime.startTime)/1000.0
                startTime = startTime + resolution;
            end
            
            if endTime == str2num(R.modelFile.ModelTime.endTime)/1000.0
                endTime = endTime - resolution;
            end
            
            samplingTimes = floor(startTime:resolution:endTime); % seconds
            % merge with existing, remove duplicates and sort ascending
            samplingTimes = sort(unique(horzcat(ot, samplingTimes))); % seconds
            % join together as a comma separate string 
            samplingString = strjoin(cellfun(@num2str,num2cell(samplingTimes),'UniformOutput',0),',');

            % instantiate the config file
            config = R.configurationFile;
            % and set these values
            config.Transports.recordTimes=samplingString;
            config.Transports.recordSurfaces = 'true';

            config.toFile;
        end
        
        function percent = percentComplete(R)
            % Checks for output files
           startTime  = str2num(R.modelFile.ModelTime.startTime)/1000.0; % ms to s
           endTime    = str2num(R.modelFile.ModelTime.endTime)/1000.0;   % ms to s
           ts = R.outputTimestamps;
           
           lastExistingOutput = startTime;
           
           for t = 1:length(ts)
               if exist(R.surPath('solids', 't', ts(t)), 'file')
                   lastExistingOutput = ts(t);
               else
                   break
               end
           end
           
           percent = 100*(lastExistingOutput-startTime)/(endTime-startTime);
        end
        
        function s = sur(R, varargin) % shortcut method/backwards compatibility
            type      = 'solids';
            
            verbose   = 1;
            gIndex    = 0;
            timestamp = [];
            resultsPath = R.resultsPath;
            
            for i = 1:2:length(varargin)
                
              switch varargin{i}
                case 'type'
                  type = varargin{i+1};
                case 'g'
                  gIndex = varargin{i+1};
                case 't'
                  timestamp = varargin{i+1};
                case 'resultsPath'
                  resultsPath = varargin{i+1};
                case 'verbose'
                  verbose = varargin{i+1};
              end
            end
            
            if length(timestamp) > 1
                s = {};
                
                for t = 1:length(timestamp)
                    if verbose
                        disp(['Reading sur file at ', num2str(timestamp(t))])
                    end
                    
                    s{t} = R.initializeSur(R.surPath(type, 'g', gIndex, 't', timestamp(t), 'resultsPath', resultsPath));
                end
            else
                s = R.initializeSur(R.surPath(type, 'g', gIndex, 't', timestamp, 'resultsPath', resultsPath));
            end
        end
                
        function s = meanSur(R, varargin)
            timestamp = [];
            
            for i = 1:2:length(varargin)
              switch varargin{i}
                case 't'
                  timestamp = varargin{i+1};
              end
            end
            
            if isempty(timestamp)
                timestamp = R.outputTimestamps();
                varargin{end+1} = 't';
                varargin{end+1} = timestamp;
            end
            
            if isempty(timestamp) | length(timestamp) < 2
                error('Insufficient output times specified')
            else
                surs = R.sur(varargin{:});

                s = surs{1};

                for t = 2:length(surs)
                    s = s.add(surs{t});
                end

                s.scale(1.0/length(surs));
            end
        end
        
        function t = outputTimestamps(R)
            config = R.configurationFile;
            
            try
                t = cellfun(@str2num, strsplit(config.Transports.recordTimes, ','));
            catch
                t = [];
            end
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
            rdd = str2num(R.modelFile.ModelTime.endTime)/(24.0*3600*1000);
        end
        
        function cmd = execute(R, varargin)
            % Invokes Depomod on the model run configuration, overwriting
            % any output files  
            
            jv = NewDepomod.Java;

            commandStringOnly = 0;
            singleRunOnly = 1;
            showConsoleOutput = 1;
            noSplash = 1;
            runInBackground = 1;

            for i = 1:2:length(varargin)
              switch varargin{i}
                case 'commandStringOnly'
                  commandStringOnly = varargin{i+1};
                case 'singleRunOnly'
                  singleRunOnly = varargin{i+1};
                case 'showConsoleOutput'
                  showConsoleOutput = varargin{i+1};
                case 'noSplash'
                  noSplash = varargin{i+1};
                case 'runInBackground'
                  runInBackground = varargin{i+1};
              end
            end

            cmd = jv.run(...
                'singleRunOnly', singleRunOnly, ...
                'commandStringOnly', commandStringOnly, ...
                'modelRunTimeFile',    R.runtimePath, ...
                'showConsoleOutput', showConsoleOutput, ...
                'nosplash', noSplash, ...
                'runInBackground', runInBackground ...
                );
 
        end
        
        function deleteRun(R, varargin)
            cages = 0;
            
            for i = 1:2:length(varargin)
              switch varargin{i}
                case 'cages'
                  cages = varargin{i+1};
              end
            end
            
            delete(R.modelPath);
            delete(R.runtimePath);
            delete(R.inputsFilePath);

            if exist(R.configPath, 'file')
                delete(R.configPath);
            end
            
            if exist(R.physicalPropertiesPath, 'file')
                delete(R.physicalPropertiesPath);
            end
            
            if cages
                delete(R.cagesPath);
            end
            
            if isequal(class(R), 'NewDepomod.Run.Solids')
                R.project.solidsRuns.refresh;
            elseif isequal(class(R), 'NewDepomod.Run.EmBZ')
                R.project.EmBZRuns.refresh
            elseif isequal(class(R), 'NewDepomod.Run.EmBZ')
                R.project.TFBZRuns.refresh
            end
        end
                 
        function initializeCages(R)
            R.cages = Depomod.Layout.Site.fromXMLFile(R.cagesPath); 
        end 
    end

end

