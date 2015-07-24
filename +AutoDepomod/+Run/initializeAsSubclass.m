function sc = initializeAsSubclass(package, cfgFileName)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   initializeAsSubclass.m  $
% $Revision:   1.3  $
% $Author:   ted.schlicke  $
% $Date:   May 28 2014 13:03:28  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Constructor method for creating instances of AutoDepomod.V1.Run.Base
    % using the appropriate subclass (Benthic, EmBZ, TFBZ) based on the
    % configuration file name
    %
    % Usage:
    %
    %    model = AutoDepomod.V1.Run.EmBZ(package, cfgFileName)
    %
    %  where:
    %    package: an instance of AutoDepomod.Package
    %    
    %    cfgFileName: is the filename of a .cfg file located within the
    %    /partrack directory of the package
    %
    % Output:
    %
    %   sc: an instance of a subclass of AutoDepomod.V1.Run.Base corresponding
    %   to the type of model run (Benthic, EmBZ, TFBZ).
    % 
    %
    % EXAMPLES:
    %
    %    package = AutoDepomod.Data.Package('Gorsten');
    %
    %    cfgFilename  = 'Gorsten-E-N-1.cfg'
    %    run = AutoDepomod.V1.Run.initializeAsSubclass(package, cfgFileName)
    %    run = 
    %      [1x1 AutoDepomod.V1.Run.EmBZ]
    %
    %    cfgFilename  = 'Gorsten-BcnstFI-N-1.cfg'
    %    run = AutoDepomod.V1.Run.initializeAsSubclass(package, cfgFileName)
    %    run = 
    %      [1x1 AutoDepomod.V1.Run.Benthic]
    %    
    % DEPENDENCIES:
    %
    %  - +AutoDepomod/+Run/Base.m
    %  - +AutoDepomod/+Run/Benthic.m
    %  - +AutoDepomod/+Run/Chemical.m
    %  - +AutoDepomod/+Run/EmBZ.m
    %  - +AutoDepomod/+Run/TFBZ.m
    %

    if ~isempty(regexp(cfgFileName, '-EMBZ-', 'ONCE'))
        sc = AutoDepomod.V2.Run.EmBZ(package, cfgFileName);
    elseif ~isempty(regexp(cfgFileName, '-NONE-', 'ONCE'))
        sc = AutoDepomod.V2.Run.Benthic(package, cfgFileName);
    elseif ~isempty(regexp(cfgFileName, '-TFBZ-', 'ONCE'))
        sc = AutoDepomod.V2.Run.TFBZ(package, cfgFileName);
    elseif ~isempty(regexp(cfgFileName, '-E-', 'ONCE'))
        sc = AutoDepomod.V1.Run.EmBZ(package, cfgFileName);
    elseif ~isempty(regexp(cfgFileName, '-BcnstFI-', 'ONCE'))
        sc = AutoDepomod.V1.Run.Benthic(package, cfgFileName);
    elseif ~isempty(regexp(cfgFileName, '-T-', 'ONCE'))
        sc = AutoDepomod.V1.Run.TFBZ(package, cfgFileName);
    end
end

