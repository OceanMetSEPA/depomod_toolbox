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
            %  B = benthic
            %            
            C.type    = [];
            
            for i = 1:length(varargin)
              switch varargin{i}
                case 'type'
                  C.type = varargin{i + 1};
              end
            end
            
            typeString = C.type; % filename indicator of model run type 

            % Look in the /partrack directory of the project for files with
            % the extension .cfg. Filter these according to type if
            % necessary.
            
            if project.version == 1
                path = project.partrackPath;
                searchTerms = '.cfg';
            else
                path = project.modelsPath;
                searchTerms = '-Model';
            end

            if ~isempty(C.type)
              % If a require type exists we add the appropriate term to the
              % search terms when identifying files
              if project.version == 1
                  if isequal(char(C.type), 'B');
                      % If the required type is benthic (B) then use the
                      % standard filename descriptor BcnstFI in the search
                      % terms
                      typeString = 'BcnstFI'; 
                  end
              else
                  if isequal(char(C.type), 'B');
                      typeString = 'NONE'; 
                  elseif isequal(char(C.type), 'E');
                      typeString = 'EMBZ'; 
                  elseif isequal(char(C.type), 'T');
                      typeString = 'TFBZ'; 
                  end
              end

              searchTerms = {searchTerms, strcat('-', typeString, '-')};
            end

            % Find files
            configFiles = fileFinder(path, searchTerms , 'type', 'and', 'fullPath', 0);

            % fileFinder returns a cell array (of file paths) if there are multiple results
            % and a char object if there is only one. We need to handle this difference.
            %
            % Initialize a model run instance for each returned config
            % file.
            %
            if iscell(configFiles)
                C.list = cell(length(configFiles),1);

                for i = 1:length(configFiles)
                    C.list{i,1} = AutoDepomod.Run.initializeAsSubclass(project, configFiles{i});
                end
            elseif ischar(configFiles)
                C.list{1} = AutoDepomod.Run.initializeAsSubclass(project, configFiles);
            end
        end
        
        function s = size(C)
            % Returns the size of the model run collection
            s = size(C.list,1);
        end
        
        function run = item(C, index)
            % Returns the model run at the passed in index position in the
            % collection
            run = C.list{index};     
        end
        
        function run = number(C, runNumber)
            % Returns the model run corresponding to the passed in run
            % number
            run = {};
                        
            for i = 1:size(C.list, 1)
                if runNumber == str2double(C.list{i}.runNumber)
                    index = i;
                    break;
                end
            end
            
            if exist('index', 'var')
                run = C.list{index};
            end
        end
        
        function rns = runNumbers(C)
            rns = [];
            
            for r = 1:C.size
                rns(r) = str2num(C.list{r}.runNumber);
            end
        end
        
        function hrn = highestRunNumber(C)
            rns = sort(C.runNumbers);
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
            
            templateRun = C.number(highestRunNumber);
            
            newConfigPath = regexprep(templateRun.configPath, '(NONE|EMBZ|TFBZ)-(N|S)-(\d+)', ['$1-$2-', num2str(newRunNumber)]);
            newModelPath  = regexprep(templateRun.modelPath, '(NONE|EMBZ|TFBZ)-(N|S)-(\d+)', ['$1-$2-', num2str(newRunNumber)]);
            
            copyfile(templateRun.cagesPath, regexprep(templateRun.cagesPath, '(NONE|EMBZ|TFBZ)-(N|S)-(\d+)', ['$1-$2-', num2str(newRunNumber)]));
            copyfile(templateRun.modelPath, newModelPath);
            copyfile(templateRun.inputsFilePath, regexprep(templateRun.inputsFilePath, '(NONE|EMBZ|TFBZ)-(N|S)-(\d+)', ['$1-$2-', num2str(newRunNumber)]));
            copyfile(templateRun.configPath, newConfigPath);
            
            if exist(templateRun.physicalPropertiesPath, 'file')
                copyfile(templateRun.physicalPropertiesPath, regexprep(templateRun.physicalPropertiesPath, '(NONE|EMBZ|TFBZ)-(N|S)-(\d+)', ['$1-$2-', num2str(newRunNumber)]));
            end

            newModelPaths = strsplit(newModelPath, '\');
            newModelFilename = newModelPaths{end};

            newRun = AutoDepomod.Run.initializeAsSubclass(C.project, newModelFilename);

            C.list{C.size+1,1} = newRun;
            
            modelFile = newRun.modelFile;
            modelFile.Model.run.number=num2str(newRunNumber);
            modelFile.toFile;
        end
        
    end
    
end

