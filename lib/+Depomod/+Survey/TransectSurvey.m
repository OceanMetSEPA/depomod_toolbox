classdef TransectSurvey < dynamicprops
    
    properties
        Transects@Depomod.Survey.Transect;
        Cages@Depomod.Layout.Site;
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
            TS.Cages = cages;
            BB = cages.boundingBox;
            
            for s = 1:4
                [e,n] = BB.Sides(s).midpoint;
                bearing = BB.Sides(s).OutwardBearing;
                
                transect = Depomod.Survey.Transect.createFromDistances(...
                    distances, [e n], bearing);
                
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
            TS.Cages = cages;
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
        
        function TS = createOrthogonalRegularSpacing(cages, spacing, varargin)
            % regular spacing along every side
            distances = 0:25:200;
            
            for i = 1:2:length(varargin) % only bother with odd arguments, i.e. the labels
                switch varargin{i}
                    case 'distances' % 
                        distances = varargin{i+1};
                end
            end
            
            TS = Depomod.Survey.TransectSurvey;
            TS.Cages = cages;
            BB = cages.boundingBox;
            
            for s = 1:4                
                bearing    = BB.Sides(s).OutwardBearing;
                sideLength = BB.Sides(s).length;
                
                transectOrigins = [];
                
                numberTransects = floor(sideLength/spacing);
                startDistance   = mod(sideLength,spacing)/2.0;

                for t = 1:numberTransects+1
                    [e,n] = BB.Sides(s).coordinatesAtDistance(...
                        startDistance + (t-1)*spacing); 

                    transectOrigins(t,1) = e; 
                    transectOrigins(t,2) = n;
                end
                
                for t = 1:size(transectOrigins)
                    e = transectOrigins(t,1);
                    n = transectOrigins(t,2);
                    
                    transect = Depomod.Survey.Transect.createFromDistances(...
                        distances, [e n], bearing);

                    TS.addTransect(transect);
                end
            end   
        end
        
        function TS = createRadialRegularSpacing(cages, number, varargin)
            % regular spacing around whole perimeter
            % might result in no transect on an individual side
            distances = 0:25:200;
            
            for i = 1:2:length(varargin) % only bother with odd arguments, i.e. the labels
                switch varargin{i}
                    case 'distances' % 
                        distances = varargin{i+1};
                end
            end
            
            TS = Depomod.Survey.TransectSurvey;
            TS.Cages = cages;
            BB = cages.boundingBox;
            
            pl = BB.perimeterLength;
            spacing = pl/number;
            
            for t = 1:number
                if t == 1
                    [e,n] = BB.Sides(2).midpoint;
                    bearing = BB.Sides(2).OutwardBearing;
                else
                    cumulativeDistance = (t-1)*spacing;
                    [sideIdx, sideDistance] = BB.perimeterDistance2SideDistance(cumulativeDistance);
                    
                    [e,n] = BB.Sides(sideIdx).coordinatesAtDistance(...
                        sideDistance); 
                    
                    mid_e = BB.Centre(1);
                    mid_n = BB.Centre(2);
                    
                    m = (n - mid_n)/(e - mid_e);
                    bearing = 90 - atand(m);
            
                    if e < mid_e
                        bearing = bearing + 180;
                    end  

                    if (n > mid_n) & ...
                            (bearing > 90 & bearing < 270)
                        bearing = bearing + 180;
                    end  
                    bearing = mod(bearing, 360);
                end
                
                transect = Depomod.Survey.Transect.createFromDistances(...
                    distances, [e n], bearing);
                
                TS.addTransect(transect);
            end  
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
                TS.Transects(end+1) = transect;  
            else
                error('Argument must be an instance of the class Depomod.Survey.Transect');
            end
        end
        
        function addOppositeTransect(TS, baseTransectIdx)
            baseTransect        = TS.Transects(baseTransectIdx);
            baseTransectBearing = baseTransect.Bearing;
            baseTransectSideIdx = TS.transectBoundingSide(baseTransect);
            
            newTransectBearing = baseTransectBearing + 180;
            newTransectBearing = mod(newTransectBearing + 360, 360);
            newTransectSideIdx = baseTransectSideIdx + 2;
            
            if newTransectSideIdx > 4
                newTransectSideIdx = baseTransectSideIdx - 2;
            end
            
            baseTransectOriginE = baseTransect.Origin(1);
            baseTransectOriginN = baseTransect.Origin(2);
            
            newTransectM    = (cosd(newTransectBearing)/sind(newTransectBearing));
            newTransectC    = baseTransectOriginN - newTransectM * baseTransectOriginE;
            newTransectX(1) = baseTransectOriginE;

            direction = 1;

            if newTransectBearing > 180 & newTransectBearing < 360
                direction = -1;
            end

            newTransectX(2) = baseTransectOriginE + direction * (9999 * cosd(atand(newTransectM)));
            newTransectY    = newTransectM.*newTransectX + newTransectC; 

            [e,n] = TS.Cages.boundingBox.Sides(newTransectSideIdx).lineIntersectPoint(newTransectX, newTransectY);
            
            transect = Depomod.Survey.Transect.createFromDistances(...
                baseTransect.distances, ...
                [e,n], ...
                newTransectBearing, ...
                'values', baseTransect.values ...
                );
            
            transect.ProxyTransectIdx = baseTransectIdx;
            TS.addTransect(transect);
        end
        
        function b = bearingToTransectOrigin(TS, transect)
            % relative to ite centre
            
            bb = TS.Cages.boundingBox;
            mid_e = bb.Centre(1);
            mid_n = bb.Centre(2);
            
            e = transect.Origin(1);
            n = transect.Origin(2);
            
            m = (n - mid_n)/(e - mid_e);
            b = 90 - atand(m);

            if e < mid_e
                b = b + 180;
            end  

            if (n > mid_n) & ...
                    (b > 90 & b < 270)
                b = b + 180;
            end  
            
            b = mod(b, 360);
        end
        
        function idx = transectBoundingSide(TS, transect)
            bb = TS.Cages.boundingBox;
            bearing = TS.bearingToTransectOrigin(transect);
            idx = bb.bearingIntersectSide(bearing);
        end
        
        function idxs = transectBoundingSides(TS)
            idxs = [];
            for t = 1:TS.size
                transect = TS.Transects(t);
                idxs(t) = TS.transectBoundingSide(transect);
            end
        end
        
        function idxs = nonTransectBoundingSides(TS)
            bs   = TS.transectBoundingSides;
            idxs = setdiff(1:4,bs);
        end
        
        function p = logisticPassingPoints(TS)
            p = NaN(TS.size,2);
            
            for t = 1:TS.size
                [e,n] = TS.Transects(t).logisticPassingPoint;
                p(t,1) = e;
                p(t,2) = n;
            end
        end
        
        function setValuesFromSur(TS, sur)
            for t = 1:TS.size
                TS.Transects(t).setValuesFromSur(sur);
            end
        end
        
        function CTS = clone(TS)
           % creates empty stations currently
           % i.e. only clones the points
           % useful for creating model counterpart
           
           CTS = Depomod.Survey.TransectSurvey;
           
           for t = 1:TS.size
               points = TS.Transects(t).points;
               transect = Depomod.Survey.Transect.createFromPoints(...
                   points(:,1), points(:,2));
               
               CTS.addTransect(transect);
           end
           
           CTS.Cages = TS.Cages;
        end
        
        function shiftPoints(TS, varargin)
            for t = 1:TS.size
                TS.Transects(t).shiftPoints(varargin{:});
            end
        end
        
        function m = toMatrix(TS)
           m     = [];
           count = 1;
           
           for t = 1:TS.size
               for s = 1:TS.Transects(t).size
                  m(count,1) = t;
                  m(count,2) = s;
                  m(count,3) = TS.Transects(t).Stations(s).Easting;
                  m(count,4) = TS.Transects(t).Stations(s).Northing;
                  m(count,5) = TS.Transects(t).Stations(s).Distance;
                  m(count,6) = TS.Transects(t).Stations(s).value;
                  
                  count = count + 1;
               end
           end 
        end
        
        function plot(TS, varargin)
            for t = 1:TS.size
                TS.Transects(t).plot(varargin{:});
            end
        end
    end
    
end

