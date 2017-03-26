classdef Java < Depomod.Java
    
    properties (Constant = true)
        versionName = 'DEPOMOD'
        versionNo   = 1;
        runCommand  = 'DEPOMOD\scripts\RunJava';
    end
    
    
    methods
        
        function options = buildRunCommandOptions(J, varargin)
            siteName    = '';
            cfgFileName = '';
            dataPath    = '';
            verbose     = 1;
            
            for i = 1:2:length(varargin) % only bother with odd arguments, i.e. the labels
              switch varargin{i}
                case 'siteName'
                  siteName = varargin{i+1};
                case 'cfgFileName'
                  cfgFileName = varargin{i+1};
                case 'dataPath'
                  dataPath = varargin{i+1};
                case 'verbose'
                  verbose = varargin{i+1};
              end
            end
            
            options = [...
                ' /siteName "',    siteName,    '"', ...
                ' /cfgFileName "', cfgFileName, '"', ...
                ' /dataPath "',    dataPath,    '"'
                ];
            
            if verbose
                options = [options, ' /verbose'];
            end

        end
        
    end
    
end

