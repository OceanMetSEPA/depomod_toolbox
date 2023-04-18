classdef Java
    
    properties (Constant = true)
        versionName    = 'newDEPOMOD'
        versionNo      = 2;
        % runCommand     = '"C:\Program Files\depomodruntimecontainer\bin\depomodruntimecontainer"';
        exportCommand  = 'newDEPOMOD\scripts\RunExporter.bat';
    end
	properties
		runCommand     = '"C:\Program Files\depomodruntimecontainer\bin\depomodruntimecontainer"';
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
            showConsoleProgress = 1;
            
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
            
            if showConsoleProgress
                options = [options, ' --showConsoleProgress'];
            end
            
%             options = [options, ' --verbose'] 
        end
                
        function command = run(J, varargin)
            
            commandStringOnly = 0;
            runInBackground   = 1;
            verbose           = 1;
            
            for i = 1:2:length(varargin) % only bother with odd arguments, i.e. the labels
              switch varargin{i}
				case 'runCommand'
					J.runCommand = varargin{i+1};
                case 'commandStringOnly'
                  commandStringOnly = varargin{i+1};
                case 'runInBackground'
                  runInBackground = varargin{i+1};
                case 'verbose'
                  verbose = varargin{i+1};
              end
            end
			
			command = J.runCommandStringWithOptions(varargin{:});
            
            if ~commandStringOnly 
                if verbose
                    disp(['Starting simulation...']);
                    disp(['Command: ', command]);                    
                    disp(['Time: ', datestr(now)]);
                end
                    
                tic
                if runInBackground
                    system(['C: & ', command, ' &']);
                else
                    [s,r] = system(command);
                    disp(r);
                end
                toc
            end
        end
        
        function r = runCommandStringWithOptions(J, varargin)
            r = [J.runCommand, J.buildRunCommandOptions(varargin{:})];
        end
    end
    
end

