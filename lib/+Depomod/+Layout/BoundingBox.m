classdef BoundingBox < dynamicprops
    
    properties
        Centre  = [];
        Corners = [];
        Sides   = {};
        Cages   = {};
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
                
               BB.Sides{bs} = Depomod.Layout.BoundingSide(BB.Corners([startIdx endIdx], :));                
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
        
        function l = sideLengths(BB)
            l = [];
            l(1) = BB.Sides{1}.length;
            l(2) = BB.Sides{2}.length;
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
                    disp('this one')
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

            side      = BB.Sides{BB.bearingIntersectSide(bearing)};
            endpoints = side.Endpoints;
            
            s1_x = radial_x(2)-radial_x(1);     
            s1_y = radial_y(2)-radial_y(1);
            s2_x = endpoints(2,1)-endpoints(1,1);     
            s2_y = endpoints(2,2)-endpoints(1,2) ;

            sg = (-s1_y * (radial_x(1) - endpoints(1,1)) + s1_x * (radial_y(1) - endpoints(1,2))) / (-s2_x * s1_y + s1_x * s2_y);
            tg = ( s2_x * (radial_y(1) - endpoints(1,2)) - s2_y * (radial_x(1) - endpoints(1,1))) / (-s2_x * s1_y + s1_x * s2_y);

            if (sg >= 0 && sg <= 1 && tg >= 0 && tg <= 1)
                e = radial_x(1) + (tg * s1_x);
                n = radial_y(1) + (tg * s1_y);  
            end
        end
        
        function a = area(BB)
            l = BB.sideLengths;
            a = l(1)*l(2);
        end
        
        function setCentre(BB)
            BB.Centre(1) = mean(BB.Corners(:,1));
            BB.Centre(2) = mean(BB.Corners(:,2));
        end
        
        function plot(BB)
            e = BB.Centre(1);
            n = BB.Centre(2);
            
            scatter3(e, n, 10, 15, 'y', 'filled');
            
            scatter3(...
                BB.Corners(:,1), ...
                BB.Corners(:,2), ...
                repmat(10,4,1), ...
                repmat(15,4,1), ...
                'g', 'filled');

             text(...
                 BB.Corners(:,1)+25,...
                 BB.Corners(:,2),...
                 arrayfun(@num2str, 1:4, 'Uniform', false),...
                 'Color',...
                 'w');
        end
        
    end
    
end

