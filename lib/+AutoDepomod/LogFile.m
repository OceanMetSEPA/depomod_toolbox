classdef LogFile
    % Wrapper class for AutoDepomod log files. This class provides a
    % number of convenience methods for representing logfiles and individual model run logs. A logfile can be 
    % accessed in tabular (i.e. matrix) form or as a set of structs representing each model run. 
    %
    % Usage:
    %
    %    logFile = AutoDepomod.V1.Logfile(path)
    %
    %  where:
    %    path: is the absolute path to a logfile
    %
    % EXAMPLES:
    %
    %    filePath = 'C:\path\path\modelling\resus\site-EMBZ.log';
    %    logFile  = AutoDepomod.Logfile(filePath);
    %
    %    logFile.table
    %    ans =    
    %      [cell matrix representing the logfile rows and columns]
    %
    %    logFile.run(4)   
    %    ans = 
    %      [struct representing run number 4]
    %    
    %    logFile.all 
    %    ans = 
    %      [struct array representing all runs]
    %    
    
    properties
        filePath = '';
        table    = {};   
        runNoRow = 3;
    end
    
    methods (Access = private)
        
        function rns = runNumbers(LF)
            % Returns a list of the run numbers for all of the runs
            % described in the logfile
            rns = LF.table(2:end-1,LF.runNoRow); % skip empty row at end
        end
        
    end
    
    methods
        function LF = LogFile(path)
            LF.filePath = path;      % memoize the path
            rows = Depomod.FileUtils.readTxtFile(path);% read the log file
    
            % create a matrix representation of the logfile table
            for row = 1:size(rows,1)
                values = strsplit(rows{row}, ',');
            
                for column = 1:size(values, 2)
                    value = strrep(values(column),'"','');            
                    LF.table(row, column) = value;
                end
            end
        end
        
        function str = run(LF, runNumber)
            % Returns a struct represent the logfile summary statistics
            % associated with the passed in run number
            
            str = struct;
           
            % Find the row in the matrix representation of the log file
            % which corresponds to the passed in run number
            matchingRow = cellfun(@(x) isequal(num2str(runNumber), x) , LF.table(:,LF.runNoRow));
            runData = LF.table(matchingRow, :);
           
            % Iterate through each column of the run and create a struct representation,
            % formatting the values and headers as appropriate 
            for column = 1:size(runData, 2)   
                if isempty(LF.table{1,column})
                    continue;
                end
                
                value = AutoDepomod.LogFile.castValue(runData{1,column});  
                str.(AutoDepomod.LogFile.formatHeader(LF.table{1,column})) = value;
            end
        end
        
        function a = all(LF)
            % Return an array of structs each representing a run associated
            % with the logfile. The struct structure is the same as that
            % returned by AutoDepomod.Logfile.run()
            
            runNumbers = LF.runNumbers;
            
            a = cellfun(@(x) LF.run(x), runNumbers(:));
        end
        
        function ls = headers(LF)
            % Returns an array describing the headers of the log file
            ls = LF.table(1,:);
        end
    end
    
    methods (Static = true)
        function h = formatHeader(header)
            % Returns a formatted version of a logfile column header than
            % can be used as a struct label
            
            h = regexprep(header, '(\([a-z]+\)|XX%)', ''); % Strip out the dodgy characters.
        end
        
        function v = castValue(value)
            % Returns the passed in token cast into an appropriate data
            % type: string, number or date.
                        
            number = str2double(value);

            if ~isnan(number)
                value = number;
            else
                if ~isempty(value) & regexp(value, '\d{2}/\d{2}/\d{4} \d{2}:\d{2}:\d{2}')
                    value = datenum(value, 'dd/mm/yyyy HH:MM:SS');
                end
            end
            
            v = value;
        end
    end
end

