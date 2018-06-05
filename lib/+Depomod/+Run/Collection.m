classdef Collection < dynamicprops
    % Wrapper class for a list of model runs. This class principally 
    % enables single runs to be accessed using chainable function
    % invocations, e.g.
    %
    %   project = AutoDepomod.Package('Gorsten', 'c:\path\path\');
    %   project.runs.item(2)    - by position in list
    %   project.runs.number(10) - by run number
    %
    % The optional 'type' argument allows specific model types to be
    % filtered
    %
    % Usage:
    %
    %    runs = AutoDepomod.Collection(project, varargin);
    % 
    %
    % EXAMPLES:
    %
    %    project = AutoDepomod.Package('Gorsten', 'c:\path\path\');
    %    runs = AutoDepomod.V1.Run.Collection(project)
    %    runs.type    
    %      >> ans = 
    %      []
    %
    %    runs.item(1)   
    %      >> ans = 
    %      [1x1 AutoDepomod.V1.Run.Benthic]
    %
    %    runs.item(5)   
    %      >> ans = 
    %      [1x1 AutoDepomod.V1.Run.EmBZ]
    %
    %    runs = AutoDepomod.V1.Run.Collection(project, 'type', 'E')
    %    runs.type    
    %      >> ans = 
    %      'E'
    %
    %    runs.item(1)   
    %      >> ans = 
    %      [1x1 AutoDepomod.V1.Run.EmBZ]
    %
    %
    % DEPENDENCIES:
    %
    %  - +AutoDepomod/Package.m
    %  - +AutoDepomod/+Run/Base.m
    %  - +AutoDepomod/+Run/Benthic.m
    %  - +AutoDepomod/+Run/EmBZ.m
    %  - +AutoDepomod/+Run/TFBZ.m
    %  - +AutoDepomod/+Run/Chemical.m
    %  - +AutoDepomod/+Run/initializeAsSubclass.m
    % 
    properties
        project;
        type;
        filenames = {}
        labels    = {}
        numbers   = []
        list = {};
    end
    
    methods
        function C = Collection(project, varargin)
            % Constructor method for AutoDepomod.Run.Collection. Requires
            % an instance of AutoDepomod.Package and an optional 'type'
            % argument.
            %            
            
            % memoize the associated project
            C.project = project; 
            
            % Determine whether a particular type of run is required and
            % store in the .type property. Otherwise, leave it empty.
            %
            %  E = EmBZ
            %  T = TFBZ
            %  S = Solids
            %            
            C.type    = [];
            
            for i = 1:length(varargin)
              switch varargin{i}
                case 'type'
                  C.type = varargin{i + 1};
              end
            end
            
            C.refresh;
        end
        
        function refresh(C)
            C.filenames = {};
            C.numbers = [];
            C.labels  = {};
            C.list = {};
                
            typeString = C.type; % filename indicator of model run type 

            % Look in the /partrack directory of the project for files with
            % the extension .cfg. Filter these according to type if
            % necessary.
            
            if C.project.version == 1
                path = C.project.partrackPath;
                searchTerms = '.cfg';
            else
                path = C.project.modelsPath;
                searchTerms = '.depomodmodelproperties';
            end

            if ~isempty(C.type)
              % If a require type exists we add the appropriate term to the
              % search terms when identifying files
              if C.project.version == 1
                  if isequal(char(C.type), 'S');
                      % If the required type is benthic (B) then use the
                      % standard filename descriptor BcnstFI in the search
                      % terms
                      typeString = 'BcnstFI'; 
                  end
                  
                  searchTerms = {searchTerms, strcat('-', typeString, '-')};
              else
                  if isequal(char(C.type), 'S');
                      typeString = 'NONE'; 
                  elseif isequal(char(C.type), 'E');
                      typeString = 'EMBZ'; 
                  elseif isequal(char(C.type), 'T');
                      typeString = 'TFBZ'; 
                  end
                  
                  searchTerms = {searchTerms, strcat('-', typeString, '.')};
              end

              
            end
            
            % Find files
            configFiles = Depomod.FileUtils.fileFinder(path, searchTerms , 'type', 'and', 'fullPath', 0);

            % fileFinder returns a cell array (of file paths) if there are multiple results
            % and a char object if there is only one. We need to handle this difference.
            %
            % Initialize a model run instance for each returned config
            % file.
            %
            if iscell(configFiles)
                C.filenames = configFiles;
                C.list = cell(length(configFiles),1);
            elseif ischar(configFiles)
                
                C.filenames{1} = configFiles;
                C.list{1} = Depomod.Run.initializeAsSubclass(C.project, configFiles);
            end
            
            C.generateRunLabels;
            % make alphbetical ascending
            [~,i] = sort(C.labels);
            C.labels    = C.labels(i);
            C.filenames = C.filenames(i);
            C.list      = C.list(i);
            
            C.generateRunNumbers;
        end
        
        function s = size(C)
            % Returns the size of the model run collection
            s = size(C.filenames,1);
        end
        
        function run = item(C, index)            
            if isempty(C.list{index})
                C.list{index} = Depomod.Run.initializeAsSubclass(C.project, C.filenames{index});
            end
            
            C.list{index}.number = C.numbers(index);
            run = C.list{index};     
        end
        
        function run = number(C, runNumber)
            run = C.item(find(C.numbers == runNumber));
        end
        
        function run = label(C, runLabel)
            run = C.item(find(cellfun(@(x) isequal(x, runLabel), C.labels)));
        end
        
        function generateRunLabels(C)
            v = C.project.version;
            
            if v == 1
                for rfn = 1:length(C.filenames)
                    AutoDepomod.Run.Base.parseRunNumber(C.filenames{rfn})
                    C.labels{rfn,1} = num2str(AutoDepomod.Run.Base.parseRunNumber(C.filenames{rfn}));
                end
            elseif v == 2
                for rfn = 1:length(C.filenames)
                    C.labels{rfn,1} = NewDepomod.Run.Base.parseRunLabel(C.filenames{rfn});
                end
            end
        end
        
        function generateRunNumbers(C)
            v = C.project.version;
            
            if v == 1
                for rfn = 1:length(C.filenames)
                    C.numbers(rfn,1) = str2num(C.labels{rfn,1}); 
                end
            elseif v == 2
                if C.isNumericallyLabelled
                    for rfn = 1:length(C.labels)
                        C.numbers(rfn,1) = str2num(C.labels{rfn});
                    end
                else
                    for rfn = 1:length(C.labels)
                        C.numbers(rfn,1) = rfn;
                    end
                end
            end
        end
        
        function bool = isNumericallyLabelled(C)
            [~,i]=cellfun(@str2num, C.labels, 'UniformOutput',0);
            bool = all(cell2mat(i));
        end
        
        function hrn = highestRunNumber(C)
            rns = sort(C.numbers);
            hrn = rns(end);
        end
        
        function fr = first(C)
            fr = C.item(1);
        end
        
        function lr = last(C)
            lr = C.number(C.highestRunNumber);            
        end
        
        function newRun = new(C, varargin)
            if C.size == 0
                error('Cannot create new run. No runs in collection to use as template');
            elseif C.project.version == 1
                error('Cannot create new run. Not supported for version 1 projects.')
            end
            
            highestRunNumber = C.highestRunNumber;
            newRunNumber     = highestRunNumber + 1;
            newRunLabel      = [];
            
            template = highestRunNumber;
            
            for i = 1:length(varargin)
              switch varargin{i}
                case 'template'
                  template = varargin{i + 1};
                case 'label'
                  newRunLabel = varargin{i + 1};
              end
            end
            
            if isnumeric(template)
                templateRun = C.number(template);
            else
                templateRun = C.label(template);
            end
            
            if isempty(newRunLabel)
                newRunLabel = num2str(newRunNumber)
            end
            
            if ismember(newRunLabel, C.labels)
                error('Cannot create new run. Supplied label already exists');
            end
            
            newModelPath  = regexprep(templateRun.modelPath, '-(\w+)\-(NONE|EMBZ|TFBZ)', ['-', newRunLabel, '-$2']);

            copyfile(templateRun.modelPath, newModelPath);

            copyfile(templateRun.cagesPath, regexprep(templateRun.cagesPath, '\-(\w+)', ['-', newRunLabel]));
            copyfile(templateRun.inputsFilePath, regexprep(templateRun.inputsFilePath, '-(\w+)\-(NONE|EMBZ|TFBZ)', ['-', newRunLabel, '-$2']));
            copyfile(templateRun.runtimePath, regexprep(templateRun.runtimePath, '-(\w+)\-(NONE|EMBZ|TFBZ)', ['-', newRunLabel, '-$2']));

            if exist(templateRun.configPath, 'file')
                copyfile(templateRun.configPath, regexprep(templateRun.configPath, '-(\w+)\-(NONE|EMBZ|TFBZ)', ['-', newRunLabel, '-$2']));
            end
            
            if exist(templateRun.physicalPropertiesPath, 'file')
                copyfile(templateRun.physicalPropertiesPath, regexprep(templateRun.physicalPropertiesPath, '-(\w+)\-(NONE|EMBZ|TFBZ)', ['-', newRunLabel, '-$2']));
            end

            newModelPaths = strsplit(newModelPath, '\');
            newModelFilename = newModelPaths{end};

            newRun = Depomod.Run.initializeAsSubclass(C.project, newModelFilename);
            newRun.number = newRunNumber;
            
            previousSize = C.size;
            
            % add to collection
            C.list{previousSize+1,1}      = newRun;
            C.filenames{previousSize+1,1} = newModelFilename;
            C.numbers(previousSize+1,1)   = newRunNumber;
            C.labels{previousSize+1,1}    = newRunLabel;
            
            % Update model file with number
            modelFile = newRun.modelFile;
            modelFile.Model.run.number = num2str(newRunNumber); % need to establish what tag and number are?
            modelFile.Model.run.tag    = newRunLabel;
            modelFile.toFile;
            
            % Update runtime file with paths
            runtimeFile = newRun.runtimeFile;

            runtimeFile.Runtime.modelParametersFile = newRun.modelPath;
            
            runtimeFile.Runtime.modelLocationFile = newRun.project.locationPropertiesPath;
            
            if exist(templateRun.configPath, 'file')
                runtimeFile.Runtime.modelConfigurationFile = newRun.configPath;                
            end
            
            if exist(templateRun.physicalPropertiesPath, 'file')
                runtimeFile.Runtime.modelPhysicalFile = newRun.physicalPropertiesPath;                
            end

            runtimeFile.toFile;
        end
        
        function optimise(C, varargin)
            initial = [];
            refine  = 0;
            target_iti = 10;
            run = C.last;
            
            coarseError      = 0.5;
            coarseStepFactor = 1.0;
            fineError        = 0.1;
            fineStepFactor   = 0.5;
            
            for i = 1:length(varargin)
              switch varargin{i}
                case 'initial'
                  initial = varargin{i + 1};
                case 'coarseError'
                  coarseError = varargin{i + 1};
                case 'coarseStepFactor'
                  coarseStepFactor = varargin{i + 1};
                case 'fineError'
                  fineError = varargin{i + 1};
                case 'fineStepFactor'
                  fineStepFactor = varargin{i + 1};
                case 'refine'
                  refine = varargin{i + 1};
                case 'targetITI'
                  target_iti = varargin{i + 1};
              end
            end
            
            config = [...
                coarseError, coarseStepFactor;...
                fineError, fineStepFactor;...
            ];
        
            phases = 1;
            
            if refine
                phases = 2;
            end
            
            if ~isempty(initial) 
                if any(ismember(superclasses(initial), 'Depomod.Run.Base'))
                    run = initial;
                else
                    run = C.number(initial);
                end
            end
            
            if ~exist(run.logFilePath, 'file')
                run.execute('runInBackground', 0);
            end
            
            if exist(run.logFilePath, 'file')
                iti = str2num(run.log.Eqs.benthic.iti)

                for i = 1:phases
                    err  = config(i,1);
                    step = config(i,2);

                    while abs(iti - target_iti) > err
                        scalingFactor = Depomod.ITI.toFlux(target_iti)/Depomod.ITI.toFlux(iti);
                        scalingFactor = (scalingFactor - 1.0)*step + 1

                        newRun = C.new;
                        newRun.inputsFile.scaleBiomass(scalingFactor);
                        newRun.inputsFile.toFile;

                        newRun.execute('runInBackground', 0);

                        run = C.last;
                        iti = str2num(run.log.Eqs.benthic.iti)
                    end

                end
            else
                error('NewDepomod:FailedRun', ['Run did not complete'])
            end
            
        end
        
    end
    
end

