classdef (Abstract) Project < dynamicprops
    
    properties
        name char;
        path char;
        solidsRuns Depomod.Run.Collection;
        EmBZRuns Depomod.Run.Collection;
        TFBZRuns Depomod.Run.Collection;
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
            if isequal(path(end), '/') | isequal(path(end), '\')
                path(end) = [];
            end
            
            version = Depomod.Project.version(path);
 
            if version == 1
                P = AutoDepomod.Project(path);
            elseif version == 2
                P = NewDepomod.Project(path);   
            else
                error('Depomod:InvalidArgument',...
                    'The path specified is not a recognizable AutoDepomod Project.')
            end
        end
        
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
        
        function r = get.solidsRuns(P)
            % Lazy load to save time and memory
            if isempty(P.solidsRuns)
                P.solidsRuns = Depomod.Run.Collection(P, 'type', 'S');
            end

            r = P.solidsRuns;
        end
        
        function r = get.EmBZRuns(P)
            % Lazy load to save time and memory
            if isempty(P.EmBZRuns)
                P.EmBZRuns = Depomod.Run.Collection(P, 'type', 'E');
            end

            r = P.EmBZRuns;
        end
        
        function r = get.TFBZRuns(P)
            % Lazy load to save time and memory
            if isempty(P.TFBZRuns)
                P.TFBZRuns = Depomod.Run.Collection(P, 'type', 'T');
            end

            r = P.TFBZRuns;
        end
        
        function r = run(P, type, number)
           if isequal(type, 'S')
               r = P.solidsRuns.number(number);
           elseif isequal(type, 'E')
               r = P.EmBZRuns.number(number);
           elseif isequal(type, 'T')
               r = P.TFBZRuns.number(number);
           else
               r = [];
           end            
        end
        
        function ar = allRuns(P)
           ar = Depomod.Run.Collection(P);
        end
               
    end
    
end

