classdef DataPropertiesFile < AutoDepomod.V2.PropertiesFile
    
    properties
        data = [];
    end
    
    methods
        
        function DPF = DataPropertiesFile(filePath)
            DPF = DPF@AutoDepomod.V2.PropertiesFile(filePath);  
            
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

            dataStartIdx = rowCount+1; % add 1 for next row AFTER start marker

            % Determine where data ends using end marker
            while ~isequal(tline(1:length(DPF.endOfDataMarker)+1), ['#',DPF.endOfDataMarker])
                tline = fgets(fid);
                rowCount = rowCount+1;
            end

            dataEndIdx = rowCount-1; % subtract 1 for last row BEFORE end marker

            fclose(fid);

            % Now read just the tabular data
            DPF.data = csvread(DPF.path, dataStartIdx, 0, [dataStartIdx, 0, dataEndIdx, DPF.dataColumnCount-1]);
        end
        
        function sizeInBytes = toFile(DPF, filePath)
            if ~exist('filePath', 'var')
                filePath = DPF.path;
                warning('No file path given. Existing source file will be overwritten.')
            end
                
            toFile@AutoDepomod.V2.PropertiesFile(DPF, filePath);
                    
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

