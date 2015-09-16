classdef (Abstract) Project < dynamicprops
    
    properties
        name@char;
        path@char;
        benthicRuns@AutoDepomod.Run.Collection;
        EmBZRuns@AutoDepomod.Run.Collection;
        TFBZRuns@AutoDepomod.Run.Collection;
        SNSCurrents@AutoDepomod.Currents.Profile;
        NSNCurrents@AutoDepomod.Currents.Profile;
    end
    
     methods (Static = true)
        
        function v = version(path)
            projectContents = dir([path, '\depomod']);
            projectContents = {projectContents.name};
            
            if any(cellfun(@(x) isequal(x, 'models'), projectContents))
                v = 2;
            elseif any(cellfun(@(x) isequal(x, 'partrack'), projectContents))
                v = 1;
            else
                v = [];
            end
        end
        
        function P = create(path)
            version = AutoDepomod.Project.version(path);
 
            if version == 1
                P = AutoDepomod.V1.Project(path);
            elseif version == 2
                P = AutoDepomod.V2.Project(path);   
            else
                error('AutoDepomod:InvalidArgument',...
                    'The path specified is not a recognizable AutoDepomod Project.')
            end
        end
        
        function P = createFromDataDir(name, namespace)
            % Returns an instance of AutoDepomod.Project representing
            % the package of modelling files specified by name.
            %
            % By default, the modelling package found under the standard
            % path (C:\SEPA Consent\DATA) is used. Alternatively, a
            % namespace can be passed in as a second argument in which case
            % the standardized namespaced path is used (e.g. C:\SEPA
            % Consent\DATA-namespace)
            
            if exist('namespace', 'var')
                p = AutoDepomod.Data.root(namespace);
            else
                p = AutoDepomod.Data.root();
            end
            
            P = AutoDepomod.Project.create([p,'\',name]);
        end
        
%         function p = path2RootPath(fullPath)
%             % Converts a directory path for a location within a
%             % modelling package into the modelling packages root path, i.e.
%             % retains only the directory paths up to the /depomod
%             % directory
%             
%             p = strsplit(fullPath, {'\\DEPOMOD','\\depomod','\\Depomod'});
%             p = p{1};
%         end 
    end
    
    methods  
        
        function dn = directoryName(P)
            dirs = strsplit(P.path, '\\');
            dn = dirs{end};
        end
        
        function pp = parentPath(P)
            % Returns the parent path of the modelling package. 
            
            dirs = strsplit(P.path, '\\');
            pp   = strjoin(dirs(1:end-1), '\');
            
            if P.isRemotePath
                pp = ['\', pp];
            end
        end
        
        function bool = isRemotePath(P)
            bool = 0;
            
            if regexp(P.path, '^\\\\')
                bool = 1
            end
        end
        
        function p = depomodPath(P)
            % Returns the absolute path of the package's \depomod directory
            p = strcat(P.path(), '\depomod');
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
        
        function scaleCurrents(P, factor)
            P.SNSCurrents.scaleSpeed(factor);
            P.NSNCurrents.scaleSpeed(factor);
            
            P.saveCurrents;
        end
                
        function [a, b, c, d] = domainBounds(P)
            % Returns the model domain bounds described on the basis of the
            % minimum and maximum easting and northings. The order of the
            % outputs is min east, max east, min north, max north.
            
            [minE, maxE, minN, maxN] = AutoDepomod.FileUtils.Inputs.Readers.readGridgenIni(P.gridgenIniPath);

            if nargout == 1
                a = [minE, maxE, minN, maxN];
            else
                a = minE;
                b = maxE;
                c = minN;
                d = maxN;
            end
        end
               
        function [e, n] = southWest(P)
            % Returns the easting and northing of the model domain's south
            % west corner
            [e, ~, n, ~] = P.domainBounds;
        end
        
        function [e, n] = southEast(P)
            % Returns the easting and northing of the model domain's south
            % east corner
            [~, e, n, ~] = P.domainBounds;
        end
        
        function [e, n] = northEast(P)
            % Returns the easting and northing of the model domain's north
            % east corner
            [~, e, ~, n] = P.domainBounds;
        end
        
        function [e, n] = northWest(P)
            % Returns the easting and northing of the model domain's north
            % west corner
            [e, ~, ~, n] = P.domainBounds;
        end
        
        function [e, n] = centre(P)
            % Returns the easting and northing of the model domain's centre
            [minE, maxE, minN, maxN] = P.domainBounds();
            
            e = minE + (maxE-minE)/2.0;
            n = minN + (maxN-minN)/2.0;
        end
        
        function ms = meanCurrentSpeed(P, depth)
            ms = P.SNSCurrents.(depth).meanSpeed;
        end
        
        function r = get.benthicRuns(P)
            % Lazy load to save time and memory
            if isempty(P.benthicRuns)
                P.benthicRuns = AutoDepomod.Run.Collection(P, 'type', 'B');
            end

            r = P.benthicRuns;
        end
        
        function r = get.EmBZRuns(P)
            % Lazy load to save time and memory
            if isempty(P.EmBZRuns)
                P.EmBZRuns = AutoDepomod.Run.Collection(P, 'type', 'E');
            end

            r = P.EmBZRuns;
        end
        
        function r = get.TFBZRuns(P)
            % Lazy load to save time and memory
            if isempty(P.TFBZRuns)
                P.TFBZRuns = AutoDepomod.Run.Collection(P, 'type', 'T');
            end

            r = P.TFBZRuns;
        end
        
        function r = run(P, type, number)
           if isequal(type, 'B')
               r = P.benthicRuns.number(number);
           elseif isequal(type, 'E')
               r = P.EmBZRuns.number(number);
           elseif isequal(type, 'T')
               r = P.TFBZRuns.number(number);
           else
               r = [];
           end            
        end
        
        function clonedProject = clone(P, namespace)
            if P.isDataProject
                clonedProject = AutoDepomod.Data.clone(P, namespace);
            else
                error('AutoDepomod:DataError', ...
                    'Cloning can only be done on projects in the standard data directory');
            end
        end
        
        function bool = isDataProject(P)
            bool = 0;

            if ~isempty(regexp(P.path,[strrep(AutoDepomod.Data.root,'\','\\'),'[\w\-]*(\\)?'], 'ONCE'))
                bool = 1;
            end
        end
        
    end
    
end

