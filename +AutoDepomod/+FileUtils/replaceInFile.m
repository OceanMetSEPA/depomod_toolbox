function replaceInFile(filepath, oldString, newString)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   replaceInFile.m  $
% $Revision:   1.2  $
% $Author:   ted.schlicke  $
% $Date:   May 28 2014 13:03:24  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
    
    tmp_path = [filepath, '.TEMP'];

    fin  = fopen(filepath, 'rt');
    fout = fopen(tmp_path, 'wt');
    
    while ~feof(fin)
       s = fgetl(fin);
       s = strrep(s, oldString, newString); % this is not idempotent!
       fprintf(fout,'%s\n',s);
    end

    fclose(fin);
    fclose(fout);

    movefile(tmp_path, filepath, 'f');
end

