classdef TransectSurvey < dynamicprops
    
    properties
        Transects = {};
    end
    
    methods (Static = true)
        function TS = createBasicOrthogonal(cages, varargin)
            distances = 0:25:200;
            
            for i = 1:2:length(varargin) % only bother with odd arguments, i.e. the labels
                switch varargin{i}
                    case 'distances' % 
                        distances = varargin{i+1};
                end
            end
            
            TS = Depomod.Survey.TransectSurvey;
            BB = cages.boundingBox;
            
            for s = 1:4
                [e,n] = BB.Sides{s}.midpoint;
                bearing = BB.Sides{s}.OutwardBearing;
                
                transect = Depomod.Survey.Transect.createFromDistances(...
                    distances, [e n], bearing)
                
                TS.addTransect(transect);
            end            
        end
        
        function TS = createRadial(cages, number, varargin)
            distances = 0:25:200;
            
            for i = 1:2:length(varargin) % only bother with odd arguments, i.e. the labels
                switch varargin{i}
                    case 'distances' % 
                        distances = varargin{i+1};
                end
            end
            
            TS = Depomod.Survey.TransectSurvey;
            BB = cages.boundingBox;
            
            % determine all bearings
            bearings = BB.MajorAxis + (0:(number-1)).*(360/number);
            bearings = mod(bearings+360,360);
            
            for t = 1:number
                bearing = bearings(t);
                
                [e,n] = BB.bearingIntersectCoordinates(bearing);
                    
                transect = Depomod.Survey.Transect.createFromDistances(...
                    distances, [e n], bearing);
                
                TS.addTransect(transect);
            end           
        end
        
        function TS = createOrthogonalRegularSpacing(cages, number, varargin)
            % regular spacing along every side
        end
        
        function TS = createRadialRegularSpacing(cages, number, varargin)
            % regular spacing around whole perimiter
        end
    end
        
    methods
        function TS = TransectSurvey()
        end
                
        function s = size(TS)
            s = numel(TS.Transects);
        end
        
        function addTransect(TS, transect)
            if isequal(class(transect), 'Depomod.Survey.Transect')
               
                transect.Survey = TS;
                TS.Transects{end+1} = transect;  
            else
                error('Argument must be an instance of the class Depomod.Survey.Transect');
            end
        end
        
        function p = logisticPassingPoints(TS)
            p = NaN(TS.size,2);
            
            for t = 1:TS.size
                [e,n] = TS.Transects{t}.logisticPassingPoint;
                p(t,1) = e;
                p(t,2) = n;
            end
        end
        
        function plot(TS, varargin)
            for t = 1:TS.size
                TS.Transects{t}.plot(varargin{:});
            end
        end
    end
    
end

