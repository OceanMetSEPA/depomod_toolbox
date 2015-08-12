classdef InputsPropertiesFile < AutoDepomod.V2.PropertiesFile
    
    properties
        data = [];
    end
    
    methods
        
        function IPF = InputsPropertiesFile(filePath)
            IPF = IPF@AutoDepomod.V2.PropertiesFile(filePath);  
            
            if exist('filePath', 'var')
                IPF.parseDataFromFile();
            end           
        end
        
        function parseDataFromFile(IPF)
            fid = fopen(IPF.path, 'r');

            rowCount = 0;
            tline = fgets(fid);

            % Determine where data starts using start marker
            while ~isequal(tline(1:length(IPF.startOfDataMarker)+1), ['#',IPF.startOfDataMarker])
                tline = fgets(fid);
                rowCount = rowCount+1;
            end

            dataStartIdx = rowCount+1; % add 1 for next row AFTER start marker

            % Determine where data ends using end marker
            while ~isequal(tline(1:length(IPF.endOfDataMarker)+1), ['#',IPF.endOfDataMarker])
                tline = fgets(fid);
                rowCount = rowCount+1;
            end

            dataEndIdx = rowCount-1; % subtract 1 for last row BEFORE end marker

            fclose(fid);

            % Now read just the tabular data
            IPF.data = csvread(IPF.path, dataStartIdx, 0, [dataStartIdx, 0, dataEndIdx, 5]);
        end
        
        function sizeInBytes = toFile(IPF, filePath)
            if ~exist('filePath', 'var')
                filePath = IPF.path;
                warning('No file path given. Existing source file will be overwritten.')
            end
                
            toFile@AutoDepomod.V2.PropertiesFile(IPF, filePath);
                    
            fid = fopen(filePath, 'a');
            fprintf(fid, ['#', IPF.startOfDataMarker, '\n']);
            fclose(fid);

            dlmwrite(filePath, IPF.data, ...
                '-append', ...
                'delimiter', ',', ....
                'precision', '%.9f'...
            );
        
            fid = fopen(filePath, 'a');
            fprintf(fid, ['#', IPF.endOfDataMarker, '\n']);
            fclose(fid);
        end
    end
    
end

