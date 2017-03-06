classdef DomainFile
    
    properties
        DataAreaXMin;
        DataAreaXMax;
        DataAreaYMin;
        DataAreaYMax;
        path;
    end
    
    methods
        
        function DF = DomainFile(path)
            
            DF.path = path;
            
            [minE, maxE, minN, maxN] = AutoDepomod.FileUtils.Inputs.Readers.readGridgenIni(DF.path);
            
            DF.DataAreaXMin = minE;
            DF.DataAreaXMax = maxE;
            DF.DataAreaYMin = minN;
            DF.DataAreaYMax = maxN;
        end
        
        
        function sizeInBytes = toFile(DF, filePath)
            
            if ~exist('filePath', 'var')
                filePath = DF.path;
                warning('No file path given. Existing source file will be overwritten.')
            end

            fid = fopen(filePath, 'w');

            fprintf(fid, ['DataAreaXMin=', num2str(DF.DataAreaXMin), '\n']);
            fprintf(fid, ['DataAreaXMax=', num2str(DF.DataAreaXMax), '\n']);
            fprintf(fid, ['DataAreaYMin=', num2str(DF.DataAreaYMin), '\n']);
            fprintf(fid, ['DataAreaYMax=', num2str(DF.DataAreaYMax), '\n']);

            fclose(fid);
            
            fileInfo    = dir(filePath);
            sizeInBytes = fileInfo.bytes;
        end
    end
    
end

