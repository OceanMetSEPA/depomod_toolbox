classdef Project < Depomod.Project
    
    properties (Constant = true)
        version = 2;
    end
    
    properties
        location@NewDepomod.PropertiesFile;
        bathymetry@NewDepomod.BathymetryFile
        flowmetry@NewDepomod.FlowmetryFile
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
                error('Requested project directory already exists. Not overwriting unless force = 1 option is used');
            elseif exist(namedProjectPath, 'dir')
                rmdir(namedProjectPath, 's');
            end
            
            templateProject = NewDepomod.Project.templateProject;
            P = templateProject.clone(path);            
            P.rename(name);
                        
            % refresh
            P = NewDepomod.Project.create(namedProjectPath);
            
            for r = 1:P.allRuns.size
                run = P.allRuns.item(r);
                runtimeFile = run.runtimeFile;

                runtimeFile.Runtime.modelConfigurationFile = ...
                    NewDepomod.Project.escapeFilePath([run.project.modelsPath, '\', run.modelFileRoot, '.depomodconfigurationproperties']);
                runtimeFile.Runtime.modelPhysicalFile = ...
                    NewDepomod.Project.escapeFilePath([run.project.modelsPath, '\', run.modelFileRoot, '.depomodphysicalproperties']);
                runtimeFile.Runtime.modelParametersFile = ...
                    NewDepomod.Project.escapeFilePath(run.modelPath);
                runtimeFile.Runtime.modelLocationFile = ...
                    NewDepomod.Project.escapeFilePath(run.project.locationPropertiesPath);
                
                runtimeFile.toFile;
            end
        end
        
        function p = templatePath()
            packageDir = what('+NewDepomod\');
            dirPathParts = strsplit(packageDir.path, '\');

            p = [strjoin(dirPathParts(1:end-1), '\'), '\Templates'];
        end
        
        function P = templateProject()
            P = NewDepomod.Project.create([NewDepomod.Project.templatePath, '\template']);
        end
        
        function outputString = escapeFilePath(inputString)
            outputString = strrep(strrep(inputString, '\', '/'), ':', '\\:');
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
        
        function p = privatePath(P)
            p = [P.depomodPath, '\private'];
        end
        
        function p = projectFilePath(P)
            p = [P.privatePath, '\depomod.prj'];
        end
        
        function p = runtimeFilePath(P)
            p = [P.modelsPath, '\depomod.prj'];
        end
        
        function p = locationPropertiesPath(P)
            % Need to look for file identifier (e.g. ext) rather than build
            % path with project name becaue this file is used to find the
            % project name!
            dirContents = dir(P.modelsPath);
            locationFile = find(cellfun(@(x) ~isempty(strfind(x, '.depomodlocationproperties')), {dirContents.name}));
            
            p = [P.modelsPath, '\', dirContents(locationFile).name];
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
                if exist(P.bathymetryDataPath, 'file')
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
        
        function f = get.flowmetry(P)
            if isempty(P.flowmetry)
                if exist(P.flowmetryFilePath, 'file')
                    P.flowmetry = NewDepomod.FlowmetryFile(P.flowmetryFilePath);
                else
                    error('No flow file found');
                end
            end

            f = P.flowmetry;
        end
        
        function clonedProject = clone(P, clonePath)
            % Function uses new parent directory as argument but appends
            % name as final residing directory for project. This makes it
            % similar to .exportFiles() function
            
            clonePath = [clonePath, '\', P.name];
            
            if isdir(clonePath)
              disp([clonePath, ' already exists. Removing...']);
              disp('    Removing...');

              rmdir(clonePath, 's');
            end

            disp('Copying Depomod files: ');
            disp(['    FROM: ', P.path]);
            disp(['    TO:   ', clonePath]);

            mkdir(clonePath);

            copyfile(P.path, clonePath, 'f');

            % write new directory path to location file   
            locationFilePath = Depomod.FileUtils.fileFinder(clonePath, {'.depomodlocationproperties'}, 'subDirectory', 1, 'type', 'or')

            Depomod.FileUtils.replaceInFile(locationFilePath, ...
                '^project\.directory=([\w\\\/\:\.]+)?$', ...
                ['project.directory=', NewDepomod.Project.escapeFilePath(clonePath)], ...
                'regexp',1 ...
            );

            % write new directory paths to depomod.prj file 
            filesToSub = [clonePath, '\depomod\private\depomod.prj']
            % location file path
            Depomod.FileUtils.replaceInFile(filesToSub, ...
                '^project\.locations\.path=([\w\\\/\:\.]+)?$', ...
                ['project.locations.path=', NewDepomod.Project.escapeFilePath(locationFilePath)], ...
                'regexp',1 ...
            );
            % project directory
            Depomod.FileUtils.replaceInFile(filesToSub, ...
                '^project\.directory=([\w\\\/\:\.]+)?$', ...
                ['project.directory=', NewDepomod.Project.escapeFilePath(clonePath)], ...
                'regexp',1 ...
            );

            clonedProject = Depomod.Project.create(clonePath);
            
            for r = 1:clonedProject.allRuns.size
                run = clonedProject.allRuns.item(r);
                % try this format
                Depomod.FileUtils.replaceInFile(run.runtimePath, ...
                    NewDepomod.Project.escapeFilePath(P.path), ...
                    NewDepomod.Project.escapeFilePath(clonePath) ...
                );
            end
        end
                        
        function renamedProject = rename(P, name)
            
            oldName = P.name;
            newName = name;
            
            % change name in locations file
            Depomod.FileUtils.replaceInFile(P.locationPropertiesPath, ...
                '^project\.name=(\w+)?$', ...
                ['project.name=', newName], ...
                'regexp',1 ...
            );     
            
            % change project root directory name in locations file
            Depomod.FileUtils.replaceInFile(P.locationPropertiesPath, ...
                '^project\.directory=([\w\\\/\:\.]+)?$', ...
                ['project.directory=' NewDepomod.Project.escapeFilePath(strrep(P.path, oldName, newName))], ...
                'regexp',1 ...
            );

            % change name in project file
            Depomod.FileUtils.replaceInFile(P.projectFilePath, ...
                '^project\.name=(\w+)?$', ...
                ['project.name=', newName], ...
                'regexp',1 ...
            );   
            % change root directory name in location file path in project file 
            Depomod.FileUtils.replaceInFile(P.projectFilePath, ...
                '^project\.locations\.path=([\w\\\/\:\.]+)?$', ...
                ['project.locations.path=', NewDepomod.Project.escapeFilePath(strrep(P.locationPropertiesPath, oldName, newName))], ...
                'regexp',1 ...
            );
            % change project root directory name in project file 
            Depomod.FileUtils.replaceInFile(P.projectFilePath, ...
                '^project\.directory=([\w\\\/\:\.]+)?$', ...
                ['project.directory=' NewDepomod.Project.escapeFilePath(strrep(P.path, oldName, newName))], ...
                'regexp',1 ...
            );
        
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
            
            for r = 1:renamedProject.allRuns.size
                run = renamedProject.allRuns.item(r);
                % try this format
                Depomod.FileUtils.replaceInFile(run.runtimePath, ...
                    NewDepomod.Project.escapeFilePath(P.path), ...
                    NewDepomod.Project.escapeFilePath(renamedProject.path) ...
                );
            end
            
            
        end
     
    end
    
end

