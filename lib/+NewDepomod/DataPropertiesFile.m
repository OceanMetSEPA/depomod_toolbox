classdef DataPropertiesFile < NewDepomod.PropertiesFile
    
    properties
        data = [];
    end
    
    % must implement a dataColumnCount property or method on this or
    % subclass
    
    methods
        
        function DPF = DataPropertiesFile(filePath, varargin)
            DPF = DPF@NewDepomod.PropertiesFile(filePath); 
            
            if ~isempty(varargin)
                for i = 1:2:size(varargin,2) % only bother with odd arguments, i.e. the labels
                    switch varargin{i}
                      case 'dataColumnCount'
                        addprop(DPF,'dataColumnCount');
                        DPF.dataColumnCount = varargin{i + 1};
                    end
                end   
            end
            
            if exist('filePath', 'var')
                DPF.parseDataFromFile();
            end           
        end
        
        function parseDataFromFile(DPF)
            fid = fopen(DPF.path, 'r');

            rowCount = 0;
            tline = fgets(fid);

            % Determine where data starts using start marker
            while ~isequal(tline(1:length(DPF.startOfDataMarker)+1), ['#',DPF.startOfDataMarker])
                tline = fgets(fid);
                rowCount = rowCount+1;
            end

            lines = {};
            
            % get each data line
            while ~isequal(tline(1:length(DPF.endOfDataMarker)+1), ['#',DPF.endOfDataMarker])
                tline = fgets(fid);
                
                if regexp(tline, '#\r\n') % fudge to address corrupt endOfDataMarker
                    break
                end
                
                lines{end+1} = tline;
            end

            fclose(fid);
            
            % Originally used csvread to parse the data, but this doesn't 
            % accommodate arbitrary delimiters (",", "  ", "\t", etc.)
            lines(end) = [];     % scrub end of data marker
            lines      = lines'; % re-orient
           
            lines = cellfun(@strtrim, lines, 'UniformOutput', 0); % strip leading whitespace
            lines = cellfun(@(x) strrep(x, '  ', ' '), lines, 'UniformOutput', 0); % strip double whitespace

            % identify delimiter
            [tokens,matches] = regexp(lines{1}, '^[\d\.\-]+([\s\t,\.]+)[\d\.\-]+','tokens','match');
            delimiter = tokens{1}{1};

            fmt = repmat([delimiter,'%f'],1,DPF.dataColumnCount);
            fmt = fmt((length(delimiter)+1):end);
            
            data = zeros(numel(lines), DPF.dataColumnCount);
            
            for l = 1:numel(lines)
                data(l, 1:DPF.dataColumnCount) = sscanf(lines{l},fmt);
            end
            
%             % split on delimiter
%             lines = cellfun(@(x) strsplit(x, delimiter),lines, 'UniformOutput', 0);
%            
%             % convert to numbers
%             data = zeros(numel(lines), numel(lines{1}));
%            
%             for l = 1:numel(lines)
%                data(l, 1:numel(lines{l})) = cell2mat(cellfun(@str2double, lines{l}, 'UniformOutput', 0));
%             end

            DPF.data = data;
        end
        
        function sizeInBytes = toFile(DPF, filePath)
            if ~exist('filePath', 'var')
                filePath = DPF.path;
                warning('No file path given. Existing source file will be overwritten.')
            end
                
            toFile@NewDepomod.PropertiesFile(DPF, filePath);
                    
            fid = fopen(filePath, 'a');
            fprintf(fid, ['#', DPF.startOfDataMarker, '\n']);
            fclose(fid);

            dlmwrite(filePath, DPF.data, ...
                '-append', ...
                'delimiter', ',', ....
                'precision', '%.9f'...
            );
        
            fid = fopen(filePath, 'a');
            fprintf(fid, ['#', DPF.endOfDataMarker, '\n']);
            fclose(fid);
        end
    end
    
end

