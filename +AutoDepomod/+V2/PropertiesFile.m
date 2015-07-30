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
            
%             fid = fopen(filePath, 'w');
            
            function pc = abcd(resultVector, value)
                if isequal(class(value), 'struct')
                    fn = fieldnames(value)
                    for n = 1:length(fn)
                       resultVector(end+1) = {fn{n}}
                       nextValue = strjoin(resultVector, ''').(''')
                       nextValue = sprintf('''%s''', nextValue)
                       
                       disp('FFFF')
                       sprintf('PF.(%s)', nextValue)
                       eval(sprintf('PF.(%s)', nextValue))
                       abcd(resultVector, eval(sprintf('PF.(%s)', nextValue)))
                       resultVector(end) = [];
                    end
                else
                    disp('NNNNNNNNNNNNN')
                    string = [strjoin(resultVector, '.'), '=', value]
%                     fprintf(fid, [TF.headerString, '\n']);
                end
                
            end
            
            for i = 1:length(dps)
                if any(strcmp(dps{i}, {'startOfDataMarker', 'endOfDataMarker'}))
                    continue
                end
                
                resultVector = {dps{i}};
                abcd(resultVector, PF.(dps{i}))
                
                
            end
%             fclose(fid);
        end
        
        function dp = dynamicPropertyNames(IPF)
            m = metaclass(IPF);
            allProperties = properties(IPF);
            classDefProperties = {m.PropertyList.Name};
            dp = setdiff(allProperties', classDefProperties); % note transposition operator
        end
       
    end
    
end

