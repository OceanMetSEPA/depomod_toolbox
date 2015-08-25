classdef Base < AutoDepomod.Run.Base
    % Wrapper class for a individual model runs in AutoDepomod. This class provides a
    % number of convenience methods for locating files and handling model runs and some outputs. 
    %
    % This class is not intended to be used directly but is intended to be subclassed with the 
    % introduction of a typeCode property (see Run.Benthic, Run.EmBZ, Run.TFBZ)
    %
    % Model objects are instantiated by passing in an instance of AutoDepomod.Package, together with
    % a .cfg filename.
    %
    % Usage:
    %
    %    model = AutoDepomod.V1.Run.Base(farm, cfgFileName)
    %
    %  where:
    %    farm: an instance of AutoDepomod.Package
    %    
    %    cfgFileName: is the filename of a .cfg file located within the
    %    /partrack directory of the project (and namespace if provided)
    % 
    %
    % EXAMPLES:
    %
    %    project = AutoDepomod.Data.Package('Gorsten');
    %    run  = AutoDepomod.V1.Run.Benthic(project, 'Gorsten-BcnstFI-N-1.cfg') % SUBCLASS
    %
    %    run.project   
    %      >> returns an instance of AutoDepomod.Package
    %
    %    run.cfgFileName   
    %      >> ans = 
    %      Gorsten-BcnstFI-N-1.cfg
    %    
    %    run.execute()    
    %      >> runs Java depomod if located under AutoDepomod.Data.root path
    %    
    %    sur = run.sur    
    %      >> returns instance of Depomod.Outputs.Sur representing the
    %      g0.sur file associated with the model run
    %    
    % DEPENDENCIES:
    %
    %  - +AutoDepomod/+Data/root.m
    %  - +AutoDepomod/Package.m
    %  - +AutoDepomod/Logfile.m
    %  - +Depomod/+Outputs/Sur.m
    % 
    
    % Class
    
    methods (Static = true)
        
        function runNo = parseRunNumber(filename)
            runNo = AutoDepomod.Run.Base.parseRunNumber(filename, 1);
        end
        
        function [bool, sitename, type, tide, number, g, ext] = isValidConfigFileName(filename)
            [bool, sitename, type, tide, number, g, ext] = AutoDepomod.Run.Base.isValidConfigFileName(filename, 1);            
        end
        
        function [sitename, type, tide, number, g, ext] = cfgFileParts(filename)
            [sitename, type, tide, number, g, ext] = AutoDepomod.Run.Base.cfgFileParts(filename, 1);
        end
        
        function str = dispersionCoefficientReplaceString(dim,value)
            str = [num2str(value), '   k', dim,'  {m2/s'];
        end
    end
    
    % Instance
    
    properties (Constant = true, Hidden = true)
        FilenameRegex = '^(.+)\-(BcnstFI|E|T)\-(S|N)\-(\d+)(g\d+)?\.(cfg|cfh|fil|flx|inp|inr|sur|out|plu|put|prn)$';
    end
    
    methods
        function R = Base(project, cfgFileName)
            
            R.project     = project;
            R.cfgFileName = cfgFileName;
                                              
            R.runNumber = AutoDepomod.V1.Run.Base.parseRunNumber(R.cfgFileName);
            
            if isempty(R.runNumber)
                errName = 'AutoDepomod:Run:MissingRunNumber';
                errDesc = 'Cannot instantiate Run object. cfgFileName has unexpected format, cannot locate run number.';
                err = MException(errName, errDesc);
                
                throw(err)
            end
        end
        
        function name = configFileRoot(R)
            % Returns just the filename for the model run cfg file, omitting the extension
            [~, name, ~] = fileparts(R.cfgFileName);
        end
        
        function p = configPath(R)
            % Returns full path for the model run cfg file
            p = strcat(R.project.partrackPath, '\', R.cfgFileName);
        end
        
        function p = surPath(R, index)
            % Returns the path to the model run sur file. By default, the
            % 0-index sur file path is returned. Pass in the index to
            % return a different surfile (e.g. 1, for EmBZ decay)
            
            if ~exist('index', 'var')
                index = 0; % Default is the 0 indexed sur file
            end

            p = strcat(R.project.resusPath, '\', R.configFileRoot, ['g', num2str(index), '.sur']);
        end
                 
        function cpn = cagesPath(R)
            cagesDirectory = R.project.resusPath;
            cageFileName = strrep(R.cfgFileName, '.cfg', '_CAGES.csv');
            
            cpn = [cagesDirectory, '\', cageFileName];
        end
        
        function initializeCages(R)
            R.cages = AutoDepomod.Layout.Site.fromCSV(R.cagesPath);
        end
        
        function initializeLog(R)
            logfile = R.project.log(R.typeCode); % typeCode defined in subclasses
            R.log = logfile.run(R.runNumber);
        end
         
        function coeffs = dispersionCoefficients(R)
            cfgData = Depomod.Inputs.Readers.readCfg(R.configPath);
            coeffs = cfgData.DispersionCoefficients;
        end
        
        function coeff = dispersionCoefficient(R,dim)
            coeffs = R.dispersionCoefficients;
            coeff = coeffs{find(cellfun(@(x) isequal(x, dim) , coeffs(:, 1))), 2};
        end
        
        function setDispersionCoefficient(R, dim, value)
            currentValue = R.dispersionCoefficient(dim);
            oldString = AutoDepomod.V1.Run.Base.dispersionCoefficientReplaceString(dim, currentValue);
            newString = AutoDepomod.V1.Run.Base.dispersionCoefficientReplaceString(dim, value);
            
            AutoDepomod.FileUtils.replaceInFile(R.configPath, oldString, newString);
        end
        
        function newProject = exportFiles(R, exportPath, varargin)
            newProject = AutoDepomod.V2.Java.export(R, exportPath, varargin{:})
        end
        
        function cmd = execute(R, varargin)
            % Invokes Depomod on the model run configuration, overwriting
            % any output files  
            
            if AutoDepomod.Java.isValidProject(R.project)
                dataPath = R.project.parentPath;
                
                jv = AutoDepomod.V1.Java;
                
                commandStringOnly = 0;
            
                for i = 1:2:length(varargin)
                  switch varargin{i}
                    case 'release'
                      release = varargin{i+1};
                    case 'commandStringOnly'
                      commandStringOnly = varargin{i+1};
                  end
                end
            
                if exist('release', 'var')
                    jv.release = release; 
                end
                
                cmd = jv.run(...
                    'commandStringOnly', commandStringOnly, ...,
                    'siteName',    R.project.name, ...
                    'cfgFileName', R.cfgFileName, ...
                    'dataPath',    dataPath ...
                    );
            else
               error('AutoDepomod:Java', ...
                    [ 'This is not a valid project for running the Java module. ', ...
                      'The parent directory must be named after the project.' ...
                      ]);
            end
        end
       
    end

end

