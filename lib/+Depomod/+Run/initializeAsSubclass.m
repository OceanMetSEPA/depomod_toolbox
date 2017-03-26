function sc = initializeAsSubclass(project, cfgFileName)
    % Constructor method for creating instances of AutoDepomod.V1.Run.Base
    % using the appropriate subclass (Benthic, EmBZ, TFBZ) based on the
    % configuration file name
    %
    % Usage:
    %
    %    model = Depomod.Run.EmBZ(package, cfgFileName)
    %
    %  where:
    %    project: an instance of Depomod.Project
    %    
    %    cfgFileName: is the filename of a .cfg file located within the
    %    /partrack directory of the package
    %
    % Output:
    %
    %   sc: an instance of a subclass of Depomod.Run.Base corresponding
    %   to the type of model run (Benthic, EmBZ, TFBZ).
    % 
    %
    % EXAMPLES:
    %
    %    project = AutoDepomod.Project.create(path);
    %
    %    cfgFilename  = 'Site-E-N-1.cfg'
    %    run = Depomod.Run.initializeAsSubclass(project, cfgFileName)
    %    run = 
    %      [1x1 Depomod.Run.EmBZ]
    %
    %    cfgFilename  = 'Site-BcnstFI-N-1.cfg'
    %    run = Depomod.Run.initializeAsSubclass(project, cfgFileName)
    %    run = 
    %      [1x1 Depomod.Run.Benthic]

    if ~isempty(regexp(cfgFileName, '-EMBZ-', 'ONCE'))
        sc = NewDepomod.Run.EmBZ(project, cfgFileName);
    elseif ~isempty(regexp(cfgFileName, '-NONE-', 'ONCE'))
        sc = NewDepomod.Run.Solids(project, cfgFileName);
    elseif ~isempty(regexp(cfgFileName, '-TFBZ-', 'ONCE'))
        sc = NewDepomod.Run.TFBZ(project, cfgFileName);
    elseif ~isempty(regexp(cfgFileName, '-E-', 'ONCE'))
        sc = AutoDepomod.Run.EmBZ(project, cfgFileName);
    elseif ~isempty(regexp(cfgFileName, '-BcnstFI-', 'ONCE'))
        sc = AutoDepomod.Run.Solids(project, cfgFileName);
    elseif ~isempty(regexp(cfgFileName, '-T-', 'ONCE'))
        sc = AutoDepomod.Run.TFBZ(project, cfgFileName);
    end
end

