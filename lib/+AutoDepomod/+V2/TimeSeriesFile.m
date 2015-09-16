classdef TimeSeriesFile < dynamicprops
    
    properties
        path    = '';
        headers = {};
        units   = {};
        data    = [];
        
        propnames = {};
    end
    
    methods
        function TF = TimeSeriesFile(filePath)
            if exist('filePath', 'var')
                TF.fromFile(filePath)
            end           
        end
                
        function fromFile(TF, filePath)
            f = importdata(filePath);
            TF.parseHeaderInfo(f.colheaders);
            TF.data = f.data;
            
            for i = 1:length(TF.headers)
                propertyName = strrep(TF.headers{i}, ' ', '_');
                
                if ~isprop(propertyName)
                    prop = addprop(TF, propertyName);
                    prop.Dependent = true;
                    prop.GetMethod = @(TF)getDynPropValue(TF,propertyName);
                    prop.SetMethod = @(TF,value)setDynPropValue(TF,propertyName,value);

                    TF.propnames{end+1}=propertyName;
                end
            end

            TF.path = filePath;
        end

        function sizeInBytes = toFile(TF, filePath)
            fid = fopen(filePath, 'w');
            fprintf(fid, [TF.headerString, '\n']);
            fclose(fid);

            dlmwrite(filePath, TF.data, ...
                '-append', ...
                'delimiter', ',', ....
                'precision', '%.9f'...
            );

            fileInfo    = dir(filePath);
            sizeInBytes = fileInfo.bytes;
        end

        function ts = toTimeSeries(TF, column)
            ts = AutoDepomod.TimeSeries.createFromTimeSeriesFile(TF, column);
        end
    end

    methods (Access = protected)

        function val = getDynPropValue(TF, name)
            idx = find(strcmp(TF.propnames,name));
            val = TF.data(:,idx);
        end
        
        function TF = setDynPropValue(TF, name, value)
            idx = strcmp(TF.propnames,name);
            TF.data(:,idx) = value;
        end
        
        function parseHeaderInfo(TF, headerArray)
            headerRegex = '(.*) \((.*)\)';

            for h = 1:size(headerArray, 2)
                 [~,t]=regexp(headerArray{h}, headerRegex, 'match', 'tokens');
                 TF.headers{end+1} = t{1}{1};
                 TF.units{end+1}   = t{1}{2};
            end
        end

        function hs = headerString(TF)
            headerStrings = {};

            for i = 1:length(TF.headers)
                headerStrings{i} = [TF.headers{i}, ' (', TF.units{i}, ')'];
            end

            hs = strjoin(headerStrings, ',');
        end
    end
    
end