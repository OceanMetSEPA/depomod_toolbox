classdef (Abstract) Base < handle
    % Base class for wrapping functionality related to Depomod .sur files.
    % This class is intended to be subclassed with the introduction of a
    % rawDataValueCol property which is specific to the different types of
    % model runs Depomod provides (benthic, EmBZ, TFBZ).
    %
    %
    % DEPENDENCIES:
    %
    %  - Depomod/Outputs/Readers/readSur.m
    % 
    
    % Class.
    
     methods (Static = true)
         
        function sc = filename2Subclass(path, version)
            if version == 1
                if ~isempty(regexp(path, '-E-', 'ONCE')) || ~isempty(regexp(path, '-T-', 'ONCE'))
                    sc = 'Depomod.Sur.Residue';
                elseif ~isempty(regexp(path, '-BcnstFI-', 'ONCE'))
                    sc = 'Depomod.Sur.Solids';
                else
                    sc = [];
                end
            elseif version == 2
                if ~isempty(regexp(path, '-EMBZ-', 'ONCE')) || ~isempty(regexp(path, '-TFBZ-', 'ONCE'))
                    if ~isempty(regexp(path, '-solids-', 'ONCE')) || ~isempty(regexp(path, '-carbon-', 'ONCE'))
                        sc = 'Depomod.Sur.Solids';
                    else
                        sc = 'Depomod.Sur.Residue';
                    end
                elseif ~isempty(regexp(path, '-NONE-', 'ONCE'))
                    sc = 'Depomod.Sur.Solids';
                else
                    sc = [];
                end
            end
        end
        
        function s = fromFile(path, varargin)
            % Constructor method for creating instances of Depomod.Outputs.Sur.Base
            % using the appropriate subclass (BenthicSur, ResidueSur) based on the
            % passed in file name
            %
            % Usage:
            %
            %    sur = Depomod.Outputs.Sur.Base.fromFile(path, varargin)
            %
            %  where:
            %    path: absolute path to a Depomod .sur file
            %    
            %    varargin: optional specification of 'Easting' and
            %    'Northing' arguments describing the the southwest corner
            %    of the model domain. If these are passed in, the sur file
            %    grid is geo-referenced.
            %
            % Output:
            %
            %   sc: an instance of a subclass of Depomod.Outputs.Sur.Base
            %   corresponding the appropriate subclass (BenthicSur, ResidueSur).
            % 

            version    = 1;
            easting    = [];
            northing   = [];

            for i = 1:2:length(varargin) % only bother with odd arguments, i.e. the labels
              switch varargin{i}
                case 'Easting'
                  easting = str2double(varargin{i+1});
                case 'Northing'
                  northing = str2double(varargin{i+1});
                case 'subclass'
                  subclass = varargin{i+1};
                case 'version'
                  version = varargin{i+1};
              end
            end
            
            subclass = Depomod.Sur.Base.filename2Subclass(path, version);
            s = eval(subclass);
                        
            % Parse file
            s.path    = path;
            s.rawData = Depomod.FileUtils.Outputs.Readers.readSur(s.path); 
            
            % Find unique x and y grid nodes
            s.X = unique(s.rawData.xCoords);
            s.Y = unique(s.rawData.yCoords);
            
            % Create ax x by y data grid as a Z-coordinate for describing
            % the .sur data
%             s.Z = zeros(size(s.X,1),size(s.Y,1));
            s.Z = zeros(size(s.Y,1),size(s.X,1));

            % Get the list of .sur data values from the appropriate column
            % (defined on subclass)
            data = s.rawData.(s.rawDataValueCol);

            if version == 2
                s.Y = s.Y(end:-1:1); % Reverse both dimension vectors
                s.X = s.X(end:-1:1);
                
                % Iterate through data and assign to appropriate grid cell
                for i = 1:size(data)
                    value = data(i);

                    y = s.rawData.yCoords(i); 
                    x = s.rawData.xCoords(i);

                    row    = find(s.X == x);
                    column = find(s.Y == y);

                    s.Z(column,row) = value;
                end  
                
               s.GeoReferenced = 1;
            else
                % Iterate through data and assign to appropriate grid cell
                for i = 1:size(data)
                    value = data(i);

                    y = s.rawData.yCoords(i);
                    x = s.rawData.xCoords(i); 

                    row    = find(s.X == y); % reverse direction we want bottom left origin
                    column = find(s.Y == x); % reverse direction we want bottom left origin

                    s.Z(row, column) = value;
                end  

                % Determine basis for grid: local or geo-referenced
                %
                % If easting and northing passed in, convert the grid axes to
                % geographic context
                if ~isempty(easting) && ~isempty(northing)
                    s.geoReference(easting,northing);
                end
            end
        end
     end
    
    % Instance.
        
    properties
        path    = [];         % memoize file path
        rawData = [];         % memoize raw data structure
        interpolatedGrid = [] % placeholder for interpolated grid
        
        X = [];
        Y = [];
        Z = [];
        
        GeoReferenced = 0;
    end
        
    methods
        
        function S = Sur()
            % Constructor method.
            
            % Ensure base instances cannot be created, only subclasses
            if ~isprop(S,'rawDataValueCol')
                errName = 'Depomod:Sur:BaseClass';
                errDesc = 'Cannot instantiate using Sur base class. Instances must use subclasses which define a rawDataValueCol property';
                err = MException(errName, errDesc);
                
                throw(err)
            end
        end
        
        function c = clone(S)
            c = eval(class(S));
            
            c.path = S.path;
            c.rawData = S.rawData;
            c.interpolatedGrid = S.interpolatedGrid;
            c.X = S.X;
            c.Y = S.Y;
            c.Z = S.Z;
            c.GeoReferenced = S.GeoReferenced;
        end
        
        function newSur = add(S, otherSur)
            newSur = S.clone;
            
            if size(newSur.X) == size(otherSur.X) & size(newSur.Y) == size(otherSur.Y) & all(newSur.X == otherSur.X) & all(newSur.Y == otherSur.Y)
                newSur.Z = newSur.Z + otherSur.Z;
            else
                
                if newSur.X(1) < newSur.X(end)
                    swEasting  = min(newSur.X(1), otherSur.X(1));
                    swNorthing = min(newSur.Y(1), otherSur.Y(1));
                    neEasting  = max(newSur.X(end), otherSur.X(end));
                    neNorthing = max(newSur.Y(end), otherSur.Y(end));
                else
                    swEasting  = min(newSur.X(end), otherSur.X(end));
                    swNorthing = min(newSur.Y(end), otherSur.Y(end));
                    neEasting  = max(newSur.X(1), otherSur.X(1));
                    neNorthing = max(newSur.Y(1), otherSur.Y(1));
                end
                
                % Determine size of domain
                eastSize  = neEasting - swEasting;
                northSize = neNorthing - swNorthing;

                % Determine grid cell requirements in each direction
                eastCells  = ceil(eastSize/S.cellSizeX);
                northCells = ceil(northSize/S.cellSizeY);

                % Create new easterly nodes taking X m intervals from sw corner along combined east
                % length
                eastGrid = zeros(eastCells,1);

                for i = 0:(eastCells-1)
                    eastGrid(i+1) = swEasting + S.cellSizeX*i;
                end

                % Create new northerly nodes taking Y m intervals from sw corner along
                % combined north length
                northGrid = zeros(northCells,1);

                for i = 0:(northCells-1)
                    northGrid(i+1) = swNorthing + S.cellSizeY*i;
                end

                % Create new m x n grid for combined concentration values
                Z = zeros(northCells,eastCells);

                % Build new summed Z matrix
                for i = 1:(eastCells)
                    for j = 1:(northCells)
                        Z(j,i) = newSur.valueAt(eastGrid(i), northGrid(j)) + otherSur.valueAt(eastGrid(i), northGrid(j)); % swap east/north, i,j
                    end
                end
                
                
                % Use the new, extended east and north nodes as X/Y
                newSur.X = eastGrid;
                newSur.Y = northGrid;
                newSur.Z = Z;
            end
        end
        
        % Statistical functions...
        
        function [m, x, y] = max(S)
            % Returns the peak concentration described in the .sur file.
            %
            % Usage:
            %
            %    sur.max()
            %
            % OUTPUT:
            %    
            %    m: a double describing the peak concentration.
            %
            % EXAMPLES:
            %
            %    sur = Depomod.Outputs.Sur(path)
            %    sur.max
            %    ans =
            %      7.843660000000000e+02
            %

            [m, i] = max(S.Z(:));
            
            [yi, xi] = ind2sub(size(S.Z), i);
            x = S.X(xi);
            y = S.Y(yi);
        end
        
        function a = area(S, level)
            % Returns the area covered by a specified contour level as described by the .sur file
            % data.
            %
            % Usage:
            %
            %    sur.area(level)
            %
            % OUTPUT:
            %    
            %    a: a double describing the area covered by the given concentration.
            %
            % EXAMPLES:
            %
            %    sur = Depomod.Outputs.Sur(path)
            %
            %    sur.area
            %    ans =
            %      1000000 % no argument given - area of entire domain
            %
            %    sur.area(0.763)
            %    ans =
            %      2.357746604253981e+05
            %

            if ~exist('level','var')
                level = 0;
            end

            if level == 0
                a = S.domainSizeX * S.domainSizeY; % entire km2
            else
                
                c = S.contour(level);
                
                polygons = struct('XData', [], 'YData', []);
                
                i = 1;
                n = 0;
                
                while i <= size(c,2)
                    n = n + 1;
                    l = c(2,i);
                
                    polygons(n).XData = c(1,i+1:i+l);
                    polygons(n).YData = c(2,i+1:i+l);
                
                    i = i + l + 1;
                end
                
                a = 0;
                
                for i = 1:n                 
                    thisArea = polyarea(polygons(i).XData, polygons(i).YData);
                    a = a + thisArea;
                end
                
            end
        end
        
        function [v] = volume(S, level)
            % Returns the "volume" within a specified contour level as described by the .sur file
            % data. This includes the volune above the contour as well as
            % the pedestal below.
            %
            % Usage:
            %
            %    sur.volume(level)
            %
            % OUTPUT:
            %    
            %    v: a double describing the volume within the given concentration contour.
            %
            % EXAMPLES:
            %
            %    sur = Depomod.Outputs.Sur(path)
            %
            %    sur.volumne
            %    ans =
            %      1.755576625000000e+07 % no argument given - volume over entire domain
            %
            %    sur.area(0.763)
            %    ans =
            %       1.729338687500000e+07
            %

            function [ val ] = zero(c, level)
              if c >= level
                  val = c;
              else
                  val = 0;
              end
            end

            if exist('level','var')
                z = arrayfun(@(x) zero(x, level), S.Z);
            else
                z = S.Z;
            end
%             v=sum(sum(z)*25)*25
            v = trapz(S.Y, trapz(S.X, z, 2), 1);
        end
        
        function [v] = positiveVolume(S, level)
            % Returns the "volume" above a specified contour level as described by the .sur file
            % data.
            %
            % Usage:
            %
            %    sur.volume(level)
            %
            % OUTPUT:
            %    
            %    v: a double describing the area covered by the given concentration.
            %
            % EXAMPLES:
            %
            %    sur = Depomod.Outputs.Sur(path)
            %
            %    sur.volume
            %    ans =
            %      1.755576625000000e+07 % no argument given - volume over entire domain
            %
            %    sur.area(0.763)
            %    ans =
            %       1.729338687500000e+07
            %

            function [ val ] = subtractOrZero(c, level)
              if c >= level
                  val = c - level;
              else
                  val = 0;
              end
            end

            if exist('level','var')
                z = arrayfun(@(x) subtractOrZero(x, level), S.Z);
            else
                z = S.Z;
            end

            v = trapz(S.Y, trapz(S.X, z, 2), 1);
        end
        
        function [ave] = mean(S, level)
            % Returns the average concentration within a specified contour level as described by the .sur file
            % data.
            %
            % Usage:
            %
            %    sur.mean(level)
            %
            % OUTPUT:
            %    
            %    ave: a double describing the average concentration within the given contour concentration.
            %
            % EXAMPLES:
            %
            %    sur = Depomod.Outputs.Sur(path)
            %
            %    sur.mean(0.763)
            %    ans =
            %       73.347096943319883
            %

            ave = S.volume(level)/S.area(level);
        end
        
        function [gc] = numberOfGridCells(S)
            % Returns the total number of grid cells in the model domain
            
            [x,y] = size(S.Z);
            gc = x*y;
        end
        
        function S = interpolate(S)
            % Generates a griddedInterpolant object which is stored on the
            % interpolatedGrid property of the Sur instance. This supports
            % the valueAt() method.
            
            if S.X(2)-S.X(1) > 0 % handle ascending versus descending (v1/v2)
                [x, y] = ndgrid(S.X,S.Y);
                S.interpolatedGrid = griddedInterpolant(x, y, S.Z', 'cubic');
            else
                [x, y] = ndgrid(S.X(end:-1:1),S.Y(end:-1:1));
                S.interpolatedGrid = griddedInterpolant(x, y, S.Z(end:-1:1,end:-1:1)', 'cubic'); % transpose Z - griddedInterpolant and surf appear to handle origin/coords differently
            end
        end
        
        function [val, sd] = valueAt(S,x,y, varargin)
            % Returns the value at the passed in x,y position in the model
            % domain. This method uses the interpolatedGrid property to produced 
            % estimates between the grid nodes. If the interpolatedGrid
            % property is not already set, it is generated and set.
            %
            % I the replicates=true option is used, the returned value
            % constitutes an average of 5 values located around the
            % requested point. These values are located at the point itself
            % plus 4 points at a particular offset distance in the N, E, S
            % and W directions. By default the offset distance is 10 m.
            % This can be changed by passing in the *offset* argument with
            % the required offset distance for the replicates.
            
            if isempty(S.interpolatedGrid)
                S.interpolate;
            end
            
            samples = 1;
            offset = 10;
            
            for i = 1:2:length(varargin) % only bother with odd arguments, i.e. the labels
              switch varargin{i}
                case 'samples' % Set easting if passed in explicitly
                  samples = varargin{i+1};
                case 'offset' % Set easting if passed in explicitly
                  offset = varargin{i+1};
              end
            end  
                        
            if samples < 2
                val = S.interpolatedGrid(x,y);

                % The interpolation algorithm may produce a negative estimate.
                % This is not valid in our domain, so just set to 0 in that case.
                %
                % We also dont want to extrapolate outside the domain, set to 0
                % again in that case.
                if val < 0 | x < min(S.X) | x > max(S.X)| y < min(S.Y)| y > max(S.Y)
                    val = 0.0;
                end
            else
                sampleBearings = linspace(0,(2*pi),samples+1);
                sampleBearings = sampleBearings(1:end-1)';
                
                [sampleOffsetX, sampleOffsetY] = pol2cart(sampleBearings, repmat(offset, samples, 1));
                
                sampleData = zeros(samples,3);
                sampleData(:,1) = x + sampleOffsetX;
                sampleData(:,2) = y + sampleOffsetY;
                
                for s = 1:samples
                    sampleData(s,3) = S.valueAt(sampleData(s,1), sampleData(s,2));
                end
                sampleData
                val = mean(sampleData(:,3));
                sd  = std(sampleData(:,3));                
            end
        end
        
        function grad = gradientAt(S, x, y)
            % Return the gradient at the point given
            
            dx = 10;
            x_gradient = (S.valueAt(x+dx, y) - S.valueAt(x-dx, y))/2*dx;
            y_gradient = (S.valueAt(x, y+dx) - S.valueAt(x, y-dx))/2*dx;
            
            grad = x_gradient + y_gradient;
        end
        
        function x = domainSizeX(S)
            x = abs(S.X(1) - S.X(end));
        end
        
        function y = domainSizeY(S)
            y = abs(S.Y(1) - S.Y(end));
        end
        
        function x = cellSizeX(S)
            x = abs(mean(diff(S.X)));
        end
        
        function y = cellSizeY(S)
            y = abs(mean(diff(S.Y)));
        end
        
        function dist = distanceToValue(S, x, y, value)
            % Return the distance from a point on the grid to the nearest
            % place which has the given concentration/flux value. 
            
            % If the value is the same as the value at our point, the
            % distance is zero, no need for contours
            if value == S.valueAt(x,y)
                dist = 0;
            else
                % Otherwise, we generate a contour object for the value
                % under consideration. This provides a list of points equal
                % to the value. We can iterate through this list and find
                % the closest one
                
                % If the value is zero, we don't get a viable contour.
                % Nudge it up a little.
                if value == 0
                    value = value + 0.0000001;
                end
                
                % set max distance
                dist = sqrt(S.domainSizeX^2 + S.domainSizeY^2); % max distance in domain
                
                % Now, attempt to calculate distance from contour
                [c,h]  = S.contour(value);
                
                if ~isempty(c)

                    points = []; 
                    i = 1;

                    % parse the individual points out of the contour
                    % object
                    while i <= size(c,2)
                        for j = i+1:i+c(2,i)
                            points(1:2,end+1) = c(:,j);
                        end

                        i = i + c(2,i) + 1;
                    end

                    x_distances = abs(points(1,:) - x);
                    y_distances = abs(points(2,:) - y);

                    distances = sqrt(x_distances.^2 + y_distances.^2);

                    dist = min(distances);
                end

             end    
        end
        
        % Plot functions...
        
        function plot(S, varargin)
            % Returns a surf plot of the modelled values
            
            type = 'pcolor';
            
            for i = 1:2:length(varargin) % only bother with odd arguments, i.e. the labels
              switch varargin{i}
                case 'type' % Set easting if passed in explicitly
                  type = varargin{i+1};
              end
            end  
            
            figure;
                        
            switch type
                case 'pcolor'
                  pcolor(S.X, S.Y, S.Z);
                  shading flat;
                case 'surf'
                  surf(S.X, S.Y, S.Z);
                  shading interp;
                case 'contour'
                  contourf(S.X, S.Y, S.Z);
            end
            
            
            title(S.path);
        end
        
        function c = contour(S, level)
            % Returns a contour object associated with the passed in contour
            % level.
            
            c = contourc(S.X, S.Y, S.Z,[level level]);
        end
        
        function [c,h] = contourPlot(S, level)
            % Returns a contour plot associated with the passed in contour
            % level.
            %
            % The contour object is returned as output
            
            [c,h] = S.contour(level, 'plot', 1);
            grid on;
        end
        
        % Initializing functions...
        
        function geoReference(S, minE, minN)
            % Converts the X and Y grid node references from locally relative distances to geo-referenced
            % relative to the OS grid.
            %
            % Note, this function is not idempotent - it can only be used
            % once on a particular Sur instance.
            
            if S.GeoReferenced == 0;
                S.X = S.X + minE;
                S.Y = S.Y + minN;
                S.GeoReferenced = 1;
            end
        end
        
        function scale(S,factor)
            % Scales all Z values accounding to the passed in factor
            
            S.Z = S.Z.*factor;
        end
        
        function decay(S, rate, time)
            % Decays all Z values according to the decay rate and time
            % intervals passed in. The decay rate must be expressed in the
            % same units as the time interval. The decay rate does not
            % require a minus sign, i.e. it is assumed to be negative.
            
            fraction = exp(-rate*time);
            S.scale(fraction);
        end
        
    end % methods    
end

