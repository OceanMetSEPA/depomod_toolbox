function [filesFound] = fileFinder(varargin)
    % This function looks within directories for files whose names contains certain strings.
    % It will return the full path of any matching files
    %
    % filesFound=fileFinder(varargin)
    %
    % INPUTS:
    %
    % 1) directory(ies) - either a char or cell array. If none provided, pwd is checked
    % 2) string2Test - either a char or cell array. If none provided, no filtering occurs
    %
    % Options:
    %  * 'subDirectory' (false) - check all subdirectories
    %  * 'file' (default = []; ignored) - if 1, return files, if 0 exclude files
    %  * 'dir' (default = []; ignored) - if 1, return directories, if 0 exlude directories
    %  * 'path' (default = true) - apply string filtering to path as well as filename
    %  * 'fullPath' (default = true) - return full path rather than just file name
    %  * 'dot' (default = false) - keep '.' and '..' directories
    %  * 'output' (default = []; Default behavoir is that the class of output depends on number of files found:
    %       * char, if single file found
    %       * cell, if more than one file found
    %       Specify
    %       'output','char' to ensure char output
    %       'output','cell' to ensure cell output
    %  * other string filtering options such as 'and', 'any', 'start','not' etc
    %            See 'stringFinder' function help for info on these options
    %  * 'verbose' (false) - spew out lots of print statements
    % OUTPUTS:
    %
    % filesFound : matching file names, with complete paths
    %
    % EXAMPLES:
    %
    % fileFinder(pwd) % all files / directories in present working directory
    % fileFinder('.xls','sub',1) % all excel files including subdirectories
    % fileFinder('C:\d3dModelling\sepaWAQBase2010_325_Seq','.ada','sub',1,'nand',{'tmp','Alt'}) % all .ada files in modelling folders - exclude 'tmp' and 'Alt'
    % fileFinder('C:\d3dModelling\sepaWAQBase2010_325_Seq\P*','.ada') % only check directories starting with 'P'
    % fileFinder('plot','path',0) %
    
    if(nargin==0)
        help fileFinder
        return
    end

    % Process input arguments:
    % 1) Find directory(ies) we're supposed to check
    % Note - we might not pass any directories, in which case check pwd
    arg=varargin{1};
    
    % may be a char or a cell (typically if we're checking multiple
    % directories)
    if ischar(arg)
        arg=cellstr(arg); % we'll work with cells from here on in
    end
    
    % Check for * wildcard (ie specify multiple directories at once)
    Nd=length(arg);
    p=cell(Nd,1);
    for i=1:Nd
        diri=arg{i};
        ast=regexp(diri,'*'); % check for '*'
        if ~isempty(ast) % is it there?
            slash=regexp(diri,filesep); % if so, find last '\' in path
            stem=diri(1:(max(slash(slash<ast)))); % keep bit before that
            lsm=cellstr(ls(diri)); % list 
            lsm=lsm(~Depomod.FileUtils.stringFinder(lsm,{'.','..'},'type','or','output','bool')); % remove . and ..
            diri=strcat(stem,lsm);
        else
            diri={diri};
        end
        p{i}=diri;
    end
    arg=horzcat(p{:}); % Bundle these directories together

    mp=regexp(path,';','split');
    if ~isempty(arg)
        % are directories in matlab path? 
        for i=1:length(arg)
            str=Depomod.FileUtils.stringFinder(mp,arg{i},'type','end','ignorecase',true);
            if ~isempty(str)
                strLength=cellfun(@length,str);
                str=str(strLength==min(strLength));
                arg(i)=str;
            end
        end

    else% didn't supply list of directories?
        arg={pwd}; % then check pwd
    end
    % Make sure these are in fact directories:
    if ~all(cellfun(@isdir,arg))
        arg={pwd};
    else
        varargin(1)=[]; % remove our directories from varargin list (we've got the info we need!)
    end
    directories=arg;
    %    
    % 2) Now determine strings we're looking for in file/directory names
    % How many vargs do we have?
    Nargs=length(varargin);
    if mod(Nargs,2)==1 % Odd number?
        string2Test=varargin{1}; % Check for 1st argument
        varargin(1)=[];
    else % Even number - assume these are args for setting options
        string2Test='*'; % Check for everything
    end

    % Options
    options=struct;
    % Allow option to choose whether we want to keep full path
    options.path=true;
    options.fullPath=true;
    options.ext=true;
    options.output=[]; % cell or char
    options.subDirectory=false;
    options.verbose=0;
    options.dir=[];
    options.file=[];
    options.dots=false; % Keep directories '.' , '..' which are returned by ls function
    
    % We're passing all arguments (including those that we'll pass onto
    % stringFinder function). So ignore warnings...
    if ~isempty(varargin)
        for v = 1:2:length(varargin)
            switch varargin{v}
                case 'path'
                  options.path = varargin{v + 1};
                case 'fullPath'
                  options.fullPath = varargin{v + 1};
                case 'ext'
                  options.ext = varargin{v + 1};
                case 'output'
                  options.output = varargin{v + 1};
                case 'subDirectory'
                  options.subDirectory = varargin{v + 1};
                case 'verbose'
                  options.verbose = varargin{v + 1};
                case 'dir'
                  options.dir = varargin{v + 1};
                case 'file'
                  options.file = varargin{v + 1};
                case 'dots'
                  options.dots = varargin{v + 1};
                otherwise
                    options.(varargin{v}) = varargin{v + 1};
            end  
        end
    end

    if options.verbose
        fprintf('DIRECTORY TO CHECK:\n')
        disp(directories)
        fprintf('STRINGS 2 TEST:\n')
        disp(string2Test)
    end

    % Check all directories are valid.
    directories=directories(cellfun(@isdir,directories));
    Nd=length(directories);

    % CHECK OUTPUT TYPE:
    validTypes={'cell','char'};
    if ~isempty(options.output)
        ok=Depomod.FileUtils.stringFinder(validTypes,options.output,'output','index');
        if isempty(ok)
            error('Invalid options ''output'' - please use either ''cell'' or ''char''')
        else
            options.output=validTypes{ok};
        end
    end

    % We're going to pass our varargin arguments to the stringFinder function
    % (so we can have optionality of 'not','nand',etc). But we don't want to
    % pass our output argument...
    argNames=varargin(1:2:end);
    if ~isempty(argNames)
        index=Depomod.FileUtils.stringFinder(argNames,'output','output','index');
        if ~isempty(index)
            index=2*(index-1)+1; % find position of 'output' in varargin
            varargin(index+(0:1))=[]; % remove that index and the one following
        end
    end

    if(options.verbose)
    %    fprintf('About to start looping through %d directories...\n',Nd)
    end
    filesFound=cell(Nd,1); % space to store our matching files

    %%%%%%%%%%%%%%%%%%%%%%%%%%% HERE WE GO!
    for iInputDir=1:Nd % loop through input directories
        dir2Check=directories(iInputDir); % check this directory
        if(options.subDirectory) % Find subdirectories
            dir2Check=regexp(Depomod.FileUtils.genpath2(char(dir2Check),'package',1,'cell',0),';','split'); % All subdirectories, as cell array
            subdirLength=cellfun(@length,dir2Check); % Find length of each subdirectory
            dir2Check(subdirLength==0)=[]; % Only retain subdirectores with length > 0
        end
        NDir2Check=length(dir2Check);
        filesInDir=cell(NDir2Check,1); % space to store files
        for iDir2Check=1:NDir2Check % For each subdirectory
            checkThisDir=dir2Check{iDir2Check};
            if(options.verbose)
    %            fprintf('Checking directory ''%s'' (%d of %d)\n',checkThisDir,iDir2Check,NDir2Check)
            end
            %        fprintf('Checking subdir ''%s'' (%d of %d)\n',subdir,subdiri,length(subdirs))
            % Determine separator to use between path (directory) and file name.
            % If path ends with '\', don't need one
            % Otherwise, we'll introduce a slash
            if checkThisDir(length(checkThisDir))~=filesep
                %            separator='\';
                %        else
                %            separator='';
                checkThisDir=sprintf('%s%s',checkThisDir,filesep);
            end
            % Call function to look for strings in contents of this directory
            filesInDirectory=ls(checkThisDir);
            if ~isempty(filesInDirectory)
                % should we include path in our string that we're testing?
                if options.path
                    strings2Check=strcat(checkThisDir,filesInDirectory);
                else
                    strings2Check=filesInDirectory;
                end
                % Check which files we found match our test strings:
                fileMatches=Depomod.FileUtils.stringFinder(strings2Check,string2Test,varargin{:},'noMatch','ignore','verbose',0);
                if ~isempty(fileMatches)
                    if options.fullPath && ~options.path % user wants full path, but we didn't add it above
                        fileMatches=strcat(checkThisDir,fileMatches);
                    elseif ~options.fullPath
                        fileMatches=strrep(fileMatches,checkThisDir,'');
                    end
                    if(~options.ext) % don't want extension?
                        for fmi=1:length(fileMatches) % for each matching file
                            filename=fileMatches{fmi};
                            dotPos=regexp(filename,'\.');
                            if(~isempty(dotPos))
                                dotPos=dotPos(length(dotPos));
                                filename=filename(1:(dotPos-1));
                            end
                            fileMatches{i}=filename;  % Replace filename
                        end
                    end
                    if ~options.dots % ls function returns '.' and '..' - we probably don't want these
                        Nf=length(fileMatches);
                        k=true(Nf,1);
                        for fmi=1:length(fileMatches) % for each matching file
                            filename=fileMatches{fmi};
                            if filename(end)=='.'
                                k(fmi)=false;
                            end
                        end
                        fileMatches(~k)=[];
                    end
                    if options.verbose
                        fprintf('Found %d files in dir ''%s''\n',length(fileMatches),checkThisDir)
                        fprintf('________________________________________________________________________________\n')
                    end
                    filesInDir{iDir2Check}=fileMatches; % Add matching files from this subdirectory
                end
            end
        end
        filesFound{iInputDir}=vertcat(filesInDir{:}); % Add all files from this input directory
    end
    % Bundle up all our files:
    filesFound=vertcat(filesFound{:});

    if isempty(filesFound)
        filesFound=[]; % rather than returning {} (empty cell array)
        return
    end
    % Might want to restrict to directories / files
    if ~isempty(options.dir)
        filesFound=filesFound(cellfun(@isdir,filesFound)==options.dir);
    end

    % Did user specify char / cell as output?
    % No? Then use default approach (char for single file; cell for multiple)
    if isempty(options.output)
        if length(filesFound)==1
            filesFound=char(filesFound);
        end
    elseif strcmp(options.output,'char')
        filesFound=char(filesFound);
    end

    if iscell(filesFound)
        filesFound=filesFound(:); % Make sure it's a column vector - better for displaying output
    end

end
