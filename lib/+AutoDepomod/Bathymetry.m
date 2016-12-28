classdef Bathymetry < handle
    
    properties (Constant = true)
        HeaderLines = 12;
    end
    
    properties
        path   = '';
        header = {};
        data   = [];
        
        ngridi = [];
        ngridj = [];
        ngridli = [];
        ngridlj = [];
        
        originE = 0;
        originN = 0;
        
    end
    
    methods
        
        function B = Bathymetry(filePath)
            if exist('filePath', 'var')
                B.fromFile(filePath);
            end           
        end
        
        function fromFile(B, filePath)
            B.path = filePath;
            
            file = readTxtFile(filePath);

            B.header = file(1:12);
            B.data   = zeros(length(file)-B.HeaderLines,1);

            for l = (B.HeaderLines + 1):length(file)
                line = strtrim(file{l});
                line = strrep(line, '  ', ',');
                line = strrep(line, ' ', ',');

                columns = strsplit(line, ',');
                columns = cellfun(@(x) str2num(x)*-1.0, columns, 'UniformOutput', 0);

                B.data(l-B.HeaderLines,1:length(columns)) = cell2mat(columns);
            end
            
            B.parseNGridInfo;
        end
        
        function parseNGridInfo(B)
            nGridLine = strsplit(B.header{3}, '{');
            nGridValues = strsplit(strtrim(nGridLine{1}), ' '); 
                         
            B.ngridi  = str2num(nGridValues{1});
            B.ngridj  = str2num(nGridValues{2});
            B.ngridli = str2double(nGridValues{3});
            B.ngridlj = str2double(nGridValues{4});
        end
        
        function refreshNGridInfo(B)
            nGridLine = strsplit(B.header{3}, '{');
            B.header{3} = [...
                '  ', num2str(B.ngridi), ... % 2-space delimiter
                '  ', num2str(B.ngridj), ...
                '  ', num2str(B.ngridli), ...
                '  ', num2str(B.ngridlj), ...
                '  {', nGridLine{2} ...
                ];            
        end
        
        function set.ngridi(B, val)
            B.ngridi =  val;
            B.refreshNGridInfo;
        end
        
        function set.ngridj(B, val)
            B.ngridj =  val;
            B.refreshNGridInfo;
        end
        
        function set.ngridli(B, val)
            B.ngridli =  val;
            B.refreshNGridInfo;
        end
        
        function set.ngridlj(B, val)
            B.ngridlj =  val;
            B.refreshNGridInfo;
        end
        
        function sizeInBytes = toFile(B, filePath)
            if ~exist('filePath', 'var')
                filePath = B.path;
                warning('No file path given. Existing source file will be overwritten.')
            end
            
            fid = fopen(filePath, 'w');
            
            for i = 1:length(B.header)
                fprintf(fid, [strrep(B.header{i}, '\', '\\'), '\n']); % escape '\' characters
            end
            
            for j = 1:size(B.data, 1)
                row = B.data(j,:).*-1.0
                row = num2cell(row);
                row = cellfun(@num2str, row, 'UniformOutput', 0);
                row = strjoin(row, '  ');
                
                fprintf(fid, ['  ', row, '\n']);
            end
            
            fclose(fid);
            
            fileInfo    = dir(filePath);
            sizeInBytes = fileInfo.bytes;
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
            
            [X,Y] = meshgrid(...
                B.originE:B.ngridli:(B.originE + (B.ngridli*(B.ngridi-1))), ...
                B.originN:B.ngridlj:(B.originN + (B.ngridlj*(B.ngridj-1))) ...
            );
            
            if contour
                pl = contourf(X,Y,flipud(B.data));
            else
                pl = pcolor(X,Y,flipud(B.data));
            end
            
            shading flat;
%             [cmin,cmax] = caxis;
%             caxis([cmin,10]);
            colormap(bone);
            map = colormap;
            map(end,:) = [0 0.3 0];
            colormap(map);
            c = colorbar;
            ylabel(c,'depth (m)')
        end
        
        function boolMatrix = landIndexes(B)
            boolMatrix = B.data == 10;
        end
        
        function boolMatrix = seabedIndexes(B)
            boolMatrix = ~B.landIndexes;
        end
        
        function adjustSeabedDepths(B, value)
            B.data(B.seabedIndexes) = B.data(B.seabedIndexes) - value;
        end
        
    end
    
end

