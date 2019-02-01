classdef Sample < dynamicprops
    
    properties
        Value@double
        Unit@char
        Description@char
        Station@Depomod.Survey.Station
    end
    
    methods
        function S = Sample(val,varargin)
            S.Value = val;
            
            station = [];
            
            for i = 1:2:length(varargin) % only bother with odd arguments, i.e. the labels
                switch varargin{i}
                    case 'station' % 
                        station = varargin{i+1};
                end
            end 
            
            if ~isempty(station)
                S.Station = station;
            end
        end
        
    end
    
end

