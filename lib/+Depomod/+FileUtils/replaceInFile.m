function replaceInFile(filepath, oldString, newString, varargin)
    % Replaces all occurrences of a string within a file with a replacement
    % string.
    %
    % Usage:
    % 
    %    replaceInFile(filepath, oldString, newString)
    % 
    %
    % OUTPUT:
    %    
    %    No explicit Matlab output.
    %
    % EXAMPLES:
    %
    %    replaceInFile('C:\\a_dir\_a_file.txt', 'this', 'that')
    %
    
    regularExpression = 0;
    
    for i = 1:2:length(varargin)
      switch varargin{i}
        case 'regexp'
          regularExpression = varargin{i+1};
      end
    end

    tmp_path = [filepath, '.TEMP'];

    fin  = fopen(filepath, 'rt');
    fout = fopen(tmp_path, 'wt');
    
    while ~feof(fin)
       s = fgetl(fin);
       
       if regularExpression
           s = regexprep(s, oldString, newString); 
       else
           s = strrep(s, oldString, newString); % this is not idempotent!
       end
       
       fprintf(fout,'%s\n',s);
    end

    fclose(fin);
    fclose(fout);

    movefile(tmp_path, filepath, 'f');
end

