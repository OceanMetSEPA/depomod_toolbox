classdef (Abstract) Base < handle
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
        
        function runNo = parseRunNumber(filename, version)
            % Returns the run number from a given filename. This can be
            % used to obtain the run number form most AutoDepomod files
            % including .cfg, .cfh, .sur, .grd, .prn, etc.
            %
            % Usage:
            %
            %    runNo = AutoDepomod.V1.Run.Base.parseRunNumber(filename)
            %
            % EXAMPLES:
            %
            %    AutoDepomod.V1.Run.Base.parseRunNumber('Gorsten-E-S-4.cfg')
            %    ans = 
            %        4
            %
            %    AutoDepomod.V1.Run.Base.parseRunNumber('Gorsten-E-S-5g1.prn')
            %    ans = 
            %        5
            %    
            if version == 1
                [bool, ~, ~, ~, number, ~, ~] = AutoDepomod.Run.Base.isValidConfigFileName(filename);
            else
                [bool, ~, ~, ~, number, ~, ~] = NewDepomod.Run.Base.isValidConfigFileName(filename);
            end
            
            if bool
                runNo = number;
            else
                runNo = [];
            end
        end
        
        function [bool, varargout] = isValidConfigFileName(filename, version)
            % Returns true if the given filename is a valid AutoDepomod configuration or output filename.
            % If the filename is valid, the fileparts are returned as per
            % AutoDepomod.V1.Run.Base.cfgFileParts.
            %
            % Usage:
            %
            %    bool = AutoDepomod.V1.Run.Base.isValidConfigFileName(filename)
            %
            % EXAMPLES:
            %
            %    AutoDepomod.V1.Run.Base.isValidConfigFileName('Gorsten-E-S-5g1.sur')
            %    ans = 
            %        1
            %
            %    AutoDepomod.V1.Run.Base.isValidConfigFileName('Gorsten-ES5g1.prn')
            %    ans = 
            %        0
            %    
            
            if version == 1
                [sitename, type, tide, number, filetype, ext] = AutoDepomod.Run.Base.cfgFileParts(filename);
            else
                [sitename, type, tide, number, filetype, ext] = NewDepomod.Run.Base.cfgFileParts(filename);
            end
            
            bool = ~isempty(sitename) && ~isempty(type) && ~isempty(tide) && ~isempty(number) && ~isempty(ext);
            varargout = cell(6,1);
            
            if bool
                varargout{1} = sitename;
                varargout{2} = type;
                varargout{3} = tide;
                varargout{4} = number;
                varargout{5} = filetype;
                varargout{6} = ext;
            end
        end
        
        function [sitename, type, tide, number, filetype, ext] = cfgFileParts(filename, version)
            % Returns the fileparts associated with AutoDepomod
            % configuration or output filenames. These
            % parts are as follows:
            %
            %   1. site name
            %   2. model run type (BcnstFI, E, T)
            %   3. Tidal context (S,N)
            %   4. Run number
            %   5. G-Model status (0,1,2,3)
            %   6. file extension
            %
            % Usage:
            %
            %    [sitename, type, tide, number, g, ext] = cfgFileParts(filename)
            %
            % EXAMPLES:
            %
            %    [sitename, type, tide, number, g, ext] = cfgFileParts('Gorsten-E-S-5g1.sur')
            %    sitename = 
            %        'Gorsten'
            %    type = 
            %        'E'
            %    tide = 
            %        'S'
            %    number = 
            %        5
            %    g = 
            %        'g1'
            %    ext = 
            %        'sur'
            %    
            
            if version == 1
                [~,t]=regexp(filename, AutoDepomod.Run.Base.FilenameRegex, 'match', 'tokens');
            else
                [~,t]=regexp(filename, NewDepomod.Run.Base.FilenameRegex, 'match', 'tokens');
            end
            
            if isempty(t)
                sitename = [];
                type     = [];
                tide     = [];
                number   = [];
                filetype = [];
                ext      = [];
            else
                sitename = t{1}{1};
                type     = t{1}{2};
                tide     = t{1}{3};
                number   = t{1}{4};
                filetype        = t{1}{5};
                ext      = t{1}{6};
            end
        end
        
        function str = dispersionCoefficientReplaceString(dim,value)
            str = [num2str(value), '   k', dim,'  {m2/s'];
        end
    end
    
    % Instance
    
    properties
        project;     % owning modelling project
        cfgFileName; % filename of cfg file, indicates run number
        runNumber;   % model run number
        log;         % property for memoizing log information for this run, saves multiple calls
        cages;
        tide;
    end
    
    methods
        
        function bool = isSolids(R)
            % Returns true if the model run is a benthic run
            bool = ~isempty(regexp(class(R), 'Solids', 'ONCE'));
        end

        function bool = isEmBZ(R)
            % Returns true if the model run is a EmBZ run
            bool = ~isempty(regexp(class(R), 'EmBZ', 'ONCE'));
        end

        function bool = isTFBZ(R)
            % Returns true if the model run is a TFBZ run
            bool = ~isempty(regexp(class(R), 'TFBZ', 'ONCE'));
        end
        
        function t = get.tide(R)
            [~, ~, t, ~, ~, ~] = AutoDepomod.Run.Base.cfgFileParts(R.cfgFileName, R.project.version);
        end

        function l = get.log(R)
            % Returns a struct representing the model run log data
            if isempty(R.log)
                R.initializeLog;
            end
            
            l = R.log;
        end
        
        function c = get.cages(R)
            if isempty(R.cages)
               R.initializeCages; 
            end
            
            c = R.cages;
        end
        
        function s = initializeSur(R, surPath) 
            % Returns an instance of Depomod.Outputs.Sur representing the
            % model run sur file associated with the passed in index. The
            % index relates to the G-model status of the sur file, as
            % indicated by the 'g-' sequence in the filename.
            
            [e, n] = R.project.southWest;
            version = R.project.version;
                        
            if ~isempty(e) && ~isempty(n) && ~isnan(e) && ~isnan(n)
                s = Depomod.Sur.Base.fromFile(surPath, 'version', version, 'Easting', num2str(e), 'Northing', num2str(n));
            else
                s = Depomod.Sur.Base.fromFile(surPath, 'version', version);
            end
        end
        
        function F = plot(R,varargin)
            
            x0=10;
            y0=10;
            width=800;
            height=800;
            
            levels = R.defaultPlotLevels;
            
            sur = [];
            impact = 1;
            plotCages = 1;
            
            for i = 1:2:length(varargin)
              switch varargin{i}
                case 'x0'
                  x0 = varargin{i+1};
                case 'y0'
                  y0 = varargin{i+1};
                case 'width'
                  width = varargin{i+1};
                case 'height'
                  height = varargin{i+1};
                case 'levels'
                  levels = varargin{i+1};
                case 'impact'
                  impact = varargin{i+1};
                case 'cages'
                  plotCages = varargin{i+1};
                case 'sur'
                  sur = varargin{i+1};
                  impact = 1; % if sur passed, definately plot an impact
              end
            end
            
            noLevels = length(levels);
            
            F = figure;
            R.project.bathymetry.plot('contour', 1);            
            hold on
            set(gcf,'units','points','position',[x0,y0,width,height]);
            box on
            grid on
            set(gca,'layer','top')
            xlabel('Northing');
            ylabel('Easting');

            if plotCages
                cages = R.cages.consolidatedCages.cages;

                figure(F)
                scatter(cellfun(@(c) c.x, cages), cellfun(@(c) c.y, cages), 'ko', 'MarkerFaceColor', 'k', 'LineWidth', 2.0, 'Visible', 'on', 'Clipping', 'on')
                set(gca,'layer','top')
            end

            if isempty(sur)
                sur = R.sur;
            end
            
            t=title([R.project.name, ': run - ', num2str(R.runNumber)]);
            % escape underscores in title
            set(t,'Interpreter','none');

            if impact & ~isempty(sur)
                legendContours = [];
                legendlabels   = {};

                for l = 1:noLevels
                    level = levels(l);

                    contour = sur.contour(level, 'plot', 0);

                    val = 0.1 + ((0.5/noLevels) * (l));

                    i = 1;

                    while i <= size(contour,2)
                        x = [];
                        y = [];

                        for j = i+1:i+contour(2,i)
                            x(1,end+1) = contour(1,j);
                            y(1,end+1) = contour(2,j);
                        end

                        figure(F)
                        contourhandle = patch(x,y,'red', 'FaceAlpha', val, 'LineStyle', ':');

                        i = i + contour(2,i) + 1;
                    end

                    if ~isempty(contour)
                        legendContours(end+1) = contourhandle;
                        legendlabels{end+1}   = [num2str(level), ' ', R.defaultUnit];
                    end
                end

                leg = legend(legendContours,legendlabels);

                PatchInLegend = findobj(leg, 'type', 'patch'); 

                % to find the patch objects in your legend. You can then set their transparency using 
                for l = 1:noLevels
                    % start with alpha 0.5 and split the rest between 0.5-1.0
                    val = 0.5 + (0.5-(0.5/noLevels) * (l - 1));
                    set(PatchInLegend(l), 'facea', val);               
                end
            end
            set(gca,'XTickLabel',sprintf('%3.f|',get(gca, 'XTick')));
            set(gca,'YTickLabel',sprintf('%3.f|',get(gca, 'YTick'))); 
        end
    end

end

