classdef Java
    
    properties (Constant = true)
        versionName    = 'newDEPOMOD'
        versionNo      = 2;
        runCommand     = '"C:\Program Files\depomodruntimecontainer\bin\depomodruntimecontainer"';
        exportCommand  = 'newDEPOMOD\scripts\RunExporter.bat';
    end
    
    methods (Static = true)
        function [newProject, oldProject] = export(run, newProjectPath, varargin)
            J = NewDepomod.Java;
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
            r = [J.exportCommand, J.buildExportCommandOptions(run, newProjectPath, varargin{:})];
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
            singleRunOnly     = 1;
            showConsoleOutput = 1;
            modelRunTimeFile  = '';
            nosplash          = 1;
            
            for i = 1:2:length(varargin) % only bother with odd arguments, i.e. the labels
              switch varargin{i}
                case 'singleRunOnly'
                  singleRunOnly = varargin{i+1};
                case 'modelRunTimeFile'
                  modelRunTimeFile = varargin{i+1};
                case 'nosplash'
                  nosplash = varargin{i+1};
                case 'showConsoleOutput'
                  showConsoleOutput = varargin{i+1};
              end
            end
            
            options = [...
                ' --modelRunTimeFile "',    modelRunTimeFile, '"', ...
                ];
            
            if nosplash
                options = [options, ' --nosplash'];
            end
            
            if singleRunOnly
                options = [options, ' --singleRunOnly'];
            end
            
            if showConsoleOutput
                options = [options, ' --showConsoleOutput'];
            end
            
            if 1
                options = [options, ' --loggerOutputLevel "finest" --loggerOutputFile "C:/newdepomod_projects/depomodOutput.log"'];
            end
        end
                
        function command = run(J, varargin)
            command = J.runCommandStringWithOptions(varargin{:});
            commandStringOnly = 0;
            
            for i = 1:2:length(varargin) % only bother with odd arguments, i.e. the labels
              switch varargin{i}
                case 'commandStringOnly'
                  commandStringOnly = varargin{i+1};
              end
            end
            
            if ~commandStringOnly                
                system(['C: & ', command, ' &']);
            end
        end
        
        function r = runCommandStringWithOptions(J, varargin)
            r = [J.runCommand, J.buildRunCommandOptions(varargin{:})];
        end
    end
    
end

