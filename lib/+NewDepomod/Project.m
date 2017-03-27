classdef Project < Depomod.Project
    
    properties (Constant = true)
        version = 2;
    end
    
    properties
        location@NewDepomod.PropertiesFile;
%         domain@NewDepomod.PropertiesFile; % now in one file -
%         bathymetry
        bathymetry@NewDepomod.BathymetryFile
    end
    
    methods (Static = true)
        
        function P = create(path)
            P = NewDepomod.Project(path);
        end
        
        function P = createFromTemplate(path, name, varargin)
            force = 0;
            
            for i = 1:2:length(varargin)
              switch varargin{i}
                case 'force'
                  force = varargin{i+1};
              end
            end
            
            if isequal(path(end), '/') | isequal(path(end), '\')
                path(end) = [];
            end
            
            name = strrep(name, ' ', '_');
            
            % path is parent path
            if ~exist(path, 'dir')
                mkdir(path);
            end
            
            namedProjectPath = [path, '\', name];
            
            if exist(namedProjectPath, 'dir') & ~force
                error('Requested project directory already exists. Not overwriting unless force = 1 option is used')
            elseif exist(namedProjectPath, 'dir')
                rmdir(namedProjectPath, 's');
            end
            
            templateProject = NewDepomod.Project.templateProject

            P = templateProject.cloneFiles(path);
            
            P.rename(name);
            
            newDirs = {'ant','batch','intermediate','private','results','working'};
            
            for nd = 1:length(newDirs)
                 mkdir([namedProjectPath, '\depomod\', newDirs{nd}]); 
            end
                        
            % refresh
            P = NewDepomod.Project.create(namedProjectPath);
            
            % explicitly add new path reference where none existed in
            % template
            Depomod.FileUtils.replaceInFile(P.locationPropertiesPath, 'project.directory=', ['project.directory=', strrep(strrep(P.path, '\','\\'),':','\:')]);
        end
        
        function p = templatePath()
            packageDir = what('+NewDepomod\');
            dirPathParts = strsplit(packageDir.path, '\');

            p = [strjoin(dirPathParts(1:end-1), '\'), '\Templates'];
        end
        
        function P = templateProject()
            P = NewDepomod.Project.create([NewDepomod.Project.templatePath, '\template']);
        end
        
    end
    
    methods
        function P = Project(path)
            P.path     = path;  
            P.location = NewDepomod.PropertiesFile(P.locationPropertiesPath);
            P.name     = P.location.project.name;
        end
        
        function p = modelsPath(P)
            p = [P.depomodPath, '\models'];
        end
        
        function p = cagesPath(P)
            p = [P.depomodPath, '\cages'];
        end
        
        function p = flowmetryPath(P)
            p = [P.depomodPath, '\flowmetry'];
        end
        
        function p = bathymetryPath(P)
            p = [P.depomodPath, '\bathymetry'];
        end
        
        function i = inputsPath(P)
            i = [P.depomodPath, '\inputs'];
        end
        
        function p = intermediatePath(P)
            p = [P.depomodPath, '\intermediate'];
        end
        
        function p = resultsPath(P)
            p = [P.depomodPath, '\results'];
        end
        
        function p = locationPropertiesPath(P)
            dirContents = dir(P.modelsPath);
            locationFile = find(cellfun(@(x) ~isempty(strfind(x, '.depomodlocationproperties')), {dirContents.name}));
            
            p = [P.modelsPath, '\', dirContents(locationFile).name];
%             p = [P.modelsPath, '\', P.name, '.depomodlocationproperties'];
        end
        
        function p = currentFilePath(P, depth, tide)
           p = [P.flowmetryPath, '\', P.name,'-', upper(tide),'-', lower(depth),'.depomodflowmetryproperties'];
        end
        
        function p = flowmetryFilePath(P)
           p = [P.flowmetryPath, '\', P.name, '.depomodflowmetryproperties'];
        end
        
        function p = gridgenDataPath(P)
            p =  [P.bathymetryPath, '\', P.name, '.depomodbathymetrygridgendata'];
        end
        
        function p = gridgenIniPath(P)
           p = [P.bathymetryPath, '\', P.name, '.depomodbathymetrygridgenini'];
        end    
        
        function p = bathymetryDataPath(P)
            p =  [P.bathymetryPath, '\', P.name, '.depomodbathymetryproperties'];
        end
         
        function b = get.bathymetry(P)
            % Lazy load to save time and memory
            if isempty(P.bathymetry)
                if exist(P.bathymetryDataPath)
                    P.bathymetry = NewDepomod.BathymetryFile(P.bathymetryDataPath);
                elseif exist(P.gridgenDataPath) & exist(P.gridgenIniPath)
                    P.bathymetry = NewDepomod.BathymetryFile.createFromGridgenFiles(P.gridgenIniPath,P.gridgenDataPath);
                    P.bathymetry.toFile(project.bathymetryDataPath);
                else
                    error('No bathy files found');
                end
            end

            b = P.bathymetry;
        end
        
        function initializeCurrents(P)
            P.SNSCurrents = NewDepomod.Currents.Profile.fromFile(...
                P.currentFilePath('s', 'S'), P.currentFilePath('m', 'S'), P.currentFilePath('b', 'S'));
            P.NSNCurrents = NewDepomod.Currents.Profile.fromFile(...
                P.currentFilePath('s', 'N'), P.currentFilePath('m', 'N'), P.currentFilePath('b', 'N'));
                        
            P.SNSCurrents.project = P;
            P.NSNCurrents.project = P;
        end
                
        function saveCurrents(P)
            depths = {'s','m','b'};
            
            for i = 1:length(depths)
                P.SNSCurrents.(depths{i}).toFile(P.currentFilePath(depths{i}, 'S'));
                P.NSNCurrents.(depths{i}).toFile(P.currentFilePath(depths{i}, 'N'));
            end            
        end
        
        function renamedProject = rename(P, name)
            
            oldName = P.name;
            newName = name;
            
            % change absolute path in locations file
            Depomod.FileUtils.replaceInFile(P.locationPropertiesPath, oldName, newName);     
            
            % change all file names
            filesToSub = Depomod.FileUtils.fileFinder(P.path, {oldName}, 'subDirectory', 1, 'type', 'or');

            for i = 1:length(filesToSub)  
                fp = filesToSub{i};
                if ~isdir(fp)
                    [p,f,x] = fileparts(fp);

                    nameMatch = strfind(f, oldName);

                    if nameMatch
                        movefile(fp, [p, '\', strrep(f, oldName, newName),x], 'f');
                    end
                end

            end

            % change project name
            movefile(P.path,[P.parentPath, '\', newName]);
            
            renamedProject = NewDepomod.Project.create([P.parentPath, '\', newName]);
        end
     
    end
    
end

