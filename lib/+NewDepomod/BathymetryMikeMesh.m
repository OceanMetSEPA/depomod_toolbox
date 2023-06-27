classdef BathymetryMikeMesh < handle
    
    
    properties
        BathymetryType = [];
        BathymetryUnit = [];
        NodeX = [];
        NodeY = [];
        NodeZ = [];
        NodeType = [];
        Elements = []
        SpatialReferenceSystem = []
        MeshType = [];
        MaxNodesPerElement = [];
        path = '';
    end
    
    methods
        
        function BMM = BathymetryMikeMesh(filePath)
            if exist('filePath', 'var')
                BMM.fromFile(filePath);
            end   
        end
        
        
        function fromFile(BMM, filePath)
            BMM.path = filePath;
            
            file = Depomod.FileUtils.readTxtFile(filePath);
       
            headerLine       = file{1};  
            parsedHeaderLine = strsplit(headerLine);
            
            BMM.BathymetryType = str2num(parsedHeaderLine{1});
            BMM.BathymetryUnit = str2num(parsedHeaderLine{2});
            BMM.SpatialReferenceSystem = parsedHeaderLine{4};
            
            numNodes         = str2num(parsedHeaderLine{3});

            for i = 1:numNodes
                line       = file{i+1};
                parsedLine = strsplit(line);

                BMM.NodeX(i) = str2double(parsedLine{2});
                BMM.NodeY(i) = str2double(parsedLine{3});
                BMM.NodeZ(i) = str2double(parsedLine{4});
                BMM.NodeType(i) = str2double(parsedLine{5});
            end
            
            elementHeaderLine       = file{1+numNodes+1};  
            parsedElementHeaderLine = strsplit(elementHeaderLine);
            
            BMM.MeshType = str2num(parsedElementHeaderLine{3});
            BMM.MaxNodesPerElement = str2num(parsedElementHeaderLine{2});
            
            numElements             = str2num(parsedElementHeaderLine{1});
            
            for i = 1:numElements
                line       = file{i+1+numNodes+1};
                parsedLine = strsplit(line);

                BMM.Elements(i,1) = str2double(parsedLine{2});
                BMM.Elements(i,2) = str2double(parsedLine{3});
                BMM.Elements(i,3) = str2double(parsedLine{4});
            end
        end
        
        function sizeInBytes = toFile(BMM, filePath)
            if ~exist('filePath', 'var')
                filePath = BMM.path;
                warning('No file path given. Existing source file will be overwritten.')
            end
            
            fid = fopen(filePath,'w');
            
            header = strjoin({ ...
                num2str(BMM.BathymetryType),...
                num2str(BMM.BathymetryUnit),...
                num2str(BMM.nodeCount),...
                BMM.SpatialReferenceSystem});
                
            fprintf(fid, [header, '\r\n']);
            
            for i = 1:BMM.nodeCount
                line = strjoin({ ...
                    num2str(i),...
                    num2str(BMM.NodeX(i)),...
                    num2str(BMM.NodeY(i)),...
                    num2str(BMM.NodeZ(i)),...
                    num2str(BMM.NodeType(i))});
            
                fprintf(fid, [line, '\r\n'] );
            end
            
            elementHeader = strjoin({ ...
                num2str(BMM.elementCount),...
                num2str(BMM.MaxNodesPerElement),...
                num2str(BMM.MeshType)});
                
            fprintf(fid, [elementHeader, '\r\n']);
            
            for i = 1:BMM.elementCount
                line = strjoin({ ...
                    num2str(i),...
                    num2str(BMM.Elements(i,1)),...
                    num2str(BMM.Elements(i,2)),...
                    num2str(BMM.Elements(i,3))});
            
                fprintf(fid, [line, '\r\n']);
            end
            
            fclose(fid);        
            
            fileInfo    = dir(filePath);
            sizeInBytes = fileInfo.bytes;
        end
        
        function c = nodeCount(BMM)
            c = numel(BMM.NodeX)
        end
        
        function c = elementCount(BMM)
            c = size(BMM.Elements,1)
        end
        
        function md = maxDepth(B)
            md = min(B.NodeZ);
        end
        
        function md = minDepth(B)
            md = max(B.NodeZ);            
        end
        
        function [a, b, c, d] = domainBounds(P)
            % Returns the model domain bounds described on the basis of the
            % minimum and maximum easting and northings. The order of the
            % outputs is min east, max east, min north, max north.
            
            minE = min(P.NodeX);
            maxE = max(P.NodeX);
            minN = min(P.NodeY);
            maxN = max(P.NodeY);

            if nargout == 1
                a = [minE, maxE, minN, maxN];
            else
                a = minE;
                b = maxE;
                c = minN;
                d = maxN;
            end
        end
        
        function h = plot(BMM, varargin)
            mesh = 0;
            % TPA 08/05/2023
            numCElems = 0;

            if ~isempty(varargin)
                for i = 1:2:size(varargin,2) % only bother with odd arguments, i.e. the labels
                    switch varargin{i}
                        case 'mesh'
                            mesh = varargin{i + 1};
                        % TPA 08/05/2023
                        case 'contour'
                            numCElems = varargin{i + 1};
                    end
                end   
            end
            
            x=BMM.NodeX;
            y=BMM.NodeY;
            z=BMM.NodeZ;
            tri=BMM.Elements;
            
            minDepth = max(BMM.NodeZ);
            maxDepth = min(BMM.NodeZ);
            % TPA 08/05/2023: Encase in "if" to allow effective plotting of a contour by
            % supplying number of levels as 'bathyContour' argument to main
            % plot function
            if numCElems == 0 || numCElems == 1
                numCElems = ceil(minDepth) - floor(maxDepth);
            end
 
            cmap = colormap(flipud(bone(numCElems)));
            
            bathyColour = zeros(numel(BMM.NodeZ),3);
            
            for i = 1:size(bathyColour,1)
                depth = BMM.NodeZ(i);
                if depth >= 10
                    % colour the land green
                    bathyColour(i,1:3) = [0 0.3 0];
                else
                    cmapIdx = 1+floor((numCElems-1)*((depth - minDepth)/(maxDepth - minDepth)));
                    
                    bathyColour(i,1:3) = cmap(cmapIdx, :);
                end
                
            end

            bathyHandle=trisurf(tri,x,y,z,'FaceVertexCData',bathyColour,'FaceColor', 'interp','EdgeColor','none','FaceAlpha',1);
            hold on;
            view(2);
            
            if mesh
                % plot mesh
                meshHandle=trimesh(tri,x,y,zeros(size(x)),'EdgeColor','k','FaceAlpha',0);
            end
            
            daspect([1 1 1]);
            shading flat;
            
            colormap(flipud(cmap));
            c = colorbar;
            ylabel(c,'depth (m)');
            caxis([maxDepth minDepth])
            
            mv = version('-release');
            
            if str2num(mv(1:4)) < 2015 | ...
                    (str2num(mv(1:4)) == 2015 & isequal(mv(5), 'a'))
                
                set(gca,'XTickLabel',sprintf('%3.f|',get(gca, 'XTick')));
                set(gca,'YTickLabel',sprintf('%3.f|',get(gca, 'YTick')));
            else               
                ax = gca;
                ax.XRuler.Exponent = 0;
                ax.YRuler.Exponent = 0;
                xtickformat('%8.f');
                ytickformat('%8.f');
            end
            
            % TPA 08/05/2023: Note that the above attempt to colour the land green does
            % nothing for an irregular mesh. The line below works, at the
            % expense of putting extra green around the water boundary too
            set(gca,'Color',[0 0.3 0])
        end
        
        function boolMatrix = shallowSeabedIndexes(B, depth)
            boolMatrix = B.NodeZ < 0 & B.NodeZ > depth;
        end
        
        function boolMatrix = deepSeabedIndexes(B, depth)
            boolMatrix = B.NodeZ < depth;
        end
        
        function adjustSeabedDepths(B, value, varargin)
            
            indexes = 1:numel(B.NodeZ);
            
            if ~isempty(varargin)
                for i = 1:2:size(varargin,2) % only bother with odd arguments, i.e. the labels
                    switch varargin{i}
                      case 'indexes'
                        indexes = varargin{i + 1};
                    end
                end   
            end
            
            B.NodeZ(indexes) = B.NodeZ(indexes) - value;
            B.NodeZ(B.NodeZ >= 10) = 10; % is the land flag relevant for triangular meshes?
        end
                    
        function adjustShallowSeabedDepths(B, value)            
            B.NodeZ(B.shallowSeabedIndexes(value)) = value;
        end
        
        function [eastings, northings] = elementCentres(B)
            [eastings, northings] = B.cellNodes;
            
            eastings  = mean(eastings, 2);
            northings = mean(northings,2);
        end
        
        % consistency with NewDepomod.BathymetryFile class
        function [eastings, northings] = cellCentres(B) 
            [eastings, northings] = B.elementCentres;
        end
                
        function [eastings, northings] = elementNodes(B)            
            eastings  = B.NodeX(B.Elements);
            northings = B.NodeY(B.Elements);           
        end
        
        % consistency with NewDepomod.BathymetryFile class
        function [eastings, northings] = cellNodes(B) 
            [eastings, northings] = B.elementNodes;
        end
    end
    
end

