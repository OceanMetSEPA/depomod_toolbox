classdef Project < Depomod.Project
    
    properties (Constant = true)
        version = 1;
    end
    
    properties 
        domain@AutoDepomod.DomainFile;
        bathymetry@AutoDepomod.BathymetryFile;
        SNSCurrents@Depomod.Currents.Profile;
        NSNCurrents@Depomod.Currents.Profile;
    end
    
    methods (Static = true)
        
        function sn = findSiteName(path)
            % Returns the site name associated with the passed in model
            % package root path. This name is based upon the standard .ini
            % file located in the package root directory.
            
            iniFileRegex = 'SEPA-(.*).ini'; % regex to identify .ini file and parse out site name
            files = Depomod.FileUtils.fileFinder(path);       % find all files in root directory
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
            P = AutoDepomod.Project(path);
        end
        
    end
    
    methods
        
        function P = Project(path)         
            P.name = AutoDepomod.Project.findSiteName(path);
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
            
            if isequal(type, 'S')
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
            lf = AutoDepomod.LogFile(lfpath);
        end
        
        function lf = solidsLog(P)
            % Returns an instance of AutoDepomod.LogFile representing the
            % package's benthic logfile
            
            lf = P.log('S');
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
        
        function d = get.domain(P)
            if isempty(P.domain)
                P.domain = AutoDepomod.DomainFile(P.gridgenIniPath);
            end
            
            d = P.domain;
        end    
        
        function b = get.bathymetry(P)
            % Lazy load to save time and memory
            if isempty(P.bathymetry)
                P.bathymetry = AutoDepomod.BathymetryFile(P.bathymetryDataPath);
                [E,N] = P.southWest;
                P.bathymetry.originE = E;
                P.bathymetry.originN = N;
            end

            b = P.bathymetry;
        end        
        
        function [a, b, c, d] = domainBounds(P)
            % Returns the model domain bounds described on the basis of the
            % minimum and maximum easting and northings. The order of the
            % outputs is min east, max east, min north, max north.
            
            [minE, maxE, minN, maxN] = Depomod.FileUtils.Inputs.Readers.readGridgenIni(P.gridgenIniPath);

            if nargout == 1
                a = [minE, maxE, minN, maxN];
            else
                a = minE;
                b = maxE;
                c = minN;
                d = maxN;
            end
        end
        
        function snsc = get.SNSCurrents(P)
            if isempty(P.SNSCurrents)
                P.initializeCurrents;
            end
            
            snsc = P.SNSCurrents;
        end
        
        function nsnc = get.NSNCurrents(P)
            if isempty(P.NSNCurrents)
                P.initializeCurrents;
            end
            
            nsnc = P.NSNCurrents;
        end
        
        function initializeCurrents(P)
            [P.SNSCurrents, P.NSNCurrents] = AutoDepomod.Currents.Profile.fromFile(...
                P.currentFilePath('s'), P.currentFilePath('m'), P.currentFilePath('b'));
            
            P.SNSCurrents.project = P;
            P.NSNCurrents.project = P;
        end
        
        function saveCurrents(P)
            depths = {'s','m','b'};
            
            for i = 1:length(depths)
                AutoDepomod.Currents.TimeSeries.toFile(...
                    P.SNSCurrents.(depths{i}),...
                    P.NSNCurrents.(depths{i}),...
                    P.currentFilePath(depths{i})...
                );
            end
        end
        
        function exportedProject = export(P, exportPath, varargin)

            runs = P.allRuns;
            
            for r = 1:runs.size
                exportedProject = runs.item(r).exportFiles(exportPath, varargin{:}); 
            end
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

            disp('Replacing absolute path references in files under new namespace...');

            % Replace all absolute path references within new tree to reflect new
            % location
            %
            % list all files within the new directory tree as a CELL ARRAY
            filesToSub = Depomod.FileUtils.fileFinder(clonePath, {'.cfg','.cfh','maj.dat','min.dat','min.ing','.log', '.inp','.inr','.out','.txt'}, 'sub', 1, 'type', 'or');

            for i = 1:length(filesToSub)        
              if ~isdir(filesToSub{i})
                disp(['    Updating ', filesToSub{i}, '...']);

                % Add trailing slash to substitution terms. This avoids 
                % ambiguity where the two paths share a common prefix (e.g.
                % /DATA) and prevents potential multiple concatenation
                %
                Depomod.FileUtils.replaceInFile(filesToSub{i}, [P.path, '\'], [clonePath, '\']); 
              end
            end

            disp(['Clone of ', P.name, ' completed.']);

            clonedProject = Depomod.Project.create(clonePath);
        end
    end
    
end

