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
        runFilenames = {}
        runNumbers = []
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
            C.runFilenames = {};
            C.list = {};
            C.runNumbers = [];
                
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
                C.runFilenames = configFiles;
                C.list = cell(length(configFiles),1);
            elseif ischar(configFiles)
                
                C.runFilenames{1} = configFiles;
                C.list{1} = Depomod.Run.initializeAsSubclass(C.project, configFiles);
            end
            
            C.generateRunNunmbers;
        end
        
        function s = size(C)
            % Returns the size of the model run collection
            s = size(C.runFilenames,1);
        end
        
        function run = item(C, index)            
            if isempty(C.list{index})
                C.list{index} = Depomod.Run.initializeAsSubclass(C.project, C.runFilenames{index});
            end
            
            run = C.list{index};     
        end
        
        function run = number(C, runNumber)
            run = C.item(find(C.runNumbers == runNumber));
        end
        
        function generateRunNunmbers(C)
            v = C.project.version;
            
            if v == 1
                for rfn = 1:length(C.runFilenames)
                    C.runNumbers(rfn,1) = AutoDepomod.Run.Base.parseRunNumber(C.runFilenames{rfn});
                end
            elseif v == 2
                for rfn = 1:length(C.runFilenames)
                    C.runNumbers(rfn,1) = NewDepomod.Run.Base.parseRunNumber(C.runFilenames{rfn});
                end
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
            
            template = highestRunNumber;
            
            for i = 1:length(varargin)
              switch varargin{i}
                case 'template'
                  template = varargin{i + 1};
              end
            end
            
            templateRun = C.number(template);
            
            newModelPath  = regexprep(templateRun.modelPath, '(\d+)\-(NONE|EMBZ|TFBZ)', [num2str(newRunNumber), '-$2']);
            copyfile(templateRun.modelPath, newModelPath);

            copyfile(templateRun.cagesPath, regexprep(templateRun.cagesPath, '\-(\d+)', ['-', num2str(newRunNumber)]));
            copyfile(templateRun.inputsFilePath, regexprep(templateRun.inputsFilePath, '(\d+)\-(NONE|EMBZ|TFBZ)', [num2str(newRunNumber), '-$2']));
            copyfile(templateRun.runtimePath, regexprep(templateRun.runtimePath, '(\d+)\-(NONE|EMBZ|TFBZ)', [num2str(newRunNumber), '-$2']));

            if exist(templateRun.configPath, 'file')
                copyfile(templateRun.configPath, regexprep(templateRun.configPath, '(\d+)\-(NONE|EMBZ|TFBZ)', [num2str(newRunNumber), '-$2']));
            end
            
            if exist(templateRun.physicalPropertiesPath, 'file')
                copyfile(templateRun.physicalPropertiesPath, regexprep(templateRun.physicalPropertiesPath, '(\d+)\-(NONE|EMBZ|TFBZ)', [num2str(newRunNumber), '-$2']));
            end

            newModelPaths = strsplit(newModelPath, '\');
            newModelFilename = newModelPaths{end};

            newRun = Depomod.Run.initializeAsSubclass(C.project, newModelFilename);
            
            previousSize = C.size;
            
            % add to collection
            C.list{previousSize+1,1}         = newRun;
            C.runFilenames{previousSize+1,1} = newModelFilename;
            C.runNumbers(previousSize+1,1)   = newRunNumber;
            
            % Update model file with number
            modelFile = newRun.modelFile;
            modelFile.Model.run.number = num2str(newRunNumber); % need to establish what tag and number are?
            modelFile.Model.run.tag    = num2str(newRunNumber);
            modelFile.toFile;
            
            % Update runtime file with paths
            runtimeFile = newRun.runtimeFile;
            
            runtimeFile.Runtime.modelParametersFile = ...
                strrep(strrep(newRun.modelPath, '\', '/'), ':', '\\:');
            
            runtimeFile.Runtime.modelLocationFile = ...
                strrep(strrep(newRun.project.locationPropertiesPath, '\', '/'), ':', '\\:');
            
            if exist(templateRun.configPath, 'file')
                runtimeFile.Runtime.modelConfigurationFile = ...
                    strrep(strrep(newRun.configPath, '\', '/'), ':', '\\:');                
            end
            
            if exist(templateRun.physicalPropertiesPath, 'file')
                runtimeFile.Runtime.modelPhysicalFile = ...
                    strrep(strrep(newRun.physicalPropertiesPath, '\', '/'), ':', '\\:');                
            end

            runtimeFile.toFile;
        end
        
    end
    
end

