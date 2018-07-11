classdef BathymetryFile < NewDepomod.DataPropertiesFile
    
    properties
        GridgenBathymetryFile@AutoDepomod.BathymetryFile
        GridgenDomainFile@AutoDepomod.DomainFile
    end
    
    methods (Static = true)
        
        function B = createFromGridgenFiles(iniFile, dataFile, varargin)
            filePath = [];
            
            for i = 1:length(varargin)
              switch varargin{i}
                case 'filePath'
                  filePath = varargin{i + 1};
              end
            end
            
            template = [NewDepomod.Project.templatePath,...
                '\template\depomod\bathymetry\template.depomodbathymetryproperties'];
            
            B = NewDepomod.BathymetryFile(template);
            
            B.GridgenDomainFile     = AutoDepomod.DomainFile(iniFile);
            B.GridgenBathymetryFile = AutoDepomod.BathymetryFile(dataFile);
            
            B.path = filePath;
                        
            B.data = B.GridgenBathymetryFile.data;
            
            B.Domain.spatial.minX = num2str(B.GridgenDomainFile.DataAreaXMin);
            B.Domain.spatial.maxX = num2str(B.GridgenDomainFile.DataAreaXMax);
            B.Domain.spatial.minY = num2str(B.GridgenDomainFile.DataAreaYMin);
            B.Domain.spatial.maxY = num2str(B.GridgenDomainFile.DataAreaYMax);
            
            B.Domain.data.numberOfElementsX = num2str(B.GridgenBathymetryFile.ngridi);
            B.Domain.data.numberOfElementsY = num2str(B.GridgenBathymetryFile.ngridj);
        end
    end
    
    methods
        
        function B = BathymetryFile(filePath)
            B@NewDepomod.DataPropertiesFile(filePath); 
        end
        
        function b = bathymetry(B)
            b = B.data;
        end
        
        function dcc = dataColumnCount(B)
            dcc = str2num(B.Domain.data.numberOfElementsX);
        end
        
        function pl = plot(B, varargin)
            contour = 0;
            
            if ~isempty(varargin)
                for i = 1:2:size(varargin,2) % only bother with odd arguments, i.e. the labels
                    switch varargin{i}
                      case 'contour'
                        contour = varargin{i + 1};
                    end
                end   
            end
            
            originE = str2num(B.Domain.spatial.minX);
            originN = str2num(B.Domain.spatial.minY);
            maxE    = str2num(B.Domain.spatial.maxX);
            maxN    = str2num(B.Domain.spatial.maxY);
            
            ngridi = str2num(B.Domain.data.numberOfElementsX);
            ngridj = str2num(B.Domain.data.numberOfElementsY);            
            
            [X,Y] = meshgrid(...
                linspace(originE,maxE,ngridi), ...
                linspace(originN,maxN,ngridj) ...
            );
            
            if contour
                [~,pl] = contourf(X,Y,flipud(B.data));
            else
                pl = pcolor(X,Y,flipud(B.data));
            end
            
            daspect([1 1 1])
            
            shading flat;
            
            colormap(B.colormap);
            c = colorbar;
            ylabel(c,'depth (m)');
            
            set(gca,'XTickLabel',sprintf('%3.f|',get(gca, 'XTick')));
            set(gca,'YTickLabel',sprintf('%3.f|',get(gca, 'YTick'))); 
        end
        
        function map = colormap(B)
            map = colormap(bone(ceil(max(B.data(:)-min(B.data(:))))));
            
            if max(B.data(:)) >= 10
                % colour the land green
                map(end,:) = [0 0.3 0];
            end
        end
                
        function sizeInBytes = toGridgenFiles(B)
            B.GridgenBathymetryFile.data = B.data;
            B.GridgenBathymetryFile.ngridi = B.Domain.data.numberOfElementsX;
            B.GridgenBathymetryFile.ngridj = B.Domain.data.numberOfElementsY;
            
            B.GridgenDomainFile.DataAreaXMin = B.Domain.spatial.minX;
            B.GridgenDomainFile.DataAreaXMax = B.Domain.spatial.maxX;
            B.GridgenDomainFile.DataAreaYMin = B.Domain.spatial.minY;
            B.GridgenDomainFile.DataAreaYMax = B.Domain.spatial.maxY;
            
            B.GridgenBathymetryFile.toFile;
            B.GridgenDomainFile.toFile;
        end
        
        function [a, b, c, d] = domainBounds(P)
            % Returns the model domain bounds described on the basis of the
            % minimum and maximum easting and northings. The order of the
            % outputs is min east, max east, min north, max north.
            
            minE = str2num(P.Domain.spatial.minX);
            maxE = str2num(P.Domain.spatial.maxX);
            minN = str2num(P.Domain.spatial.minY);
            maxN = str2num(P.Domain.spatial.maxY);

            if nargout == 1
                a = [minE, maxE, minN, maxN];
            else
                a = minE;
                b = maxE;
                c = minN;
                d = maxN;
            end
        end
        
        function md = maxDepth(B)
            md = min(min(B.data));
        end
        
        function md = minDepth(B)
            md = max(max(B.data));            
        end
        
        function boolMatrix = landIndexes(B)
            boolMatrix = B.data == 10;
        end
        
        function boolMatrix = seabedIndexes(B)
            boolMatrix = ~B.landIndexes;
        end
        
        function boolMatrix = drySeabedIndexes(B)
            boolMatrix = B.data < 10 & B.data > 0;
        end
        
        function boolMatrix = shallowSeabedIndexes(B, depth)
            boolMatrix = B.data < 0 & B.data > depth;
        end
        
        function boolMatrix = deepSeabedIndexes(B, depth)
            boolMatrix = B.data < depth;
        end
        
        function adjustSeabedDepths(B, value, varargin)
            
            indexes = B.seabedIndexes;
            
            if ~isempty(varargin)
                for i = 1:2:size(varargin,2) % only bother with odd arguments, i.e. the labels
                    switch varargin{i}
                      case 'indexes'
                        indexes = varargin{i + 1};
                    end
                end   
            end
            
            B.data(indexes) = B.data(indexes) - value;
            B.data(B.data >= 10) = 10;
        end
        
        function adjustDrySeabedDepths(B, value)
            if ~exist('value', 'var') | value > 0
                value = 10;
            end
            
            B.data(B.drySeabedIndexes) = value;
        end
                    
        function adjustShallowSeabedDepths(B, value)            
            B.data(B.shallowSeabedIndexes(value)) = value;
        end
        
        function disambiguateShoreline(B, value)  
            if ~exist('value', 'var')
                value = -1;
            end          
            
            B.adjustDrySeabedDepths(value);          
            B.adjustShallowSeabedDepths(value);
        end
        
        function smoothSeabed(B, varargin)
            [seabedX,seabedY] = find(B.data ~= 10);
            
            if ~isempty(varargin)
                for i = 1:2:size(varargin,2) % only bother with odd arguments, i.e. the labels
                    switch varargin{i}
                      case 'indexes'
                        [seabedX,seabedY] = find(varargin{i + 1});
                    end
                end   
            end
            
            for c = 1:length(seabedX)
                x = seabedX(c);
                y = seabedY(c);
                
                if x ~= 1 & x ~= size(B.data,1) & y ~= 1 & y ~= size(B.data,2)
                    B.data(x,y) = (B.data(x+1,y) + B.data(x-1,y) + B.data(x,y+1) + B.data(x,y-1))/4.0;
                elseif x == 1 & y == 1
                    B.data(x,y) = (B.data(x+1,y) + B.data(x,y+1))/2.0;
                elseif x == 1 & y == size(B.data,2)
                    B.data(x,y) = (B.data(x+1,y) + B.data(x,y-1))/2.0;
                elseif x == size(B.data,1) & y == 1
                    B.data(x,y) = (B.data(x-1,y) + B.data(x,y+1))/2.0;
                elseif x == size(B.data,1) & y == size(B.data,2)
                    B.data(x,y) = (B.data(x-1,y) + B.data(x,y-1))/2.0;
                elseif x == 1
                    B.data(x,y) = (B.data(x+1,y) + B.data(x,y-1) + B.data(x,y+1))/3.0;
                elseif y == 1
                    B.data(x,y) = (B.data(x+1,y) + B.data(x-1,y) + B.data(x,y+1))/3.0;
                elseif x == size(B.data,1) 
                    B.data(x,y) = (B.data(x-1,y) + B.data(x,y-1) + B.data(x,y+1))/3.0;
                 elseif y == size(B.data,2)
                    B.data(x,y) = (B.data(x+1,y) + B.data(x-1,y) + B.data(x,y-1))/3.0;
                end
            end
        end
        
        function l = domainLengthX(B)
            l = str2num(B.Domain.spatial.maxX) - str2num(B.Domain.spatial.minX);
        end
        
        function l = domainLengthY(B)
            l = str2num(B.Domain.spatial.maxY) - str2num(B.Domain.spatial.minY);
        end
        
        function cl = cellLengthX(B)
            cl = B.domainLengthX/str2num(B.Domain.data.numberOfElementsX);
        end
        
        function cl = cellLengthY(B)
            cl = B.domainLengthY/str2num(B.Domain.data.numberOfElementsY);
        end
        
        function [eastings, northings] = cellCentres(B)
            cellLengthX = B.cellLengthX;
            cellLengthY = B.cellLengthY;
            
            [eastings, northings] = meshgrid(...
                (str2num(B.Domain.spatial.minX)+cellLengthX/2):cellLengthX:(str2num(B.Domain.spatial.maxX)-cellLengthX/2),...
                (str2num(B.Domain.spatial.maxY)-cellLengthY/2):-cellLengthY:(str2num(B.Domain.spatial.minY)+cellLengthY/2));
        end
        
        function e = nodesX(B)
            e = linspace(str2num(B.Domain.spatial.minX), ...
                    str2num(B.Domain.spatial.maxX), ...
                    str2num(B.Domain.data.numberOfElementsX)+1 ...
                );
        end
        
        function n = nodesY(B)
            n = linspace(str2num(B.Domain.spatial.minY), ...
                    str2num(B.Domain.spatial.maxY), ...
                    str2num(B.Domain.data.numberOfElementsY)+1 ...
                );
        end
        
        function [E,N] = cellNodes(B)
            idxs = zeros(str2num(B.Domain.data.numberOfElementsX)*str2num(B.Domain.data.numberOfElementsY),4);
            
            nodesX = B.nodesX;
            nodesY = B.nodesY;
            
            count = 1;
            
            for x = 1:str2num(B.Domain.data.numberOfElementsX)
                for y = 1:str2num(B.Domain.data.numberOfElementsY)
                    E(count, 1) = nodesX(x);
                    E(count, 2) = nodesX(x);
                    E(count, 3) = nodesX(x+1);
                    E(count, 4) = nodesX(x+1);
                    
                    N(count, 1) = nodesY(y);
                    N(count, 2) = nodesY(y+1);
                    N(count, 3) = nodesY(y);
                    N(count, 4) = nodesY(y+1);
                    
                    count = count + 1;
                end
            end
        end
    end
end

