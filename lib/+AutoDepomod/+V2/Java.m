classdef Java < AutoDepomod.Java
    
    properties (Constant = true)
        versionName    = 'newDEPOMOD'
        versionNo      = 2;
        runCommand     = 'newDEPOMOD\scripts\RunModel.bat';
        exportCommand  = 'newDEPOMOD\scripts\RunExporter.bat';
    end
    
    methods (Static = true)
        function [newProject, oldProject] = export(run, newProjectPath, varargin)
            J = AutoDepomod.V2.Java;
            [newProject, oldProject] = J.exportRun(run, newProjectPath, varargin{:});
        end
    end
    
    methods 
        
        function [newProject, oldProject] = exportRun(J, run, newProjectPath, varargin)

            system(J.exportCommandStringWithOptions(run, newProjectPath, varargin{:}));

            newProject = AutoDepomod.Project.create([newProjectPath, '\', run.project.name]);
            oldProject = run.project;
        end
        
        function r = exportCommandStringWithOptions(J, run, newProjectPath, varargin)
            r = [J.networkLocation, J.exportCommand, J.buildExportCommandOptions(run, newProjectPath, varargin{:})];
        end
        
        function options = buildExportCommandOptions(J, run, newProjectPath, varargin)
            verbose   = 1;
            logOutput = 0;
            
            for i = 1:2:length(varargin)
              switch varargin{i}
                case 'logOutput'
                  logOutput = varargin{i+1};
                case 'verbose'
                  verbose = varargin{i+1};
              end
            end
                
            options = [...
                ' /inputDataPath "',       run.project.parentPath, '"', ...
                ' /outputDataPath "',      newProjectPath, '"', ...
                ' /siteName "',            run.project.name, '"', ...
                ' /modelParametersFile "', run.cfgFileName, '"' ...
                ];
        
            if verbose
                options = [options, ' /verbose'];
            end
            
            if logOutput
                options = [options, ' /logOutput'];
            end
        end
        
        function options = buildRunCommandOptions(J, varargin)
            siteName = '';
            dataPath = '';
            singleRunOnly = 1;
            logOutput     = 0;
            verbose       = 1;
            modelParametersFile    = '';
            modelLocationFile      = '';
            modelConfigurationFile = '';
            modelDefaultsFilePath  = '';
            maxBioMassLimit        = '';
            
            for i = 1:2:length(varargin) % only bother with odd arguments, i.e. the labels
              switch varargin{i}
                case 'siteName'
                  siteName = varargin{i+1};
                case 'dataPath'
                  dataPath = varargin{i+1};
                case 'singleRunOnly'
                  singleRunOnly = varargin{i+1};
                case 'logOutput'
                  logOutput = varargin{i+1};
                case 'verbose'
                  verbose = varargin{i+1};
                case 'modelParametersFile'
                  modelParametersFile = varargin{i+1};
                case 'modelLocationFile'
                  modelLocationFile = varargin{i+1};
                case 'modelConfigurationFile'
                  modelConfigurationFile = varargin{i+1};
                case 'modelDefaultsFilePath'
                  modelDefaultsFilePath = varargin{i+1};
                case 'maxBioMassLimit'
                  maxBioMassLimit = varargin{i+1};
              end
            end
            
            options = [...
                ' /dataPath "',    dataPath, '"', ...
                ' /siteName "',     siteName, '"', ...
                ' /modelParametersFile "',    modelParametersFile, '"', ...
                ' /modelLocationFile "',      modelLocationFile, '"', ...
                ' /modelConfigurationFile "', modelConfigurationFile, '"', ...
                ];
            
            
            if ~isempty(modelDefaultsFilePath)
                options = [options, ' /modelDefaultsFilePath "', modelDefaultsFilePath, '"'];
            end
            
            if ~isempty(maxBioMassLimit)
                options = [options, ' /maxBioMassLimit', maxBioMassLimit];
            end
            
            if verbose
                options = [options, ' /verbose'];
            end
            
            if singleRunOnly
                options = [options, ' /singleRunOnly'];
            end
            
            if logOutput
                options = [options, ' /logOutput'];
            end
        end
    end
    
end

