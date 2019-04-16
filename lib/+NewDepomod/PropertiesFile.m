classdef PropertiesFile < dynamicprops
        
    methods (Static = true)
        
        function outputString = escapeFilePath(inputString)
            outputString = strrep(strrep(inputString, '\', '/'), ':', '\\:');
        end
        
        function outputString = cleanFilePath(inputString)
            outputString = strrep(inputString, '\:', ':');
            outputString = strrep(outputString, '\\', '\');
            outputString = strrep(outputString, '\', '/');
            outputString = strrep(outputString, '//', '/');
        end
        
    end
    
    properties
        path = '';
    end
    
    properties (Hidden = true)
        NonParseableProperties = {};
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
               
               % This utterly lamentable section of code is intended to
               % catch a marginal flaw in the properties file format. In a
               % couple of places the heirarchical structure of keys and
               % values breaks down. This occurs in the model location
               % properties file in that a couple of specific keys hold
               % values AS WELL AS being branch nodes for further values,
               % e.g.
               %
               %    logs.runtime.stdOut=STDOUT
               %    logs.runtime.stdOut.extension=txt
               %
               % The following code section seeks to identify these and
               % cache any conflicting values so that there is not an
               % attempt to include them in the heirarchical key structure.
               % This means that some keys will not be available for
               % editing but the missing ones will be written back to file
               % in their original form. This is a messy workaround for a
               % flawed data structure. It is expected to be negligible in
               % its effect - the problematic keys are not likely to be
               % edited by a user.

               isParseable = 1;
               
               % iterate through the sequence of heirarchical keys
               for i = 2:numel(keys)
                   cmd = sprintf('fld=PF.%s', strjoin(keys(1:(i-1)), '.'));
                   evalc(cmd);

                   % Is this key already defined?
                   % If not, we can parse and include it without risking a
                   % conflict with something previously defined
                   if isfield(fld, keys{i})
                      cmd = sprintf('propClass = class(PF.%s)', strjoin(keys(1:i), '.'));
                      evalc(cmd);
                       
                      % This key is already defined (from parsing a
                      % previous row in the file) but does it hold a non
                      % struct value already and are we trying to append a
                      % new branch, OR should it be the last limb holding a
                      % real value but already holds a struct? If so, we
                      % refuse to parse it.
                      if (~isequal(propClass, 'struct') & i < numel(keys)) | ...
                          (isequal(propClass, 'struct') & i ==  numel(keys))
                      
                          isParseable = 0;
                      end
                   else
                       break
                   end
               end
               
               if isParseable
                   cmd = sprintf('PF.%s = value', keyString);
                   evalc(cmd); 
               else % cache any non-parseable lines
                   PF.NonParseableProperties{end+1} = ...
                       [keyString, '=', value];
               end
            else
               PF.(topLevelProperty) = value;
            end
        end
        
        function fromFile(PF, filePath)
            file = Depomod.FileUtils.readTxtFile(filePath);
            
            for i = 1:length(file)
               if  regexp(file{i}, '^#')
                   continue
               end
               
               if  regexp(file{i}, '.*=.*')
                   [strs, ~] = strsplit(file{i}, '=');
                                      
                   PF.addProperty(strs{1}, NewDepomod.PropertiesFile.cleanFilePath(strs{2}));
               end                
            end

            PF.path = filePath;
        end
        
        function sizeInBytes = toFile(PF, filePath)
            if ~exist('filePath', 'var')
                filePath = PF.path;
                warning('No file path given. Existing source file will be overwritten.')
            end
            
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
                    lineString = [strjoin(propertyVector, '.'), '=', NewDepomod.PropertiesFile.escapeFilePath(strtrim(value))];
                    fprintf(fid, [lineString, '\n']);
                end
            end
            
            dps = PF.dynamicPropertyNames;
            
            fid = fopen(filePath, 'w');
            
            for i = 1:length(dps)
                writePropertyStructToFile(dps(i), PF.(dps{i}))
            end
            
            for i = 1:numel(PF.NonParseableProperties)
                fprintf(fid, [PF.NonParseableProperties{i}, '\n']);
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

