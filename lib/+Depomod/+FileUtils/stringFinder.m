function [op] = stringFinder(strings2CompareAgainst,string2Test,varargin)
    % Function to look for string(s) within other string(s)
    %
    % function [stringMatches,indexMatches] = stringFinder(strings2CompareAgainst,string2Test,varargin)
    %
    % Matlab has various string functions (some of which are called within
    % this). This is a 'wrapper' function, designed to make comparing strings a
    % bit easier. It can also look for strings containing multiple string
    % fragments.
    %
    % It can do various types of comparison, depending on the 'type' argument:
    % *** 'exact' - returns strings/indices of exact matches
    % *** 'start' - returns strings/indices of strings which start the same
    % *** 'end'   - returns strings/indices which end the same
    % *** 'or'   - returns stringsindices of strings containing test string
    % *** 'and'   - returns strings/indices of strings containing ALL test strings (DEFAULT)
    % *** 'count' - returns count of number of times string appears
    %
    % It can also exclude matches, based on nand / nor logic inputs.
    %
    % INPUT ARGUMENTS:
    % string2Test              - string(s) to test (either char or cell)
    % strings2CompareAgainst   - strings to compare against
    %       OPTIONAL:
    % type                     - either 'exact', 'start', 'or', 'end', 'and' 'count'(see above)
    % output                   - either 'string' (default),
    %                                   'index' - integer denoting matching string,
    %                                   'bool',
    %                                   'any', - single true/false indicating whether string was found
    %
    % not                      - (default = []) exclude single term
    % nand                     - (default = []) exclude strings with ALL of these
    % nor                      - (default = []) exclude strings with ANY of these
    % sequential               - (default = false): run stringFinder for each string2Test input separately
    % first                    - (default = false): return first match
    %
    % OUTPUT ARGUMENTS:
    % matched strings, indices or bools, depending on 'output' above.
    %
    % EXAMPLES:
    % strOptions={'water level','water depth','salinity','bed shear stress'}
    %
    % stringFinder(strOptions,'salinity','type','exact','output','index')    % returns 3 (Exact match)
    % stringFinder(strOptions,'sal','type','start')         % returns 'salinity' (matching start)
    % stringFinder(strOptions,'stress','type','start')      % returns [] (no matching start)
    % stringFinder(strOptions,'stress','output','bool')         % returns [0 0 0 1]
    % stringFinder(strOptions,{'nit','st'},'type','or')     % returns [3,4] (2 separate matches)
    % stringFinder(strOptions,{'nit','st'},'type','and','output','bool')     % [0 0 0 0]
    % stringFinder(strOptions,{'w','d'},'type','or','output','index')       % returns [1,2,4]
    % stringFinder(strOptions,{'w','d'},'type','and')       % returns water depth
    % stringFinder(ls,'.m','type','end')                    % returns '.m' files in directory
    % stringFinder(ls,'*','nand','.m') % return all files without '.m'
    % stringFinder(fileread('stringFinder.m'),sprintf('\r\n'),'output','any') % check whether this function contains Windows newline specification
    % stringFinder(fileread('stringFinder.m'),char(0),'output','any') % check for presence of null character
    % stringFinder(fileread('stringFinder.m'),'the','type','count') % count number of occurences of 'the'
    % stringFinder(strOptions,{'water','stress'},'sequential',1) % return 2x1 cell
   
    if(nargin==0)
        help Depomod.FileUtils.stringFinder
        return
    end

    op=[]; % Our output!
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Declare our comparison parameters (may be overwritten by optional
    % arguments)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    comparisonTypes={'start','exact','or','end','and','count'}; % Possible comparison types
    outputOptions={'string','index','bool','any'};
    dimOptions={'row','col'};

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Check optional arguments
    % We're trying to be clever by using this function to check its own
    % arguments.
    % Need to be careful to avoid infinite recursion which causes matlab to crash!
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    options=struct;
    options.ignorecase=false;
    options.verbose=false;
    options.type='and';
    options.output='string';
    options.noMatch='warning';
    options.nand=[];
    options.nor=[];
    options.not=[];
    options.dim='col';
    options.first=0;
    options.sequential=false;

    for v = 1:2:length(varargin)
        switch varargin{v}
            case 'ignorecase'
              options.ignorecase = varargin{v + 1};
            case 'verbose'
              options.verbose = varargin{v + 1};
            case 'type'
              options.type = varargin{v + 1};
            case 'output'
              options.output = varargin{v + 1};
            case 'noMatch'
              options.noMatch = varargin{v + 1};
            case 'nand'
              options.nand = varargin{v + 1};
            case 'nor'
              options.nor = varargin{v + 1};
            case 'not'
              options.not = varargin{v + 1};
            case 'dim'
              options.dim = varargin{v + 1};
            case 'first'
              options.first = varargin{v + 1};
            case 'sequential'
              options.sequential = varargin{v + 1};
        end  
    end
    
%     options=checkArguments(options,varargin{:});

    function op=checkInputOptions(ct,ot,type)
        s=strncmp(ct,ot,length(ot));
        if ~sum(s)==1
            disp('****** VALID OPTIONS:')
            disp(ct)
            error('Unrecognised %s type; please select one of above options',type)
        else
            op=ct{s};
        end
    end
    options.type=checkInputOptions(comparisonTypes,options.type,'comparison');
    options.output=checkInputOptions(outputOptions,options.output,'output');
    options.dim=checkInputOptions(dimOptions,options.dim,'dimension');

    % Some argument checking. We'll return [] rather than throw an error if
    % arguments 1 or 2 are invalid
    if ~ischar(strings2CompareAgainst)&& ~iscell(strings2CompareAgainst)
        warning('OH:DEAR','Argument 1 is of invalid class (%s)',class(strings2CompareAgainst))
        return
    end
    if ~ischar(string2Test)&& ~iscell(string2Test)
        warning('OH:DEAR','Argument 2 is of invalid class (%s)',class(string2Test))
        return
    end
    if isempty(strings2CompareAgainst)
        warning('OH:DEAR','Argument 1 is empty')
        return
    end

    % Make sure we're working with cells
    % cellstr function removes special characters (\n,\r, null) that we may be
    % interested in. So we convert to char by enclosing in curly brackets,
    % unless char array is 2d (e.g. as returned by 'ls' function) - then we
    % need to use cellstr
    if(ischar(string2Test))
        %    string2Test=cellstr(string2Test); % doesn't work with \r, \n etc
        string2Test={string2Test};
    end
    if(ischar(strings2CompareAgainst))
        if min(size(strings2CompareAgainst))==1
            strings2CompareAgainst={strings2CompareAgainst};
        else % 2d arry of chars
            strings2CompareAgainst=cellstr(strings2CompareAgainst);
        end
    end
    type=cellstr(options.type);

    % Might want to run function for each string2Test separately
    if options.sequential
        Nop=length(string2Test);
        op=cell(Nop,1);
        args=varargin;
        f=find(cellfun(@(x)strncmp(x,'sequential',length(x)),args));
        if ~isempty(f)
            args{f+1}=0;
        end
        for i=1:Nop
            op{i}=Depomod.FileUtils.stringFinder(strings2CompareAgainst,string2Test{i},args);
        end
        return
    end

    % make sure there's no numbers
    for i=1:length(strings2CompareAgainst)
        if isnumeric(strings2CompareAgainst{i})
            strings2CompareAgainst{i}=num2str(strings2CompareAgainst{i});
        end
    end
    % Case sensitivity
    strings2CompareAgainstOriginal=strings2CompareAgainst; % Retain copy of original strings (we might capitalise them)
    if(options.ignorecase) % We're ignoring case
        strings2CompareAgainst=upper(strings2CompareAgainst); % Convert to upper case
        string2Test=upper(string2Test); % And this to upper case too
    end

    % and make sure they're column vectors:
    string2Test=string2Test(:);
    for i=1:length(string2Test)
        stri=string2Test{i};
        if iscell(stri)
            string2Test{i}=stri{:};
        end
        if ~ischar(string2Test{i})
            disp(string2Test)
            error('String to Test should be chars / cells')
        end
    end
    for i=1:length(strings2CompareAgainst)
        stri=strings2CompareAgainst{i};
        if iscell(stri)
            strings2CompareAgainst{i}=stri{:};
        end
        if ~ischar(strings2CompareAgainst{i})
            disp(strings2CompareAgainst)
            error('String to Test should be chars / cells')
        end
    end
    strings2CompareAgainst=strings2CompareAgainst(:);

    if options.verbose
        fprintf('%d String possibilities:\n',length(strings2CompareAgainst))
        disp(strings2CompareAgainstOriginal)
        fprintf('String to test:\n')
        disp(string2Test)
        fprintf('COMPARISON TYPE= %s\n',char(type))
    end

    % Set some default values for the indices
    if strcmp(type,'and')
        index=true(length(strings2CompareAgainst),1); % Need trues for 'and' condition
    elseif strcmp(type,'count')
        index=zeros(length(strings2CompareAgainst),1); % numeric
    else
        index=false(length(strings2CompareAgainst),1); % and falses for 'or'
    end

    % Abbreviations
    Nt=length(string2Test); % Number of test strings
    Nc=length(strings2CompareAgainst); % Number of string possibilites

    if Nt==1
        if strcmp(string2Test,'*')
            index=(1:Nc)';
            Nt=0;
        end
    end

    % OK, ready to go now
    for i=1:Nt % loop through test strings
        stri=string2Test{i};
        switch char(type) % which string function to use depends on 'type'
            case 'exact'
                index=index|strcmp(strings2CompareAgainst,stri);
            case 'start'
                index=index|strncmp(strings2CompareAgainst,stri,length(stri));
            case 'or'
                index=index|~cellfun('isempty',strfind(strings2CompareAgainst,stri));
                %                 index=index|strcmp(strings2CompareAgainst,stri);
            case 'and'
                index=index&~cellfun('isempty',strfind(strings2CompareAgainst,stri));
                %                index=index&strcmp(strings2CompareAgainst,stri);
            case 'end'
                % Extract end bit from each string
                endBits=cellfun(@(x)x(max(1,length(x)-length(stri))+1:end),strings2CompareAgainst,'Unif',0); % end bits of comparison strings
                index=index|strcmp(endBits,stri);
            case 'count'
                count=cellfun(@length,strfind(strings2CompareAgainst,stri));
                index=index+count;
            otherwise
                error('Unrecognised type; aborting')
        end
    end
    % Just after a count?
    if strcmp(options.type,'count')
        op=index;
        return
    end

    % Restrict strings based on logical settings.
    if sum([~isempty(options.not),~isempty(options.nor),~isempty(options.nand)])>1
        error('Only one instance of ''not'',''nor'' or ''nand'' can be used in function call')
    end

    if ~isempty(options.not)
        if ischar(options.not)
            options.not={options.not};
        end
        if length(options.not)>1
            warning('OH:DEAR','More than one exclusion selected - please use option ''nor'' or ''nand''')
        end
        ig=Depomod.FileUtils.stringFinder(strings2CompareAgainstOriginal,options.not,'type','or','output','bool');
        index=index&~ig;
    end

    % Input Logical Statement: options.nand strings are present
    % Output logical statement: keep string.
    %
    % NAND:
    % Output false if ALL inputs are true. This is equivalent to:
    % Output true if ANY inputs are NOT true.
    % Hence, we use the 'or' type to find ANY matches, and exclude those.
    if ~isempty(options.nand) % Logical NAND
        ig=Depomod.FileUtils.stringFinder(strings2CompareAgainstOriginal,options.nand,'type','or','output','bool');
        index=index&~ig;
    end

    % NOR
    % Output false if ANY inputs are true. This is equivalent to:
    % Output true if ALL inputs are NOT true.
    % Hence, we use the 'and' type to find ALL matches, and exclude those.
    if ~isempty(options.nor) % Logical OR
        ig=Depomod.FileUtils.stringFinder(strings2CompareAgainstOriginal,options.nor,'type','and','output','bool');
        index=index&~ig;
    end

    switch options.output
        case 'bool'
            op=index;
        case 'index'        
            op=find(index);
        case 'string'
            op=strings2CompareAgainstOriginal(index);
        case 'any'
            op=any(index);
    end

    if options.first && ~isempty(op)
        op=op(1);
    end

    op=op(:); % ensure output is a column vector
    if strcmp(options.dim,'row')
        op=op'; %unless we specify row!
    end

end

