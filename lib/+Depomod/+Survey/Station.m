classdef Station < dynamicprops
    
    properties
        Easting@double;
        Northing@double;
        Transect@Depomod.Survey.Transect;
        Distance@double;
        Samples@Depomod.Survey.Sample;
    end
    
    
    methods (Static = true)
        function S = createFromPoints(e, n, varargin)
            % Pass in easting/northing to create station
            % Optional array of values
            
            S = Depomod.Survey.Station('easting', e, 'northing', n, varargin{:});
        end
        
        function [new_e, new_n] = shiftPoint(e, n, varargin)
            x = [];
            y = [];
            bearing = [];
            distance = [];

            for i = 1:2:length(varargin) % only bother with odd arguments, i.e. the labels
                switch varargin{i}
                    case 'x' % 
                        x = varargin{i+1};
                    case 'y' % 
                        y = varargin{i+1};
                    case 'distance' % 
                        distance = varargin{i+1};
                    case 'bearing' % 
                        bearing = varargin{i+1};
                end
            end 

            if isempty(x) | isempty(y)
                if isempty(bearing) | isempty(distance)
                    error('Shifting stations requires either an x and y shift or a bearing and distance.')
                else
                    x = distance*sind(bearing);
                    y = distance*cosd(bearing);
                end
            end

            new_e = e + x;
            new_n = n + y;   
        end
    end
    
    methods
        function S = Station(varargin)            
            transect = [];
            distance = [];
            easting  = [];
            northing = [];
            values   = [];
            
            for i = 1:2:length(varargin) % only bother with odd arguments, i.e. the labels
                switch varargin{i}
                    case 'transect' % 
                        transect = varargin{i+1};
                    case 'easting' % 
                        easting = varargin{i+1};
                    case 'northing' % 
                        northing = varargin{i+1};
                    case 'distance' % 
                        distance = varargin{i+1};
                    case 'values' % 
                        values = varargin{i+1};
                end
            end 
            
            if ~isempty(transect)
                S.Transect = transect;
            end
            
            if ~isempty(values)
                for s = 1:numel(values)
                    S.addSample(Depomod.Survey.Sample(values(s), 'station', S));
                end
            end
            
            S.Easting  = easting;
            S.Northing = northing;
            S.Distance = distance;
        end
        
        function addSampleFromSur(S, sur)
            for s = 1:S.size
                S.Samples(s) = {};
            end

            value = sur.valueAt(S.Easting, S.Northing, 'samples', 9);
            S.Samples(1) = Depomod.Survey.Sample(value, 'station', S);
        end
        
        function addSample(S, sample)
            S.Samples(end+1) = sample;
        end
        
        function s = size(S)
            s = numel(S.Samples);
        end
        
        function v = values(S)
            v = [];
            
            for s = 1:S.size
                v(s) = S.Samples(s).Value;
            end
        end
        
        function m = mean(S)
           m = mean(S.values);  
        end
        
        % convenience
        function v = value(S)
            v = S.mean;
        end
        
        function shift(S, varargin)
            [new_e, new_n] = Depomod.Survey.Station.shiftPoint(S.Easting, S.Northing, varargin{:});
            
            S.Easting  = new_e;
            S.Northing = new_n;            
        end
        
    end
    
end

