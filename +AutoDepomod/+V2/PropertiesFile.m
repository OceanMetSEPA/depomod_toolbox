classdef PropertiesFile < dynamicprops
        
    properties
        path = '';
    end
    
    methods
        function PF = PropertiesFile(filePath)
            if exist('filePath', 'var')
                PF.fromFile(filePath);
            end           
        end
        
        function addProperty(PF, keys, value)
            % Pass in either cell array or dot-delimited string of keys
            
            if ischar(keys)
                keyString = keys;
                [keys, ~] = strsplit(keyString, '.');
            else
                keyString = strjoin(keys, '.');
            end
            
            if ischar(keys)
               topLevelProperty = keys;
            else
               topLevelProperty = keys{1};
            end

            if ~isprop(PF, topLevelProperty)
               addprop(PF, topLevelProperty);
            end

            if length(keys) > 1
               if isempty(PF.(topLevelProperty))
                   PF.(topLevelProperty) = struct;
               end
               
               cmd = sprintf('PF.%s = value', keyString);
               evalc(cmd); 
            else
               PF.(topLevelProperty) = value;
            end
        end
        
        function fromFile(PF, filePath)
            file = readTxtFile(filePath);
            
            for i = 1:length(file)
               if  regexp(file{i}, '.*=.*')
                   [strs, ~] = strsplit(file{i}, '=');
                                      
                   PF.addProperty(strs{1}, strs{2});
               end                
            end

            PF.path = filePath;
        end
        
        function sizeInBytes = toFile(PF, filePath)
            if ~exist('filePath', 'var')
                filePath = PF.path;
                warning('No file path given. Existing source file will be overwritten.')
            end
            
            dps = PF.dynamicPropertyNames;
            
            fid = fopen(filePath, 'w');
            
            function writePropertyStructToFile(propertyVector, value)
                if isequal(class(value), 'struct')
                    fn = fieldnames(value);
                    
                    for n = 1:length(fn)
                       propertyVector(end+1) = fn(n);                       
                       nextValue = strjoin( ...
                           cellfun(@(x) sprintf('(''%s'')', x), propertyVector, 'UniformOutput', 0), ...
                           '.');
                       
                       writePropertyStructToFile(propertyVector, eval(sprintf('PF.%s', nextValue)))
                       propertyVector(end) = [];
                    end
                else
                    lineString = [strjoin(propertyVector, '.'), '=', value];
                    fprintf(fid, [lineString, '\n']);
                end
            end
            
            for i = 1:length(dps)
                writePropertyStructToFile(dps(i), PF.(dps{i}))
            end
            
            fclose(fid);
            
            fileInfo    = dir(filePath);
            sizeInBytes = fileInfo.bytes;
        end
        
        function dp = dynamicPropertyNames(IPF)
            m = metaclass(IPF);
            allProperties = properties(IPF);
            classDefProperties = {m.PropertyList.Name};
            dp = setdiff(allProperties', classDefProperties); % note transposition operator
        end
       
    end
    
end

