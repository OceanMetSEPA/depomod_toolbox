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
            mv = version('-release');
            
            x0=0;
            y0=-100;
            width=600;
            height=600;
            
            sur       = [];
            impact    = 1;
            plotCages = 1;
            cageSize  = 1;
            visible   = 'on';
            bathyContour  = 1;
            impactContour = 0;
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
                    case 'cageSize'
                        cageSize = varargin{i+1};
                    case 'sur'
                        sur = varargin{i+1};
                        impact = 1; % if sur passed, definitely plot an impact
                    case 'visible'
                        visible = varargin{i+1};
                    case 'bathyContour'
                        bathyContour = varargin{i+1};
                    case 'impactContour'
                        impactContour = varargin{i+1};
                    case 'color'
                        color = varargin{i+1};
                end
            end
            
            F = figure('visible', visible);
            R.project.bathymetry.plot('contour', bathyContour);
            daspect([1 1 1]);
            hold on
            set(gcf,'units','points','position',[x0,y0,width,height]);
            box on
            grid on
            set(gca,'layer','top');
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
                
                if impactContour
                    
                    % Plot impact as a contour
                    
                    for l = 1:noLevels
                        level = levels(l);
                        
                        contr = sur.contour(level);
                        
                        val = 0.1 + ((0.5/noLevels) * (l));
                        
                        i = 1;
                        contourhandle  = [];
                        
                        while i <= size(contr,2)
                            x = [];
                            y = [];
                            
                            for j = i+1:i+contr(2,i)
                                x(1,end+1) = contr(1,j);
                                y(1,end+1) = contr(2,j);
                            end
                            
                            figure(F);
                            validIndexes = ~isnan(x) & ~isnan(y);
                            contourhandle = fill(x(validIndexes),y(validIndexes), color, 'FaceAlpha', val, 'LineStyle', ':');
                            
                            i = i + contr(2,i) + 1;
                        end
                        
                        if exist('contourhandle', 'var') & ~isempty(contourhandle)
                            legendContours(end+1) = contourhandle;
                            legendlabels{end+1}   = [ num2str(level), ' ', sur.defaultUnit];
                        end
                    end
                else
                    % Plot impact cellwise
                    
%                    [E,N] = R.project.bathymetry.cellNodes;
                    % Using E,N coordinates from above gives unrealistic (e.g. impact on land) when
                    % bathy size < sur size.
                    % Here we generate x,y vectors covering extent of domain with size matching
                    % sur.Z value. This seems to fix things.
                    % Andy used double for loop to populate E,N. But can do it by manipulating meshgrid.
                    try
                        dom=R.project.bathymetry.Domain.spatial;
                        minX=str2double(dom.minX);
                        minY=str2double(dom.minY);
                        maxX=str2double(dom.maxX);
                        maxY=str2double(dom.maxY);
                    catch
%                     dom=R.project.bathymetry.Domain.spatial;
                        try
                            minX=str2double(min(R.project.bathymetry.NodeX));
                            minY=str2double(min(R.project.bathymetry.NodeY));
                            maxX=str2double(max(R.project.bathymetry.NodeX));
                            maxY=str2double(max(R.project.bathymetry.NodeY));
                        catch
                            print('Cannot define model extent')
                        end
                    end
                    set(gca,'Xlim',[minX,maxX])
                    set(gca,'Ylim',[minY,maxY])

                    Nx=length(sur.X)+1;
                    Ny=length(sur.Y)+1;
                    X=linspace(minX,maxX,Nx);
                    Y=linspace(minY,maxY,Ny);
                    [xg,yg]=meshgrid(X,Y);
                    x1=xg(1:end-1,1:end-1);
                    x2=xg(2:end,2:end);
                    x1=x1(:);
                    x2=x2(:);
                    E=[x1,x1,x2,x2];
                    
                    y1=yg(1:end-1,1:end-1);
                    y2=yg(2:end,2:end);
                    y1=y1(:);
                    y2=y2(:);
                    N=[y1,y2,y1,y2];
                    % End of X,Y manipulation
                    Z = sur.Z;
                    Z(Z==0)=NaN;
                    
                    % need to treat square and triangular grids separately
                    bathyDim=size(E,2);
                    switch bathyDim
                        case 4  % Square grid:
                            Z = reshape(fliplr(flipud(Z)), 1, []); % Andy's original code for modifying Z
                            patchIndices=[1,3,4,2];
                        case 3 % Triangles
                            % Generate grid corresponding to Z values:
                            [xg,yg]=meshgrid(sur.X,sur.Y);
                            % Find centres of triangles:
                            [xc,yc]=R.project.bathymetry.cellCentres;
                            % Find closest triangle to given grid point:
                            [~,k]=distanceBetweenPoints(xc,yc,xg,yg,'min');
                            % Map Z values to triangles:
                            Z=Z(k);
                            % And set indices for patch
                            patchIndices=[1,2,3];
                        otherwise
                            error('Unknown bathy size')
                    end
                    
                    for l = 1:noLevels
                        level = levels(l);
                        
                        idxs=Z>level;
                        patchHandle = patch(E(idxs,patchIndices)',N(idxs,patchIndices)', ...
                            'r', ...
                            'EdgeColor','none', ...
                            'FaceAlpha',0.25 ...
                            );
                        
                        if exist('patchHandle', 'var') & ~isempty(patchHandle)
                            legendContours(end+1) = patchHandle;
                            legendlabels{end+1}   = [ num2str(level), ' ', sur.defaultUnit];
                        end
                        
                    end
                end
                
                if ~isempty(legendContours)
                    if str2num(mv(1:4)) < 2017
                        leg = legend(legendContours,legendlabels,'color','w');
                    else
                        [~,leg] = legend(legendContours,legendlabels, 'AutoUpdate', 'off','color','w');
                    end
                    
                    PatchInLegend = findobj(leg, 'type', 'patch');
                    
                    for l = 1:size(PatchInLegend,1)
                        % start with alpha 0.25 and split the rest between 0.5-1.0
                        
                        val = 0.75 - (0.5-(0.5/noLevels) * (l - 1));
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
                xtickformat('%8.f');
                ytickformat('%8.f');
            end
            
            if plotCages
%                fprintf('Plotting cages\n')
                cages = R.cages.consolidatedCages.cages;
                
                figure(F);
                
                if (cageSize==0)
                    scatter3(...
                        cellfun(@(c) c.x, cages), ...
                        cellfun(@(c) c.y, cages), ...
                        repmat(11,length(cages),1),...
                        'wo', ...
                        'MarkerFaceColor', 'k', ...
                        'LineWidth', 1.0, ...
                        'Visible', 'on', ...
                        'Clipping', 'on' ...
                        );
                else
                    
                    if cages{1}.isCircle
                        
                        for c=1:length(cages)
                            rectangle( ...
                                'Position',[ ...
                                cages{c}.x-cages{c}.width/2 ...
                                cages{c}.y-cages{c}.length/2 ...
                                cages{c}.width ...
                                cages{c}.length],...
                                'Curvature',[1 1],...
                                'FaceColor', 'none', ...
                                'EdgeColor',[1 1 1], ...
                                'LineWidth',1 ...
                                );
                        end
                    else
                        
                        for c=1:length(cages)
                            theta = R.cages.majorAxis*pi/180;
                            
                            cornersOrthE = [...
                                cages{c}.x-cages{c}.width/2 ...
                                cages{c}.x+cages{c}.width/2 ...
                                cages{c}.x+cages{c}.width/2 ...
                                cages{c}.x-cages{c}.width/2 ...
                                ];
                            
                            cornersOrthN = [...
                                cages{c}.y-cages{c}.length/2 ...
                                cages{c}.y-cages{c}.length/2 ...
                                cages{c}.y+cages{c}.length/2 ...
                                cages{c}.y+cages{c}.length/2 ...
                                ];
                            
                            % remove distance from origin
                            cornersOrthE = cornersOrthE - cages{c}.x;
                            cornersOrthN = cornersOrthN - cages{c}.y;
                            
                            % rotate points
                            cornersRotE =  cornersOrthE.*cos(theta) + cornersOrthN.*sin(theta);
                            cornersRotN = -cornersOrthE.*sin(theta) + cornersOrthN.*cos(theta);
                            
                            % re-add distance from origin
                            cornersRotE = cornersRotE + cages{c}.x;
                            cornersRotN = cornersRotN + cages{c}.y;
                            
                            patch( ...
                                cornersRotE,...
                                cornersRotN,...
                                'w', 'FaceColor', 'none', ...
                                'EdgeColor',[1 1 1], ...
                                'LineWidth',1 ...
                                );
                        end
                    end
                end
                
                set(gca,'Xlim',[min(R.project.bathymetry.NodeX),max(R.project.bathymetry.NodeX)])
                set(gca,'Ylim',[min(R.project.bathymetry.NodeY),max(R.project.bathymetry.NodeY)])
                set(gca,'layer','top');
                
            end
            
            drawnow;
        end
        
    end
    
end

