classdef Transect < dynamicprops
    
    properties
        Origin     = []; % OSGB E/N
        UnitVector = []; % 1 m components
        Bearing    = []; % Degrees, clockwise, relative to north
        Stations   = {};
        Survey     = {};
        LogisticFit@Depomod.Stats.Logistic.Fit;
    end
    
    methods (Static = true)
        function T = createFromPoints(eastings, northings, varargin)
            % Pass in easting/northing to create transect
            %
            % Expects n size vectors of easting and northings
            % Optional n x m matrix of values
            % Distance and trasnect unit vector calculated  
            % Assumes first point is origin
            
            values = [];
            origin = [];
            
            for i = 1:2:length(varargin) % only bother with odd arguments, i.e. the labels
                switch varargin{i}
                    case 'values' % 
                        values = varargin{i+1};
                    case 'origin' % 
                        origin = varargin{i+1};
                end
            end
            
            T = Depomod.Survey.Transect;
            
            if isempty(origin)
                T.Origin = [eastings(1) northings(1)];            
            else
                T.Origin = origin;
            end
            
            for st = 1:numel(eastings)  
                if size(values,1) >= st
                    station = T.addStation('easting', eastings(st), 'northing', northings(st), 'values', values(st,:));
                else
                    station = T.addStation('easting', eastings(st), 'northing', northings(st));
                end
            end
            
            T.setStationDistances;
            T.setUnitVector;
        end
        
        function T = createFromDistances(distances, origin, bearing, varargin)
            % Pass in distances
            values  = [];
            
            for i = 1:2:length(varargin) % only bother with odd arguments, i.e. the labels
                switch varargin{i}
                    case 'values' % 
                        values = varargin{i+1};
                end
            end
            
            T = Depomod.Survey.Transect;
            T.Origin = origin;          
            T.Bearing = bearing;             
            
            for st = 1:numel(distances)
                if ~isempty(values)
                    theseValues = values(st);
                else
                    theseValues = [];
                end
                
                T.addStation('distance', distances(st), 'values', theseValues);
            end
            
            T.setUnitVector;
            T.setStationCoordinates
        end
    end
    
    methods
        
        function T = Transect()
        end
                
        function s = size(T)
            s = numel(T.Stations);
        end
        
        function station = addStation(T, varargin)
            % Either pass in a ready made station as first argument or with
            % 'station' option, OR pass in easting, northing and values to
            % dynamically create the station and samples.
            
            station  = [];
            distance = [];
            easting  = [];
            northing = [];
            values   = [];
            
            for i = 1:2:length(varargin) % only bother with odd arguments, i.e. the labels
                switch varargin{i}
                    case 'station' % 
                        station = varargin{i+1};
                    case 'distance' % 
                        distance = varargin{i+1};
                    case 'easting' % 
                        easting = varargin{i+1};
                    case 'northing' % 
                        northing = varargin{i+1};
                    case 'values' % 
                        values = varargin{i+1};
                end
            end
            
            if isequal(class(varargin{1}), 'Depomod.Survey.Station')
                station = varargin{1};
            elseif ~isempty(easting) & ~isempty(northing) 
                station = Depomod.Survey.Station('easting', easting, 'northing', northing, 'values', values);
            elseif ~isempty(distance)
                station = Depomod.Survey.Station('distance', distance, 'values', values);
            end
            
            station.Transect = T;
            T.Stations{end+1} = station;
        end
        
        function p = points(T)
            % easting/nothing
            
            p = [];
            
            for s = 1:T.size
               p(s,1) = T.Stations{s}.Easting;
               p(s,2) = T.Stations{s}.Northing;
            end
        end
        
        function d = distances(T)
            % distances in m
            d = [];
            
            for s = 1:T.size
               d(s) = T.Stations{s}.Distance;
            end
        end
        
        function v = values(T)
           v = [];
           
           for s = 1:T.size
               v(s) = T.Stations{s}.value;
           end
        end
        
        function [e,n] = coordinatesAtDistance(T, distance)
            e = T.Origin(1) + distance*T.UnitVector(1);
            n = T.Origin(2) + distance*T.UnitVector(2);            
        end
        
        function [m, c] = linearFitParameters(T)
            points = T.points;
            [P,S] = polyfit(points(:,1),points(:,2),1);
            
            m = P(1);
            c = P(2);
        end
        
        function setStationDistances(T)
            % Requires stations with easting and northings and an origin
            % distances are in m
            
            points = T.points;
            
            if isempty(T.Origin)
               warning('No origin set for transect. Assuming first station is origin');
               
               T.Origin = points(1,:)                
            end
            
            for s = 1:T.size
               T.Stations{s}.Distance = sqrt((T.Stations{s}.Easting-T.Origin(1))^2 + (T.Stations{s}.Northing-T.Origin(2))^2); 
            end
        end
        
        function setStationCoordinates(T)
            % Requires stations with distances and both an origin and a
            % bearing
            
            distances = T.distances;
            
            for s = 1:T.size
               [e,n] = T.coordinatesAtDistance(distances(s));
               
               T.Stations{s}.Easting  = e;
               T.Stations{s}.Northing = n;
            end
        end
        
        function setBearing(T, bearing)
           % ensures 0-360 degrees
           
           bearing = mod(bearing + 360, 360);
           T.Bearing = bearing;  
           T.setUnitVector;
        end
        
        function setOrigin(T, easting, northing)
            T.Origin = [easting, northing];
        end
        
        function setUnitVector(T)
            % unit vector lengths associated with a 1 m distance
            
            if ~isempty(T.Bearing)
                T.UnitVector = [sind(T.Bearing), cosd(T.Bearing)];
            else
                T.setBearingFromPoints;
            end
        end
        
        function setBearingFromPoints(T)
            % Relative to north
            
            % get slope
            m = T.linearFitParameters;
            
            % convert to degrees and relative to north
            bearing = 90 - atand(m);
            
            points = T.points;
            
            if points(end,1) < points(1,1)
                bearing = bearing + 180;
            end  
            
            if (points(end,2) > points(1,2)) & ...
                    (bearing > 90 & bearing < 270)
                bearing = bearing + 180;
            end  
            
            T.setBearing(bearing);
        end
        
        function i = firstPassingStation(T)
            i = [];
            idxs = T.values > 0.64;
            i = idxs(1);
        end
        
        function d = firstPassingDistance(T)
            d = T.distances(T.firstPassingStation);
        end
        
        function [e,n] = firstPassingPoint(T)
            [e,n] = T.coordinatesAtDistance(T.firstPassingStation);
        end
        
        function lf = logisticFit(T)
            if isempty(T.LogisticFit)
                x = T.distances;
                y = T.values;

                T.LogisticFit = Depomod.Stats.Logistic.Fit(x,y);
            end
            
            lf = T.LogisticFit;
        end
        
        function lpd = logisticPassingDistance(T, varargin)
            lf = T.logisticFit;
            
            lpd = lf.Curve.inverseSolution(0.64);
        end
        
        function [e,n] = logisticPassingPoint(T)
            [e,n] = T.coordinatesAtDistance(T.logisticPassingDistance);
        end
        
        function plot(T, varargin)
           
           % work on plotting options with varargin
            
           points = T.points;
           
           scatter3(...
                points(:,1), ...
                points(:,2), ...
                repmat(10,size(points,1),1), ...
                repmat(15,size(points,1),1), ...
                'g', 'filled')

%             text(points(:,1)+25,points(:,2),...
%                 arrayfun(@num2str, T.values, 'Uniform', false),'Color','w')
        end
    end
    
end

