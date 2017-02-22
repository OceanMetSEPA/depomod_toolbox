classdef BathymetryFile < AutoDepomod.V2.DataPropertiesFile
    
    properties
        GridgenBathymetryFile@AutoDepomod.V1.BathymetryFile
        GridgenDomainFile@AutoDepomod.V1.DomainFile
    end
    
    methods (Static = true)
        
        function B = createFromGridgenFiles(iniFile, dataFile)
            ini       = AutoDepomod.V1.DomainFile(iniFile);
            bathyData = AutoDepomod.V1.BathymetryFile(dataFile);
            
            B = AutoDepomod.V2.BathymetryFile()
            
            B.GridgenBathymetryFile = bathyData;
            B.GridgenDomainFile     = ini;
            
            B.data = bathyData.data;
            
            
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
        
        
    end
    
end

