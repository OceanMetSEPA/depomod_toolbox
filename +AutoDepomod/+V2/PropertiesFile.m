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
       
    end
    
end

