classdef Project < AutoDepomod.Project
    
    properties (Constant = true)
        version = 2;
    end
    
    properties
        location@AutoDepomod.V2.PropertiesFile;
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
        
        function p = flowmetryPath(P)
            p = [P.depomodPath, '\flowmetry'];
        end
        
        function p = bathymetryPath(P)
            p = [P.depomodPath, '\bathymetry'];
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
            lf = AutoDepomod.(['V', num2str(P.version)]).LogFile(lfpath);
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
        
        function p = gridgenIniPath(P)
           p = [P.bathymetryPath, '\', P.name, '.depomodbathymetrygridgenini'];
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
                AutoDepomod.V2.Currents.TimeSeries.toFile(...
                        P.SNSCurrents.(depths{i}),...
                        P.currentFilePath(depths{i}, 'S')...
                    );
                
                AutoDepomod.V2.Currents.TimeSeries.toFile(...
                        P.NSNCurrents.(depths{i}),...
                        P.currentFilePath(depths{i}, 'N')...
                    );
            end            
        end
     
    end
    
end

