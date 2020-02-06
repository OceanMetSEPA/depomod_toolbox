classdef Site < dynamicprops
    
    properties
        cageGroups = {};
        path = '';
    end
    
    methods (Static = true)
        
        function site = fromXMLFile(filepath)
            xmlDOM  = xmlread(filepath);
            siteDOM = xmlDOM.getDocumentElement;
            site = Depomod.Layout.Site.fromXMLDOM(siteDOM);
            site.path = filepath;
        end
        
        function site = fromXMLDOM(siteDOM)
            site = Depomod.Layout.Site;
            groupsDOM = siteDOM.getElementsByTagName('ns2:group');
            
            for i = 1:groupsDOM.getLength
                groupDOM = groupsDOM.item(i-1);
                group = Depomod.Layout.Cage.Group.fromXMLDOM(groupDOM);
                site.cageGroups{i} = group;
            end
        end
        
        function site = fromCSV(filepath)
            site = Depomod.Layout.Site;
            group = Depomod.Layout.Cage.Group;
            
            data = Depomod.FileUtils.readTxtFile(filepath, 'startRow', 2);
            
            for i = 1:size(data,1)
                cage = Depomod.Layout.Cage.Base.fromCSVRow(data{i});
                group.cages{i} = cage;
            end
            
            site.cageGroups{1} = group;
        end
    end
    
    methods
        
        function g = group(S, number)
            g = S.cageGroups{number};
        end
        
        function s = size(S)
            s = length(S.cageGroups);
        end
        
        function sc = sizeCages(S)
            sc = 0;
            for g = 1:S.size
                sc = sc + S.group(g).size;
            end
        end
        
        function a = cageArea(S)
            a = 0;
            
            for i = 1:S.size
                group = S.group(i);
                a = a + group.cageArea;
            end
        end
        
        function v = cageVolume(S)
            v = 0;
            
            for i = 1:S.size
                group = S.group(i);
                v = v + group.cageVolume;
            end
        end
        
        function [x,y,cageStruct] = cagePerimeter(S, varargin)
            % by default is from cage edge
            
            radialDistance=100; % default value = MZ length
            % But set to zero in nearestCageEdgeLocationToPoint to get cage
            % edge boundary for transects
            plotPerimeter  = 0;
            
            for i = 1:2:length(varargin) % only bother with odd arguments, i.e. the labels
                switch varargin{i}
                    case 'radialDistance'
                        radialDistance = varargin{i+1};
                    case 'plot'
                        plotPerimeter = logical(varargin{i+1});
                end
            end
            
            cages      = S.consolidatedCages.cages;
            th=linspace(0,2*pi,1000); % TS 20191210- More points for greater accuracy
            
            cageStruct = struct;
            for ss = 1:length(cages)
                cage=cages{ss};
                cageShape=cage.shape;
                cageSize=cage.width;
                if cageSize<0
                    error('Cage %d has negative length %f',ss,cageSize)
                end
                switch cageShape
                    case 'square'
                        angle=-cage.angle; % angle included in .csv file format...
                        if isempty(angle) % ... but not in xml. So for this, use:
                            angle=S.majorAxis; % Calculated in majorAxis from cage group configuration
                        end
                        [x,y]=S.getSquareMixingZone(cage.x,cage.y,cageSize,angle,radialDistance);
                        cageStruct(ss).x=x;
                        cageStruct(ss).y=y;
                        
                    case 'circle'
                        radius=cageSize/2+radialDistance; % calculate required radius
                        cageStruct(ss).x = radius * cos(th) + cages{ss}.x;
                        cageStruct(ss).y = radius * sin(th) + cages{ss}.y;
                    otherwise
                        error('%s calculation not implemented',cageShape)
                end
                if ~ispolycw(cageStruct(ss).x,cageStruct(ss).y)
                    [cageStruct(ss).x,cageStruct(ss).y]=poly2cw(cageStruct(ss).x,cageStruct(ss).y);
                end
            end
            
            [x, y] = polybool('union', cageStruct(1).x, cageStruct(1).y, cageStruct(1).x, cageStruct(1).y);
            
            for ss = 2:length(cages)                
                x1 = x;
                y1 = y;
                x2 = cageStruct(ss).x;
                y2 = cageStruct(ss).y;
                [x, y] = polybool('union', x1, y1, x2, y2);
            end
            if plotPerimeter
                figure;
                plot(x,y);
                daspect([1 1 1]);
            end
          end
        
        function a = compositeArea(S, varargin)
            radialDistance  = 100; % m
            %            cageEdge        = 1;
            for i = 1:2:length(varargin) % only bother with odd arguments, i.e. the labels
                %              fprintf('%d and arg = %s\n',i,varargin{i})
                switch varargin{i}
                    case 'radialDistance'
                        radialDistance = varargin{i+1};
                        %                    case 'cageEdge' % this option never seems to be used
                        %                        cageEdge = varargin{i+1};
                end
            end
            
            %             if ~cageEdge
            %                 cageLength = S.consolidatedCages.cages{1}.length;
            %
            %                 if cageLength == 0
            %                     cageLength = S.consolidatedCages.cages{1}.width;
            %                 end
            %
            %                 cageLength     = cageLength/2.0;
            %                 radialDistance = radialDistance - cageLength;
            %             end
            [x,y] = S.cagePerimeter('radialDistance', radialDistance);
            if sum(isnan(x)) > 0
                idx = find(isnan(x));
                
                a = polyarea(x(1:(idx(1)-1)), y(1:(idx(1)-1)));
                for pidx = 1:numel(idx)
                    if pidx == numel(idx)
                        a = a + polyarea(x((idx(pidx)+1):end), y((idx(pidx)+1):end));
                    else
                        a = a + polyarea(x((idx(pidx)+1):(idx(pidx+1)-1)), y((idx(pidx)+1):(idx(pidx+1)-1)));
                    end
                end
            else
                a = polyarea(x, y);
            end
        end
        
        function [e,n, distance] = nearestCageEdgeLocationToPoint(S, x, y)
            % Find nearest point on perimeter to x,y
            [ep,np] = S.cagePerimeter('radialDistance', 0);
            % We can redo Andy's distance calculation without a loop:
            dist=sqrt((ep-x).^2+(np-y).^2); % Distance between x,y and all points on perimeter
            k=find(dist==min(dist));
            k=k(1); % in case we're equidistant between points, just pick first one
            e=ep(k);
            n=np(k);
            distance=dist(k);
            %             [ep,np] = S.cagePerimeter('radialDistance', 0);
            %             e = [];
            %             n = [];
            %
            %             distance = 99999999 ;
            %             %            th = 0:pi/50:2*pi;
            %
            %             for ss = 1:numel(ep)
            %
            %                 d = sqrt((ep(ss) - x)^2 + (np(ss) - y)^2);
            %
            %                 if d < distance
            %                     distance = d;
            %                     e = ep(ss);
            %                     n = np(ss);
            %                 end
            %             end
        end
        
        function cc = consolidatedCages(S)
            cc = Depomod.Layout.Cage.Group;
            
            for g = 1:S.size
                for c = 1:S.group(g).size
                    cc.cages{end+1} = S.group(g).cage(c);
                end
            end
        end
        
        function [meanE, meanN] = meanCagePosition(S)
            % Is this correct. Is this the mean cage position of the mean
            % position of the groups?
            
            cumE = 0;
            cumN = 0;
            
            for i = 1:S.size
                [meanGroupE, meanGroupN] = S.group(i).meanCagePosition;
                
                cumE = cumE + meanGroupE;
                cumN = cumN + meanGroupN;
            end
            
            meanE = cumE/S.size;
            meanN = cumN/S.size;
        end
        
        function ma = majorAxis(S)
            cages = S.consolidatedCages.cages;
            cage_xy = [];
            if length(cages)==1 % TS added this- can't calculate eigenvectors etc with single cage
                ma=0; % 0 is as good as any other number. Shouldn't matter
                return
            end
            for c = 1:length(cages)
                cage_xy(c,1) =  cages{c}.x;
                cage_xy(c,2) =  cages{c}.y;
            end
            
            % discover major axis of cage layout
            pcaStruct.covar = cov(cage_xy(:,1), cage_xy(:,2));
            [pcaStruct.eigenVector, pcaStruct.eigenValue] = eig(pcaStruct.covar); % eigenvector
            
            if pcaStruct.eigenValue(2,2) > pcaStruct.eigenValue(1,1)
                pcaStruct.cols = [2 1];
            else
                pcaStruct.cols = [1 2];
            end
            
            f = pcaStruct.eigenVector(1,pcaStruct.cols(1));
            g = pcaStruct.eigenVector(2,pcaStruct.cols(1));
            
            ma = atan2(f,g);
            
            if mean(cage_xy(:,2))<0
                ma = ma + pi;
            end
            
            ma = ma * 180 / pi;      % convert to degrees
            ma = mod(ma + 360, 360); % make sure axis is between 0 and 360
            
            % Avoid completely vertical and horizintal axes
            % Makes trigonometry difficult
            if ma == 0 | ma == 90 | ma == 180 | ...
                    ma == 270 | ma == 360
                ma = ma + 1;
                ma = mod(ma + 360, 360);
            end
        end
        
        function ob = orthogonalBearings(S)
            ma = S.majorAxis;
            ob = [ma, ma + 90, ma + 180, ma + 270];
            
            ob = mod(ob+360, 360);
        end
        
        function c = corners(S)
            cages = S.consolidatedCages.cages;
            
            cageLength = cages{1}.length;
            
            if cageLength == 0
                cageLength = cages{1}.width;
            end
            
            cageLength = cageLength/2.0;
            
            cage_xy = [];
            
            for c = 1:length(cages)
                cage_xy(c,1) =  cages{c}.x;
                cage_xy(c,2) =  cages{c}.y;
            end
            
            min_x = min(cage_xy(:,1));
            max_x = max(cage_xy(:,1));
            
            ob = S.orthogonalBearings;
            
            intercepts = zeros(2,3);
            
            for o = 1:2
                theta = ob(o);
                
                for l = -1:2:1
                    m = (cosd(theta)/sind(theta));
                    
                    for c = 1:length(cages)
                        pointCheckData = [];
                        
                        x = cage_xy(c,1);
                        y = cage_xy(c,2);
                        
                        intercept = y - m*x;
                        this_intercept = intercept + l * cageLength/sind(theta);
                        
                        x_s = (min_x-100):(max_x+100);
                        y_s = (cosd(theta)/sind(theta)).*x_s + this_intercept;
                        
                        for c2 = 1:length(cages)
                            x2 = cage_xy(c2,1) ;
                            y2 = cage_xy(c2,2) ;
                            
                            % https://math.stackexchange.com/questions/274712/calculate-on-which-side-of-a-straight-line-is-a-given-point-located
                            d = (x2 - x_s(1))*(y_s(end) - y_s(1))-(y2 - y_s(1))*(x_s(end) - x_s(1));
                            
                            if d < 1 && d > -1
                                pointCheckData(c2) = 0; % accomodate rounding error for points on the line
                            else
                                pointCheckData(c2) = sign(d);
                            end
                        end
                        
                        nonZeroPointCheckData = pointCheckData(pointCheckData~=0);
                        
                        if all(nonZeroPointCheckData > 0) || all(nonZeroPointCheckData < 0)
                            
                            if l == 1 && nonZeroPointCheckData(1) == intercepts(o,1)
                                continue;
                            end
                            
                            if l == -1
                                intercepts(o,1) = this_intercept;
                            else
                                intercepts(o,2) = this_intercept;
                            end
                            
                            break
                        end
                    end
                end
            end
            
            c = zeros(4,2);
            
            count = 1;
            
            for in1 = 1:2
                for in2 = 1:2
                    
                    m1 = ob(1);
                    m2 = ob(2);
                    
                    i1 = intercepts(1,in1);
                    i2 = intercepts(2,in2);
                    
                    x = (i2 - i1)/((cosd(m1)/sind(m1)) - (cosd(m2)/sind(m2)));
                    
                    y = ((cosd(m1)/sind(m1)))*x + i1;
                    
                    c(count,1)=x;
                    c(count,2)=y;
                    
                    count = count + 1;
                end
            end
            
            % counter-clockwise order
            c = c([1 2 4 3], :);
        end
        
        function BB = boundingBox(S)
            BB = Depomod.Layout.BoundingBox.createFromCages(S);
        end
        
        function sizeInBytes = toFile(S, filePath)
            % this currently only tries to write 1 cage group
            
            if ~exist('filePath', 'var')
                filePath = S.path;
                warning('Site.m : No file path given. Existing source file will be overwritten.')
            end
            
            % get an XML cage template
            templateCages = xmlread(NewDepomod.Project.templateProject.solidsRuns.item(1).cagesPath);
            
            DOM = templateCages.getDocumentElement;
            
            % retrieve existing cage groups
            groups = DOM.getElementsByTagName('ns2:group');
            
            % and delete them. Easier ro build from scratch
            for i = 1:groups.getLength
                DOM.removeChild(groups.item(0));
            end
            
            % create new cage group node
            group_node = templateCages.createElement('ns2:group');
            
            % add to XML doc
            templateCages.getDocumentElement.appendChild(group_node);
            
            % Create a random uuid for all cages
            indexes = [48:57, 97:102]; % ascii 0-9, a-f
            uuid = [...
                char(indexes(ceil(rand(1, 8)*length(indexes)))), ...
                '-',...
                char(indexes(ceil(rand(1, 4)*length(indexes)))), ...
                '-',...
                char(indexes(ceil(rand(1, 4)*length(indexes)))), ...
                '-',...
                char(indexes(ceil(rand(1, 4)*length(indexes)))), ...
                '-',...
                char(indexes(ceil(rand(1, 12)*length(indexes)))) ...
                ];
            
            % get group - this might provide group level attributes
            group = S.cageGroups{1};
            
            for c = 1:S.sizeCages
                
                cage = S.consolidatedCages.cages{c};
                
                cage_node = templateCages.createElement('cage');
                
                type_node       = templateCages.createElement('cageType');
                x_node          = templateCages.createElement('xCoordinate');
                y_node          = templateCages.createElement('yCoordinate');
                phi_node        = templateCages.createElement('phi');
                length_node     = templateCages.createElement('length');
                width_node      = templateCages.createElement('width');
                height_node     = templateCages.createElement('hieght');
                depth_node      = templateCages.createElement('depth');
                id_node         = templateCages.createElement('inputsId');
                proportion_node = templateCages.createElement('proportion');
                production_node = templateCages.createElement('inProduction');
                
                if isequal(class(cage), 'Depomod.Layout.Cage.Circle')
                    type_node.setTextContent('CIRCULAR');
                elseif isequal(class(cage), 'Depomod.Layout.Cage.Square')
                    type_node.setTextContent('RECTANGULAR');
                end
                
                x_node.setTextContent(num2str(cage.x));
                y_node.setTextContent(num2str(cage.y));
                phi_node.setTextContent(num2str(pi/2.0));
                
                if isequal(class(cage), 'Depomod.Layout.Cage.Circle')
                    length_node.setTextContent(num2str(cage.width));
                elseif isequal(class(cage), 'Depomod.Layout.Cage.Square')
                    length_node.setTextContent(num2str(cage.length));
                end
                
                width_node.setTextContent(num2str(cage.width));
                height_node.setTextContent(num2str(cage.height));
                depth_node.setTextContent(num2str(cage.height/2.0));
                
                if isempty(cage.inputsId)
                    id_node.setTextContent(uuid);
                else
                    id_node.setTextContent(cage.inputsId);
                end
                
                if isempty(cage.proportion)
                    proportion_node.setTextContent(num2str(1/S.sizeCages));
                else
                    proportion_node.setTextContent(num2str(cage.proportion));
                end
                
                if isempty(cage.inProduction)
                    production_node.setTextContent('true');
                else
                    if cage.inProduction
                        production_node.setTextContent('true');
                    else
                        production_node.setTextContent('false');
                    end
                end
                
                cage_node.appendChild(type_node);
                cage_node.appendChild(x_node);
                cage_node.appendChild(y_node);
                cage_node.appendChild(phi_node);
                cage_node.appendChild(length_node);
                cage_node.appendChild(width_node);
                cage_node.appendChild(height_node);
                cage_node.appendChild(depth_node);
                cage_node.appendChild(id_node);
                cage_node.appendChild(proportion_node);
                cage_node.appendChild(production_node);
                
                group_node.appendChild(cage_node)  ;
                
            end
            
            layout_type_node    = templateCages.createElement('ns2:layoutType');
            name_node           = templateCages.createElement('ns2:name');
            origin_x_node       = templateCages.createElement('ns2:regularGridXOrigin');
            origin_y_node       = templateCages.createElement('ns2:regularGridYOrigin');
            spacing_x_node      = templateCages.createElement('ns2:regularGridXSpacing');
            spacing_y_node      = templateCages.createElement('ns2:regularGridYSpacing');
            grid_nx_node        = templateCages.createElement('ns2:regularGridNX');
            grid_ny_node        = templateCages.createElement('ns2:regularGridNY');
            grid_length_node    = templateCages.createElement('ns2:regularGridLength');
            grid_width_node     = templateCages.createElement('ns2:regularGridWidth');
            grid_height_node    = templateCages.createElement('ns2:regularGridHieght');
            grid_depth_node     = templateCages.createElement('ns2:regularGridDepth');
            grid_bearing_node   = templateCages.createElement('ns2:regularGridBearing');
            grid_cage_type_node = templateCages.createElement('ns2:regularGridCageType');
            
            if isempty(group.layoutType)
                layout_type_node.setTextContent(group.layoutType);
            else
                layout_type_node.setTextContent('REGULARGRID');
            end
            
            name_node.setTextContent(group.name);
            origin_x_node.setTextContent(num2str(S.consolidatedCages.cages{c}.x));
            origin_y_node.setTextContent(num2str(S.consolidatedCages.cages{c}.y));
            spacing_x_node.setTextContent(num2str(group.xSpacing));
            spacing_y_node.setTextContent(num2str(group.ySpacing));
            grid_nx_node.setTextContent(num2str(group.Nx));
            grid_ny_node.setTextContent(num2str(group.Ny));
            
            if isequal(class(cage), 'Depomod.Layout.Cage.Circle')
                grid_length_node.setTextContent(num2str(S.consolidatedCages.cages{c}.width));
            elseif isequal(class(cage), 'Depomod.Layout.Cage.Square')
                grid_length_node.setTextContent(num2str(S.consolidatedCages.cages{c}.length));
            end
            
            grid_width_node.setTextContent(num2str(S.consolidatedCages.cages{c}.width));
            grid_height_node.setTextContent(num2str(S.consolidatedCages.cages{c}.height));
            grid_depth_node.setTextContent(num2str(S.consolidatedCages.cages{c}.height/2.0));
            grid_bearing_node.setTextContent(num2str(group.bearing));
            
            if isequal(class(S.consolidatedCages.cages{c}), 'Depomod.Layout.Cage.Circle')
                grid_cage_type_node.setTextContent('CIRCULAR');
            elseif isequal(class(S.consolidatedCages.cages{c}), 'Depomod.Layout.Cage.Square')
                grid_cage_type_node.setTextContent('SQUARE');
            end
            
            group_node.appendChild(layout_type_node);
            group_node.appendChild(name_node);
            group_node.appendChild(origin_x_node);
            group_node.appendChild(origin_y_node);
            group_node.appendChild(spacing_x_node);
            group_node.appendChild(spacing_y_node);
            group_node.appendChild(grid_nx_node);
            group_node.appendChild(grid_ny_node);
            group_node.appendChild(grid_length_node);
            group_node.appendChild(grid_width_node);
            group_node.appendChild(grid_height_node);
            group_node.appendChild(grid_depth_node);
            group_node.appendChild(grid_bearing_node);
            group_node.appendChild(grid_cage_type_node);
            
            % use this method to remove annoying whitespace characters
            % added by MATLAB (https://uk.mathworks.com/matlabcentral/newsreader/view_thread/245555)
            docStr = xmlwrite(templateCages);
            docStr = regexprep(docStr,'\n\s*\n','\n');
            openDoc = fopen(filePath,'w');
            fprintf(openDoc,'%s\n',docStr);
            fclose(openDoc);
        end
        
        function m = toMatrix(S)
            cages = S.consolidatedCages.cages;
            m = cell(numel(cages),10);
            
            for c = 1:numel(cages)
                cage = cages{c};
                
                m{c,1} = c;
                m{c,2} = cage.x;
                m{c,3} = cage.y;
                m{c,4} = cage.length;
                m{c,5} = cage.width;
                m{c,6} = cage.height;
                m{c,7} = cage.depth;
                m{c,8} = cage.inputsId;
                m{c,9} = cage.proportion;
                m{c,10} = cage.inProduction;
            end
        end
        
        
        function [xCorner,yCorner] = getSquareCorners(~,x0,y0,L,angle)
            % Given coordinates of a cage (centre) and size and orientation,
            % find 4 corner points
            %
            % INPUTS
            %   x0,y0 - coordinates of centre(s) of square(s)
            %   L     - length of side
            %   angle - orientation of square (degrees)- +ve = clockwise
            %
            %
            % OUTPUT
            %  [xc,yc] - coordinates of square corners. One row for each square. 4
            %  columns, one per corner. If 'join'==true, get extra column equal to
            %  first column
            %
            % EXAMPLE:
            % getSquareCorners(150,200,35,30,'plot',1,'join',1)
            %    1.0e+02 *
            %    1.260945554337723   1.435945554337723   1.739054445662277   1.564054445662277   1.260945554337723
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % $Workfile:   getSquareCorners.m  $
            % $Revision:   1.0  $
            % $Author:   ted.schlicke  $
            % $Date:   Apr 08 2014 14:02:50  $
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if nargin==0
                help getSquareCorners
                return
            end
            
            % To generate our square's corners, we start by defining a square centred on our point of interest and
            % lined up with x,y axes. Then we rotate the square by the angle specified.
            % Some nice matrix manipulation!
            
            NumberOfSquares=length(x0);
            xCorner=cell(NumberOfSquares,1);
            yCorner=cell(NumberOfSquares,1);
            
            if length(L)==1
                L=repmat(L,NumberOfSquares,1);
            end
            
            % Some abbreviations: we use these in our rotation matrix
            cd=cosd(angle);
            sd=sind(angle);
            
            for i=1:NumberOfSquares
                % These are 4 corners of a square of side L(i) lined up with x,y axes, centred on origin:
                Li=L(i)/2;
                dx=[-1,-1,1,1]*Li;
                dy=[-1,1,1,-1]*Li;
                % shift so square centred on our point of interest (x0,y0)
                x1=x0(i)+dx;
                y1=y0(i)+dy;
                
                T=[1,0,x0(i);0,1,y0(i);0,0,1]; % Translation matrix: shift from origin to (x0,y0)
                R=[cd,sd,0;-sd,cd,0;0,0,1]; % Rotation matrix: rotate by angle about origin
                M=T*R/T; % Rotation about our point of interest (x0,y0) is equivalent to shifting to origin, rotation about origin and shifting back from origin.
                
                ip=[x1;y1;ones(size(x1))];% Define our input matrix: our 4 corners plus some ones
                op=M*ip; % These are our rotated coordinates!
                x1=op(1,:); % x row
                y1=op(2,:); % y row
                
                xCorner{i}=x1;
                yCorner{i}=y1;
            end
            % Join cells and convert to numeric
            xCorner=vertcat(xCorner{:});
            yCorner=vertcat(yCorner{:});
            
        end
        function [xb,yb] = getSquareMixingZone(S,x0,y0,squareSide,ang,mzLength)
            % Get MZ boundary for square
            [x,y]=S.getSquareCorners(x0,y0,squareSide,ang);
            [xb,yb]=S.getSquareCorners(x0,y0,squareSide+2*mzLength,ang);
            % Define unit square for establishing corner angles (incase squareSize = 0)
            [xunit,yunit]=getSquareCorners(x0,y0,1,ang);
            Nc=1000;
            circleAngles=linspace(0,2*pi,Nc);
            
            % For each corner, replace square section with circle
            Ldiag=squareSide/sqrt(2)+mzLength;
            for cornerIndex=1:4
                xi=xunit(cornerIndex);
                yi=yunit(cornerIndex);
                iang=atan2(yi-y0,xi-x0);
                %    fprintf('Corner %d and ang = %f\n',cornerIndex,rad2deg(iang))
                xi=x0+Ldiag*cos(iang);
                yi=y0+Ldiag*sin(iang);
                [xi,yi]=getSquareCorners(xi,yi,sqrt(2)*mzLength,ang);
                [xb,yb]=polybool('subtraction',xb,yb,xi,yi);
                xc=x(cornerIndex)+mzLength*cos(circleAngles);
                yc=y(cornerIndex)+mzLength*sin(circleAngles);
                [xc,yc]=poly2cw(xc,yc);
                [xb,yb]=polybool('union',xb,yb,xc,yc);
            end
            
            % Theoretical area =
            % squareSide^2 + 4*squareSide*mzLength + pi*mzLength^2;
            % i.e. area of original square + 4 rectangles + 4 quarter circles
            %
            % Discrepancy between polybool(xb,yb) and theoretical value due to finite
            % Nc. polybool grinds to a halt when this is too big...
            
        end
        
    end
end
