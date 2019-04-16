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
           
    end
    
    % Instance
    
    properties
        project;     % owning modelling project
        cfgFileName; % filename of cfg file, indicates run number
        number;      % model run number
        cages;
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

            version = R.project.version;
            
            if version == 2
                s = Depomod.Sur.Base.fromFile(surPath, 'version', version);
            else
                [e, n] = R.project.southWest;

                if ~isempty(e) && ~isempty(n) && ~isnan(e) && ~isnan(n)
                    s = Depomod.Sur.Base.fromFile(surPath, 'version', version, 'Easting', num2str(e), 'Northing', num2str(n));
                else
                    s = Depomod.Sur.Base.fromFile(surPath, 'version', version);
                end
            end
        end
        
        function F = plot(R,varargin)
            
            x0=0;
            y0=0;
            width=600;
            height=600;
            
            sur       = [];
            impact    = 1;
            plotCages = 1;
            visible   = 'on';
            contour   = 1;
            levels    = [];
            color     = 'red';
            
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
                case 'visible'
                  visible = varargin{i+1};
                case 'contour'
                  contour = varargin{i+1};
                case 'color'
                  color = varargin{i+1};
              end
            end
                        
            F = figure('visible', visible);
            R.project.bathymetry.plot('contour', contour);    
            daspect([1 1 1])
            hold on
            set(gcf,'units','points','position',[x0,y0,width,height]);
            box on
            grid on
            set(gca,'layer','top')
            xlabel('Easting');
            ylabel('Northing');
            
            t=title([R.project.name, ': run - ', R.label]);
            set(t,'Interpreter','none'); % escape underscores in title            
            
            if isempty(sur)
                try
                    sur = R.sur;
                catch
                    impact = 0;
                end
            end
            
            if impact & ~isempty(sur)
                if isempty(levels)
                    levels = sur.defaultPlotLevels;
                end
                
                noLevels = length(levels);
                
                legendContours = [];
                legendlabels   = {};

                for l = 1:noLevels
                    level = levels(l);

                    contour = sur.contour(level);

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
                        validIndexes = ~isnan(x) & ~isnan(y);
                        contourhandle = fill(x(validIndexes),y(validIndexes), color, 'FaceAlpha', val, 'LineStyle', ':');

                        i = i + contour(2,i) + 1;
                    end
                    
                    if exist('contourhandle', 'var') & ~isempty(contourhandle)
                        legendContours(end+1) = contourhandle;
                        legendlabels{end+1}   = [ num2str(level), ' ', sur.defaultUnit];
                    end
                end
                
                if ~isempty(legendContours)
                    leg = legend(legendContours,legendlabels);

                    PatchInLegend = findobj(leg, 'type', 'patch'); 

                    % to find the patch objects in your legend. You can then set their transparency using 
                    for l = 1:size(PatchInLegend,1)
                        % start with alpha 0.5 and split the rest between 0.5-1.0

                        val = 0.25 + (0.5-(0.5/noLevels) * (l - 1));
                        set(PatchInLegend(l), 'facea', val);               
                    end
                end
            end
            
            mv = version('-release');
            
            if str2num(mv(1:4)) < 2015 | ...
                    (str2num(mv(1:4)) == 2015 & isequal(mv(5), 'a'))
                
                set(gca,'XTickLabel',sprintf('%3.f|',get(gca, 'XTick')));
                set(gca,'YTickLabel',sprintf('%3.f|',get(gca, 'YTick')));
            else               
                ax = gca;
                ax.XAxis.Exponent = 0;
                ax.YAxis.Exponent = 0;
            end
            
            if plotCages
                cages = R.cages.consolidatedCages.cages;

                figure(F)
                scatter3(...
                    cellfun(@(c) c.x, cages), ...
                    cellfun(@(c) c.y, cages), ...
                    repmat(11,length(cages),1), ...
                    'wo', ...
                    'MarkerFaceColor', 'k', ...
                    'LineWidth', 1.0, ...
                    'Visible', 'on', ...
                    'Clipping', 'on' ...
                    );
                
                set(gca,'layer','top')
            end
            
            drawnow
        end
        
        
        
        function F = patch(R,varargin)
            
            x0=0;
            y0=0;
            width=600;
            height=600;
            
            sur       = [];
            impact    = 1;
            plotCages = 1;
            visible   = 'on';
            contour   = 1;
            levels    = [];
            
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
                case 'visible'
                  visible = varargin{i+1};
                case 'contour'
                  contour = varargin{i+1};
              end
            end
                        
            F = figure('visible', visible);
            R.project.bathymetry.plot('contour', contour);    
            daspect([1 1 1])
            hold on
            set(gcf,'units','points','position',[x0,y0,width,height]);
            box on
            grid on
            set(gca,'layer','top')
            xlabel('Northing');
            ylabel('Easting');
            
            t=title([R.project.name, ': run - ', num2str(R.label)]);
            set(t,'Interpreter','none'); % escape underscores in title            
            
            if isempty(sur)
                try
                    sur = R.sur;
                catch
                    impact = 0;
                end
            end
            
            if impact & ~isempty(sur)
                if isempty(levels)
                    levels = sur.defaultPlotLevels;
                end
                
                noLevels = length(levels);
                
                legendContours = [];
                legendlabels   = {};

                pcolor(sur.X, sur.Y, sur.Z)

                leg = legend(legendContours,legendlabels);

                PatchInLegend = findobj(leg, 'type', 'patch'); 

                % to find the patch objects in your legend. You can then set their transparency using 
                for l = 1:size(PatchInLegend,1)
                    % start with alpha 0.5 and split the rest between 0.5-1.0
                    val = 0.5 + (0.5-(0.5/noLevels) * (l - 1));
                    set(PatchInLegend(l), 'facea', val);               
                end
            end
            
%             set(gca,'XTickLabel',sprintf('%3.f|',get(gca, 'XTick')));
%             set(gca,'YTickLabel',sprintf('%3.f|',get(gca, 'YTick')));
            
            if plotCages
                cages = R.cages.consolidatedCages.cages;

                figure(F)
                scatter3(cellfun(@(c) c.x, cages), cellfun(@(c) c.y, cages),repmat(max(max(R.project.bathymetry.data))+1,length(cages),1), 'ko', 'MarkerFaceColor', 'k', 'LineWidth', 2.0, 'Visible', 'on', 'Clipping', 'on');
                set(gca,'layer','top')
            end
            
            drawnow
        end
    end

end

