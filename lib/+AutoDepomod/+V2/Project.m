classdef Project < AutoDepomod.Project
    
    properties (Constant = true)
        version = 2;
    end
    
    properties
        location@AutoDepomod.V2.PropertiesFile;
%         domain@AutoDepomod.V2.PropertiesFile; % now in one file -
%         bathymetry
        bathymetry@AutoDepomod.V2.BathymetryFile
    end
    
    methods (Static = true)
        
        function P = create(path)
            P = AutoDepomod.V2.Project(path);
        end
        
    end
    
    methods
        function P = Project(path)
            P.path     = path;  
            P.location = AutoDepomod.V2.PropertiesFile(P.locationPropertiesPath);
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
            locationFile = find(cellfun(@(x) ~isempty(strfind(x, '-Location')), {dirContents.name}));
            
            p = [P.modelsPath, '\', dirContents(locationFile).name];
        end
        
        function p = logFilePath(P, type, tide)
            % Returns the absolute path of the package's logfile according
            % to the type passed in: 'B', 'E' or 'T'
            
            if isequal(type, 'B')
                p = [P.resultsPath, '\', P.name, '-NONE-', tide, '.depomodrunlog'];
            elseif isequal(type, 'E')
                p = [P.resultsPath, '\', P.name, '-EMBZ-', tide, '.depomodrunlog'];
            elseif isequal(type, 'T')
                p = [P.resultsPath, '\', P.name, '-TFBZ-', tide, '.depomodrunlog'];
            else
               p = [];
            end
        end
        
        function lf = log(P, type, tide)
            % Returns an instance of AutoDepomod.LogFile representing the
            % package's logfile which corresponds to the passed in type, 'B', 'E' or 'T'
            
            lfpath = P.logFilePath(type, tide);
            lf = AutoDepomod.V2.PropertiesFile(lfpath);
        end
        
        function lf = benthicLog(P, tide)
            % Returns an instance of AutoDepomod.LogFile representing the
            % package's benthic logfile
            
            lf = P.log('B', tide);
        end
        
        function lf = EmBZLog(P, tide)
            % Returns an instance of AutoDepomod.LogFile representing the
            % package's EmBZ logfile
            
            lf = P.log('E', tide);
        end
        
        function lf = TFBZLog(P, tide)
            % Returns an instance of AutoDepomod.LogFile representing the
            % package's TFBZ logfile
            
            lf = P.log('T', tide);
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
                    P.bathymetry = AutoDepomod.V2.BathymetryFile(P.bathymetryDataPath);
                elseif exist(P.gridgenDataPath) & exist(P.gridgenIniPath)
                    P.bathymetry = AutoDepomod.V2.BathymetryFile.createFromGridgenFiles(P.gridgenIniPath,P.gridgenDataPath);
                else
                    error('No bathy files found')
                end
            end

            b = P.bathymetry;
        end
        
        function initializeCurrents(P)
            P.SNSCurrents = AutoDepomod.V2.Currents.Profile.fromFile(...
                P.currentFilePath('s', 'S'), P.currentFilePath('m', 'S'), P.currentFilePath('b', 'S'));
            P.NSNCurrents = AutoDepomod.V2.Currents.Profile.fromFile(...
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
            
            filesToSub = fileFinder(P.path, {oldName}, 'sub', 1, 'type', 'or');

            for i = 1:length(filesToSub)  
                fp = filesToSub{i}
                if ~isdir(fp)
                    [p,f,x] = fileparts(fp)

                    nameMatch = strfind(f, oldName)

                    if nameMatch
                        movefile(fp, [p, '\', strrep(f, oldName, newName),x], 'f')
                    end
                end

            end

            movefile(P.path,[P.parentPath, '\', newName])
            % 
            locationFile = [P.parentPath, '\', newName, '\depomod\models\', newName, '-Location.properties']
            AutoDepomod.FileUtils.replaceInFile(locationFile, oldName, newName);
            
            renamedProject = AutoDepomod.Project.create([P.parentPath, '\', newName]);
        end
     
    end
    
end

