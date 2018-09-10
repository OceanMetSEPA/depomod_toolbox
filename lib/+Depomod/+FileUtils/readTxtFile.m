function [ txt ] = readTxtFile(f,varargin)
    % Read text file into cell array.
    %
    % This function uses Matlab function 'fileread', which loads file into
    % one long char array. It then splits this char so each row is contained
    % within a separate cell. Further processing can be done by specifying
    % optional arguments.
    %
    % INPUT: filename
    %
    % Optional Inputs:
    % trim (false) - trim white space (call 'strtrim' for each line)
    % empty (true)  - keep empty strings
    % verbose (false)   - print messages as function proceeds
    % startRow (1)  - ignore any rows before this value
    % split ([])  - split individual rows by this character
    % expand (true) - if split non-empty, expand 1d cell array of cell arrays
    % to 2d cell array of chars (only works if same number of elements in each
    % row)
    %
    % OUTPUT: cell array of strings
    %
    % EXAMPLE: Reading a csv file
    %
    % txt=readTxtFile('test.csv'); % txt is 1d cell array of chars (each cell is a row of text)
    % txt=readTxtFile('test.csv','split',',','expand',0); % txt is a 1d cell array of cell arrays, where each cell contains a comma-separated char 
    % txt=readTxtFile('test.csv','split',',','expand',1); % txt is a 2d cell array of chars
    %
    %

    if nargin==0
        help Depomod.FileUtils.readTxtFile
        return
    end
    % Allow user to pass cellstr
    if iscellstr(f)
        f=char(f);
    end
    if ~ischar(f)
        error('Input should be a char')
    end

    options=struct;
    options.trim=false;
    options.empty=true;
    options.split=[];
    options.expand=true;
    options.startRow=1;
    options.verbose=false;
    options.standardiseNewline=true;
    
    for v = 1:2:length(varargin)
      switch varargin{v}
        case 'trim'
          options.trim = varargin{v + 1};
        case 'empty'
          options.empty = varargin{v + 1};
        case 'split'
          options.split = varargin{v + 1};
        case 'expand'
          options.expand = varargin{v + 1};
        case 'startRow'
          options.startRow = varargin{v + 1};
        case 'verbose'
          options.verbose = varargin{v + 1};
        case 'standardiseNewline'
          options.standardiseNewline = varargin{v + 1};
      end
    end
    

    if ~exist(f,'file')
        error('''%s'' not a file!\n',f)
    end

    txt=fileread(f); % Read file into one long char

    if options.verbose
        fprintf('READING ''%s''; length = %d\n',f,length(txt))
    end

    if options.standardiseNewline
        % Different platforms use different characters for new line:
        % MAC new line = \r ASCII 13
        % Unix new line = \n ASCII 10
        % Windows new line = \r\n
        % Matlab's fileread function seems to interpret \r\n as two new lines
        % So we might want to replace any instances of these single \n.
        newLine=sprintf('\n');
        carriageReturn=sprintf('\r');
        windowsNewLine=sprintf('\r\n');
        if options.verbose
            numberOfNewLines=length(regexp(txt,newLine));
            numberOfCarriageReturns=length(regexp(txt,carriageReturn));
            numberOfWindowsNewLines=length(regexp(txt,windowsNewLine));
            fprintf('New line characters found in text file:\n')
            fprintf('%d ''\\n''\n',numberOfNewLines);
            fprintf('%d ''\\r''\n',numberOfCarriageReturns);
            fprintf('%d ''\\r\\n''\n',numberOfWindowsNewLines);
        end
        txt=strrep(txt,windowsNewLine,newLine);
        txt=strrep(txt,carriageReturn,newLine);
    end

    txt=regexp(txt,'\n','split')';

    if length(txt)==1
        warning('OH:DEAR','No new lines found in file!');
        fprintf('ASCII:\n')
        disp(uint8(options.newlineChar))
    end

    if isempty(txt{end}) % remove last element if it's empty
        txt(end)=[];
    end

    if options.trim
        txt=cellfun(@strtrim,txt,'UniformOutput',0); % Trim string
    end

    if options.startRow>1 % remove header
        if options.startRow>length(txt)
            error('Start row %d larger than txt length %d',options.startRow,length(txt))
        end
        txt(1:(options.startRow-1))=[];
    end

    if ~options.empty || ~isempty(options.split)
        k=~cellfun(@isempty,txt);
        txt=txt(k); % Remove empty strings
    end

    if ~isempty(options.split)
        txt=regexp(txt,options.split,'split');
        k=cellfun(@length,txt);
        if length(unique(k))==1 && options.expand
            txt=vertcat(txt{:});
        elseif options.verbose
            fprintf('Different length rows; returning 1d cell array\n')
        end
    end
    if options.verbose
        fprintf('Returning cell of size\n')
        disp(size(txt))
    end

end
