classdef BathymetryFile < AutoDepomod.V2.DataPropertiesFile
    
    properties
        GridgenBathymetryFile@AutoDepomod.V1.BathymetryFile
        GridgenDomainFile@AutoDepomod.V1.DomainFile
    end
    
    methods (Static = true)
        
        function B = createFromGridgenFiles(iniFile, dataFile)
            template = [AutoDepomod.V2.Project.templatePath,...
                '\template\depomod\bathymetry\template.depomodbathymetryproperties'];
            
            B = AutoDepomod.V2.BathymetryFile(template)
            
            B.GridgenDomainFile     = AutoDepomod.V1.DomainFile(iniFile);
            B.GridgenBathymetryFile = AutoDepomod.V1.BathymetryFile(dataFile);
            
            B.path = [];
                        
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
            B@AutoDepomod.V2.DataPropertiesFile(filePath); 
        end
        
        function b = bathymetry(B)
            b = B.data;
        end
        
        function dcc = dataColumnCount(B)
            dcc = str2num(B.Domain.data.numberOfElementsY);
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
                pl = contourf(X,Y,flipud(B.data));
            else
                pl = pcolor(X,Y,flipud(B.data));
            end
            
            shading flat;
            
            colormap(bone);
            map = colormap;
            map(end,:) = [0 0.3 0];
            colormap(map);
            c = colorbar;
            ylabel(c,'depth (m)')
        end
        
        function sizeInBytes = toGridgenFiles(B)
            
            B.GridgenBathymetryFile.data = B.data;
            B.GridgenBathymetryFile.ngridi = B.Domain.data.numberOfElementsX;
            B.GridgenBathymetryFile.ngridj = B.Domain.data.numberOfElementsY;
            
            B.GridgenDomainFile.DataAreaXMin = B.Domain.spatial.minX;
            B.GridgenDomainFile.DataAreaXMax = B.Domain.spatial.maxX;
            B.GridgenDomainFile.DataAreaYMin = B.Domain.spatial.minY;
            B.GridgenDomainFile.DataAreaYMax = B.Domain.spatial.maxY;
            
            B.GridgenBathymetryFile.toFile
            B.GridgenDomainFile.toFile
            
        end
        
        function boolMatrix = landIndexes(B)
            boolMatrix = B.data == 10;
        end
        
        function boolMatrix = seabedIndexes(B)
            boolMatrix = ~B.landIndexes;
        end
        
        function adjustSeabedDepths(B, value)
            B.data(B.seabedIndexes) = B.data(B.seabedIndexes) - value;
            B.data(B.data >= 10) = 10;
        end
        
        function smoothSeabed(B)
            [seabedX,seabedY] = find(B.data ~= 10);
            
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
        
        
    end
    
end

