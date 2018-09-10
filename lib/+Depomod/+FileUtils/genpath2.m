function p = genpath2(d,varargin)
    % genpath2 : 'hacked' version of matlab 'genpath' function
    %
    % Matlab version excludes packages and classes from path
    % This version allows these to be included if desired.
    % 
    % See 'genpath' help for info on Matlab version.
    %
    % Optional inputs:
    % 'package' (false) : include packages (folders starting with '+')
    % 'class' (false)   : include classes (starting with '@')
    % 'cell', (true)    : return output as cell array rather than char
    %
    %GENPATH Generate recursive toolbox path.
    %   P = GENPATH returns a new path string by adding all the subdirectories 
    %   of MATLABROOT/toolbox, including empty subdirectories. 
    %
    %   P = GENPATH(D) returns a path string starting in D, plus, recursively, 
    %   all the subdirectories of D, including empty subdirectories.
    %   
    %   NOTE 1: GENPATH will not exactly recreate the original MATLAB path.
    %
    %   NOTE 2: GENPATH only includes subdirectories allowed on the MATLAB
    %   path.
    %
    %   See also PATH, ADDPATH, RMPATH, SAVEPATH.
    

    if nargin==0,
        help genpath2
      return
    end

    options=struct;
    options.package=false;
    options.class=false;
    options.cell=true; 

    if ~isempty(varargin)
        for v = 1:2:length(varargin)
            switch varargin{v}
                case 'package'
                  options.package = varargin{v + 1};
                case 'class'
                  options.class = varargin{v + 1};
                case 'cell'
                  options.cell = varargin{v + 1};
            end  
        end
    end
    
    % initialise variables
    classsep = '@';  % qualifier for overloaded class directories
    packagesep = '+';  % qualifier for overloaded package directories
    p = '';           % path to be returned

    % Generate path based on given root directory
    files = dir(d);
    if isempty(files)
      return
    end

    % Add d to the path even if it is empty.
    p = [p d pathsep];

    % set logical vector for subdirectory entries in d
    isdir = logical(cat(1,files.isdir));
    %
    % Recursively descend through directories which are neither
    % private nor "class" directories.
    %
    dirs = files(isdir); % select only directory entries from the current listing

    for i=1:length(dirs)
       dirname = dirs(i).name;
       % Should we ignore class?
       classBool=~options.class && strncmp(dirname,classsep,1);
       % and package?
       packageBool=~options.package && strncmp(dirname,packagesep,1);
       if    ~strcmp( dirname,'.')          && ...
             ~strcmp( dirname,'..')         && ...  
             ~classBool && ...
             ~packageBool && ...
             ~strcmp( dirname,'private')
          p = [p Depomod.FileUtils.genpath2(fullfile(d,dirname),'cell',false,'package',options.package,'class',options.class)]; % recursive calling of this function.
       end
    end
    if options.cell
        p=regexp(p,';','split')';
        p(end)=[]; % remove final, empty cell
    end
end

