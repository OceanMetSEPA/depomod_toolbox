classdef BoundingBox < dynamicprops
    
    properties
        Centre  = [];
        Corners = [];
        Sides@Depomod.Layout.BoundingSide;
        Cages@Depomod.Layout.Site;
        MajorAxis@double;
    end
    
    methods (Static = true)
        
        function BB = createFromCages(cages)
            corners   = cages.corners;
            majorAxis = cages.majorAxis;
            
            BB = Depomod.Layout.BoundingBox(corners, majorAxis);   
            BB.Cages = cages;
        end
    end
    
    methods
   
        function BB = BoundingBox(corners, majorAxis)
            BB.Corners = corners;
            BB.MajorAxis = majorAxis;
            
            for bs = 1:4
                startIdx = bs;
                endIdx   = bs + 1;
                
                if endIdx > 4
                    endIdx = 1;
                end
                
               BB.Sides(bs) = Depomod.Layout.BoundingSide(BB.Corners([startIdx endIdx], :),...
                   'boundingBox', BB);                
            end
            
            BB.setCentre;
        end
        
        function ob = orthogonalBearings(BB)
            % bearings relative to box centre/major axis
            
            ma = BB.MajorAxis;
            ob = [ma, ma + 90, ma + 180, ma + 270];

            ob = mod(ob+360, 360);
        end
        
        function cb = cornerBearings(BB)
            % bearings relative to box centre
            
            cb = [];
            
            for c = 1:4
                centre = BB.Centre;
                corner = BB.Corners(c,:);
                
                x = [centre(1), corner(1)];
                y = [centre(2), corner(2)];
                
                [P,S] = polyfit(x, y,1);
                m     = P(1);

                % convert to degrees and relative to north
                bearing = 90 - atand(m);

                if corner(1) < centre(1)
                    bearing = bearing + 180;
                end   

                cb(c) = bearing;
            end
        end
        
        function pl = perimeterLength(BB)
            sl = BB.sideLengths;
            pl = 2*(sl(1)+sl(2));
        end
        
        function l = sideLengths(BB)
            l = [];
            l(1) = BB.Sides(1).length;
            l(2) = BB.Sides(2).length;
        end
        
        function [sideIdx, sideDistance] = perimeterDistance2SideDistance(BB, distance)
            thisSide = 2;
            thisDistance = BB.Sides(thisSide).length/2.0;
            sideRemainingDistance = BB.Sides(thisSide).length - thisDistance;
            
            while sideRemainingDistance < distance
                distance = distance - sideRemainingDistance;
                thisSide = thisSide+1;
                if thisSide == 5
                    thisSide = 1;
                end
                thisDistance = 0;
                sideRemainingDistance =  BB.Sides(thisSide).length;
            end
            
            sideIdx = thisSide;
            sideDistance = thisDistance+distance;
        end
        
        function sb = sideBearings(BB, idx)
            % bearings relative to box centre
            % counter-clockwide order
            
            cb = BB.cornerBearings;
            
            startIdx = idx;
            endIdx   = idx + 1;
            
            if endIdx > 4
                endIdx = 1;
            end
            
            sb = [cb(startIdx), cb(endIdx)];
        end
        
        function s = bearingIntersectSide(BB, bearing) 
            % bearings relative to box centre
            
            for s = 1:4
                sb = BB.sideBearings(s);
                
                if sb(2) > sb(1) % includes 0/360 mark
                    if (bearing < sb(1) & bearing >= 0) | ...
                            (bearing > sb(2) & bearing <= 360)
                        break
                    end
                else
                    if bearing < sb(1) & bearing > sb(2)
                        break
                    end
                end
            end
        end
        
        function [e,n] = bearingIntersectCoordinates(BB, bearing) 
            % bearings relative to box centre

            side      = BB.Sides(BB.bearingIntersectSide(bearing));
            
            mid_e = BB.Centre(1);
            mid_n = BB.Centre(2);
            
            radial_m    = (cosd(bearing)/sind(bearing));
            radial_c    = mid_n - radial_m * mid_e;
            radial_x(1) = mid_e;

            direction = 1;

            if bearing > 180 & bearing < 360
                direction = -1;
            end

            radial_x(2) = mid_e + direction * (9999 * cosd(atand(radial_m)));
            radial_y    = radial_m.*radial_x + radial_c; 
            
            [e,n] = side.lineIntersectPoint(radial_x, radial_y);
        end
        
        function a = area(BB)
            l = BB.sideLengths;
            a = l(1)*l(2);
        end
        
        function setCentre(BB)
            BB.Centre(1) = mean(BB.Corners(:,1));
            BB.Centre(2) = mean(BB.Corners(:,2));
        end
        
        function plotCorners(BB)
            e = BB.Centre(1);
            n = BB.Centre(2);
            
            % offset text by 25 m from point in direction of coner bearing
            bearings = BB.cornerBearings;
            unitVectors = [sind(bearings'), cosd(bearings')];
            % double this offset for westward pointing corners to account
            % for text width
            textOffset  = (unitVectors(:,1) < 0) + 1;
            
            scatter3(e, n, 10, 15, 'y', 'filled');
            
            scatter3(...
                BB.Corners(:,1), ...
                BB.Corners(:,2), ...
                repmat(10,4,1), ...
                repmat(15,4,1), ...
                'g', 'filled');

             text(...
                 BB.Corners(:,1)+25.*textOffset.*unitVectors(:,1),...
                 BB.Corners(:,2)+25.*textOffset.*unitVectors(:,2),...
                 arrayfun(@num2str, 1:4, 'Uniform', false),...
                 'Color',...
                 'g');
        end
        
        function plotSides(BB)
            
            for i = 1:4
                j = i+1;
                
                if i == 4
                    j = 1;
                end
                
                plot(...
                    [BB.Corners(i,1) BB.Corners(j,1)], ...
                    [BB.Corners(i,2) BB.Corners(j,2)], ...
                    'y');

                % offset text by 25 m from point in direction of coner bearing
                [e,n]      = BB.Sides(i).midpoint;
                bearing    = BB.Sides(i).OutwardBearing;
                unitVector = [sind(bearing), cosd(bearing)];
                % double this offset for westward pointing corners to account
                % for text width
                textOffset = (unitVector(1) < 0) + 1;
                
                text(...
                    e+25*textOffset*unitVector(1),...
                    n+25*textOffset*unitVector(2),...
                    num2str(i),...
                    'Color',...
                    'y');
            end
        end
        
    end
    
end

