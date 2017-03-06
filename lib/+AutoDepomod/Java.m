classdef Java
    
    properties (Constant = true)
        releasesRootPath = 'AutoDepomod-releases'
    end
    
    properties
        release@char;
        networkLocation = 'C:\';
    end
    
    methods (Static =true)
        
        function switchRunRelease(releaseDir, exDir)
            
            if exist(releaseDir, 'dir')

                if exist(exDir, 'dir')
                    rmdir([exDir,'\java'],    's');
                    rmdir([exDir,'\scripts'], 's');
                end
                
                mkdir(exDir);

                copyfile([releaseDir, '\java'], [exDir,'\java'],'f')
                copyfile([releaseDir, '\scripts'], [exDir,'\scripts'],'f')
            else
                error('AutoDepomod:InvalidArgument', 'The release directory specified does not exist')
            end    
        end
        
        function bool = isValidProject(project)
            bool = 0;
            
            if isequal(project.name, project.directoryName)
                bool = 1;
            end
        end
        
    end
    
    methods
        
        function rd = releasesDir(J)
            rd = num2str(J.versionNo);
        end
        
        function rp = releasesPath(J)
            rp = [J.networkLocation, J.releasesRootPath, '\', J.releasesDir];
        end
        
        function rd = runDir(J)
            rd = [J.networkLocation, J.versionName];
        end
        
        function r = get.release(J)
            if isempty(J.release)
                J.release = J.latestRelease;
            end
            
            r = J.release;            
        end
        
        function vs = availableReleases(J)
            dirContents = dir(J.releasesPath);
            directoriesOnly = dirContents([dirContents.isdir] & ...
                cellfun(@(x) ~isequal(x,'.'), {dirContents.name}) & ...
                cellfun(@(x) ~isequal(x,'..'), {dirContents.name}));

            vs = cellfun(@(x) strrep(x, [J.versionName, '-'], ''), {directoriesOnly.name}, 'UniformOutput', 0);
        end
        
        function lv = latestRelease(J)
            lv = num2str(max(cellfun(@str2num, J.availableReleases)));
        end
        
        function makeRunRelease(J)
            releaseDir = [ ...
                J.releasesPath, '\', ...
                J.versionName, '-', J.release, '\', ...
                J.versionName ...
                ];
            
            disp(['Switching AutoDepomod V', num2str(J.versionNo), ' to release ', J.release]);
            
            AutoDepomod.Java.switchRunRelease(releaseDir, J.runDir);
        end
        
        function command = run(J, varargin)
            command = J.runCommandStringWithOptions(varargin{:});
            commandStringOnly = 0;
            useCurrentRelease = 1;
            
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
            r = [J.networkLocation, J.runCommand, J.buildRunCommandOptions(varargin{:})];
        end
    end
    
end

