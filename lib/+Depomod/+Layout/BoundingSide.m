classdef BoundingSide< dynamicprops
    
    properties
        Endpoints = [];
        Slope@double;
        Bearing@double;
        UnitVector = [];
        InwardBearing@double;
        OutwardBearing@double;
        BoundingBox@Depomod.Layout.BoundingBox;
    end
    
    methods (Static = true)
    end
    
    methods
   
        function BS = BoundingSide(endpoints, varargin)
            % order assumes points from right to left when positioned
            % *within* box.
            
            boundingBox = [];
            
            for i = 1:2:length(varargin) % only bother with odd arguments, i.e. the labels
                switch varargin{i}
                    case 'boundingBox' % 
                        boundingBox = varargin{i+1};
                end
            end
            
            BS.Endpoints = endpoints;
            BS.setBearingsFromPoints;
            
            if ~isempty(boundingBox)
                BB.BoundingBox = boundingBox;
            end
        end
        
        function l = length(BS)
            l = sqrt((BS.Endpoints(2,1) - BS.Endpoints(1,1))^2 + (BS.Endpoints(2,2) - BS.Endpoints(1,2))^2);
        end
        
        function setSlope(BS)
            BS.Slope = (BS.Endpoints(2,2) - BS.Endpoints(1,2))/...
                (BS.Endpoints(2,1) - BS.Endpoints(1,1));
        end
        
        function b = validateBearing(BS, bearing)
           % ensures 0-360 degrees
           
           b = mod(bearing + 360, 360);
        end
        
        function setBearingsFromPoints(BS)
            BS.setSlope;
            
            % convert to degrees and relative to north
            bearing = 90 - atand(BS.Slope);
                        
            if BS.Endpoints(2,1) < BS.Endpoints(1,1)
                bearing = bearing + 180;
            end   
            
            BS.Bearing        = BS.validateBearing(bearing);
            BS.InwardBearing  = BS.validateBearing(bearing-90);
            BS.OutwardBearing = BS.validateBearing(bearing+90);
            
            BS.setUnitVector;
        end
        
        function setUnitVector(BS)
            % unit vector lengths associated with a 1 m distance
            
            if ~isempty(BS.Bearing)
                BS.UnitVector = [sind(BS.Bearing), cosd(BS.Bearing)];
            else
                BS.setBearingsFromPoints;
            end
        end
        
        function [e,n] = coordinatesAtDistance(BS, distance)
            e = BS.Endpoints(1,1) + distance*BS.UnitVector(1);
            n = BS.Endpoints(1,2) + distance*BS.UnitVector(2);            
        end
        
        function [e,n] = midpoint(BS)
            distance = BS.length/2.0;
            [e,n] = BS.coordinatesAtDistance(distance);
        end
        
        function [e,n] = lineIntersectPoint(BS, x, y)
            
            endpoints = BS.Endpoints;
            
            s1_x = x(2)-x(1);     
            s1_y = y(2)-y(1);
            s2_x = endpoints(2,1)-endpoints(1,1);     
            s2_y = endpoints(2,2)-endpoints(1,2) ;

            sg = (-s1_y * (x(1) - endpoints(1,1)) + s1_x * (y(1) - endpoints(1,2))) / (-s2_x * s1_y + s1_x * s2_y);
            tg = ( s2_x * (y(1) - endpoints(1,2)) - s2_y * (x(1) - endpoints(1,1))) / (-s2_x * s1_y + s1_x * s2_y);

            if (sg >= 0 && sg <= 1 && tg >= 0 && tg <= 1)
                e = x(1) + (tg * s1_x);
                n = y(1) + (tg * s1_y);  
            end
        end
    end
    
end

