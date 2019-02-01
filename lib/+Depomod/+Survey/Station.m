classdef Station < dynamicprops
    
    properties
        Easting@double;
        Northing@double;
        Transect@Depomod.Survey.Transect;
        Distance@double;
        Samples = {};
    end
    
    
    methods (Static = true)
        function S = createFromPoints(e, n, varargin)
            % Pass in easting/northing to create station
            % Optional array of values
            
            S = Depomod.Survey.Station('easting', e, 'northing', n, varargin{:})
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
        
        function addSample(S, sample)
            S.Samples{end+1} = sample;
        end
        
        function s = size(S)
            s = numel(S.Samples);
        end
        
        function v = values(S)
            v = [];
            
            for s = 1:S.size
                v(s) = S.Samples{s}.Value;
            end
        end
        
        function m = mean(S)
           m = mean(S.values);  
        end
        
        % convenience
        function v = value(S)
            v = S.mean;
        end
    end
    
end

