classdef Project < AutoDepomod.Project
    
    properties (Constant = true)
        version = 1;
    end
    
    properties 
        
    end
    
    methods (Static = true)
        
        function sn = findSiteName(path)
            % Returns the site name associated with the passed in model
            % package root path. This name is based upon the standard .ini
            % file located in the package root directory.
            
            iniFileRegex = 'SEPA-(.*).ini'; % regex to identify .ini file and parse out site name
            files = fileFinder(path);       % find all files in root directory
            file  = {};
            
            if ~isempty(files)
                % isolate the file(s) that match the .ini file regex
                file = files(cell2mat(cellfun(@(x) ~isempty(regexp(x, iniFileRegex, 'ONCE')), files, 'UniformOutput', false)),:);
            end
                        
            if ~isempty(file) && size(file,1) == 1
                % Use the .ini file regex to parse out the name and
                % assign to output
                [~, tokens] = regexp(file{1}, iniFileRegex, 'match', 'tokens');
                sn = cell2mat(tokens{1});
            else
                % If zero or many matched files exist, return nothing
                sn = [];
            end
        end
        
        function P = create(path)
            P = AutoDepomod.V1.Project(path);
        end
        
    end
    
    methods
        
        function P = Project(path)         
            P.name = AutoDepomod.V1.Project.findSiteName(path);
            P.path = path;  
        end
        
        function p = partrackPath(P)
            % Returns the absolute path of the package's \partrack directory
            p = strcat(P.depomodPath(), '\partrack');
        end
        
        function p = resusPath(P)   
            % Returns the absolute path of the package's \resus directory        
            p = strcat(P.depomodPath(), '\resus');           
        end
        
        function p = gridgenPath(P)
            p = strcat(P.depomodPath, '\gridgen');
        end
        
        function p = logFilePath(P, type)
            % Returns the absolute path of the package's logfile according
            % to the type passed in: 'B', 'E' or 'T'
            
            if isequal(type, 'B')
                p = [P.resusPath, '\', P.name, '-BENTHIC.log'];
            elseif isequal(type, 'E')
                p = [P.resusPath, '\', P.name, '-EMBZ.log'];
            elseif isequal(type, 'T')
                p = [P.resusPath, '\', P.name, '-TFBZ.log'];
            else
               p = [];
            end
        end
        
        function p = bathymetryDataPath(P)
            p =  [P.gridgenPath, '\', P.name, '-min.dat'];
        end
        
        function lf = log(P, type)
            % Returns an instance of AutoDepomod.LogFile representing the
            % package's logfile which corresponds to the passed in type, 'B', 'E' or 'T'
            
            lfpath = P.logFilePath(type);
            lf = AutoDepomod.(['V', num2str(P.version)]).LogFile(lfpath);
        end
        
        function lf = benthicLog(P)
            % Returns an instance of AutoDepomod.LogFile representing the
            % package's benthic logfile
            
            lf = P.log('B');
        end
        
        function lf = EmBZLog(P)
            % Returns an instance of AutoDepomod.LogFile representing the
            % package's EmBZ logfile
            
            lf = P.log('E');
        end
        
        function lf = TFBZLog(P)
            % Returns an instance of AutoDepomod.LogFile representing the
            % package's TFBZ logfile
            
            lf = P.log('T');
        end
        
        function p = currentFilePath(P, depth)
           p = [P.partrackPath, '\current-data\', P.name,'-NS-', depth,'.dat'];
        end
        
        function p = gridgenIniPath(P)
           p = [P.depomodPath,'\gridgen\',P.name,'.ini'];
        end
        
        function initializeCurrents(P)
            [P.SNSCurrents, P.NSNCurrents] = AutoDepomod.V1.Currents.Profile.fromFile(...
                P.currentFilePath('s'), P.currentFilePath('m'), P.currentFilePath('b'));
            
            P.SNSCurrents.project = P;
            P.NSNCurrents.project = P;
        end
        
        function saveCurrents(P)
            depths = {'s','m','b'};
            
            for i = 1:length(depths)
                AutoDepomod.V1.Currents.TimeSeries.toFile(...
                    P.SNSCurrents.(depths{i}),...
                    P.NSNCurrents.(depths{i}),...
                    P.currentFilePath(depths{i})...
                );
            end
        end
        
        function exportedProject = exportFiles(P, exportPath, varargin)
            runs = P.allRuns;
            
            for r = 1:runs.size
                exportedProject = runs.item(r).exportFiles(exportPath, varargin{:}); 
            end
        end
    end
    
end

