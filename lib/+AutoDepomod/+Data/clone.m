function clonedProject = clone(project, namespace)
            
    % Creates a clone of the package data contained within the /SEPA Consent/DATA directory using a 
    % new directory with the name format /SEPA Consent/DATA-namespace. The required namespace 
    % suffix can be passed in as an argument. If no namespace is passed in then the current 
    % datetime is used as a namespace for the cloned data.
    %
    % Under this operation all files in the parent modelling package are
    % copied to a corresponding package under /SEPA Consent/DATA-namespace.
    % Absolute path references in the cloned files are updated as appropriate.
    %
    % Usage:
    %
    %    package = AutoDepomod.Data.Package('Gorsten');
    %    clonedPackage = package.clone(namespace)
    %
    %
    % OUTPUT:
    %    
    %    clonedPackage: An instance of AutoDepomod.Data.Package representing the newly created file package.     
    %
    % EXAMPLES:
    %
    %    package = AutoDepomod.Data.Package('Gorsten');
    %
    %    package.clone()    
    %      >> Creates a clone of the standard package data inside a
    %      new directory with a datetime namespace (e.g. C:\\Sepa
    %      Consent\Data-20140106121520\Gorsten)
    %
    %    package.clone('new_depomod_test')    
    %      >> Creates a clone of the standard package data inside a
    %      new directory with the specified namespace (e.g. C:\\Sepa
    %      Consent\Data-new_depomod_test\Gorsten)
    %

    if ~exist('namespace', 'var')
      % if no new namespace explicitly passed in, just use the current
      % time
      namespace = datestr(now, 'yyyymmddHHMMSS');
    end

    % Define standard and new paths
    root_path  = project.path;
    clone_path = AutoDepomod.Data.namespacePath(project.path, namespace);

    % Create clone of the \depomod subdirectory tree under new test
    % namespace. 
    %
    % Should perhaps change this to only get the required depomod *input* files
    % The output files get overwritten anyway with a rerun of the
    % model so not urgent.
    %
    if isdir(clone_path)
      disp([clone_path, ' already exists. Removing...'])
      disp('    Removing...')

      rmdir(clone_path, 's');
    end

    disp('Copying AutoDepomod files: ');
    disp(['    FROM: ', root_path]);
    disp(['    TO:   ', clone_path]);
    
    mkdir(clone_path);

    copyfile(root_path, clone_path, 'f');
    
    disp('Replacing absolute path references in files under new namespace...')

    % Replace all absolute path references within new tree to reflect new
    % location
    %
    if project.version == 1
        % list all files within the new directory tree as a CELL ARRAY
        filesToSub = fileFinder(clone_path, {'.cfg','.cfh','maj.dat','min.dat','min.ing','.log', '.inp','.inr','.out','.txt'}, 'sub', 1, 'type', 'or');
        
        for i = 1:length(filesToSub)        
          if ~isdir(filesToSub{i})
            disp(['    Updating ', filesToSub{i}, '...']);

            % Add trailing slash to substitution terms. This avoids 
            % ambiguity where the two paths share a common prefix (e.g.
            % /DATA) and prevents potential multiple concatenation
            %
            AutoDepomod.FileUtils.replaceInFile(filesToSub{i}, [root_path, '\'], [clone_path, '\']); 
          end
        end
    else
        filesToSub = fileFinder(clone_path, {'-Location.properties'}, 'sub', 1, 'type', 'or');
        root_path_string  = strrep(strrep(root_path, '\', '\\'), ':', '\:');
        clone_path_string = strrep(strrep(clone_path, '\', '\\'), ':', '\:');
        
        disp(['    Updating ', filesToSub, '...']);
        AutoDepomod.FileUtils.replaceInFile(filesToSub, root_path_string, clone_path_string);
    end

    disp(['Clone of ', project.name, ' completed.']);
   
    clonedProject = AutoDepomod.Project.createFromDataDir(project.name, namespace);
end