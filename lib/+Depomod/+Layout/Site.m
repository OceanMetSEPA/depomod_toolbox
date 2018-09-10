classdef Site
    
    properties
        cageGroups = {};
        path = '';
    end
    
    methods (Static = true)
        
        function site = fromXMLFile(filepath)
            xmlDOM  = xmlread(filepath);
            siteDOM = xmlDOM.getDocumentElement;
            
            site = Depomod.Layout.Site.fromXMLDOM(siteDOM);
            site.path = filepath;
        end
        
        function site = fromXMLDOM(siteDOM)
            site = Depomod.Layout.Site;
            
            groupsDOM = siteDOM.getElementsByTagName('ns2:group');
            
            for i = 1:groupsDOM.getLength
                groupDOM = groupsDOM.item(i-1);
                group = Depomod.Layout.Cage.Group.fromXMLDOM(groupDOM);
                
                site.cageGroups{i} = group;
            end            
        end
        
        function site = fromCSV(filepath)
            site = Depomod.Layout.Site;
            group = Depomod.Layout.Cage.Group;
            
            data = Depomod.FileUtils.readTxtFile(filepath, 'startRow', 2);
            
            for i = 1:size(data,1)
                cage = Depomod.Layout.Cage.Base.fromCSVRow(data{i});
                group.cages{i} = cage;
            end 
            
            site.cageGroups{1} = group;
        end
    end
    
    methods
        
        function g = group(S, number)
            g = S.cageGroups{number};
        end
        
        function s = size(S)
            s = length(S.cageGroups);
        end
        
        function sc = sizeCages(S)
            sc = 0;
            for g = 1:S.size
                sc = sc + S.group(g).size;
            end
        end
        
        function a = cageArea(S)
            a = 0;
            
            for i = 1:S.size
                group = S.group(i);
                a = a + group.cageArea;
            end            
        end
        
        function v = cageVolume(S)
            v = 0;
            
            for i = 1:S.size
                group = S.group(i);
                v = v + group.cageVolume;
            end            
        end
        
        function cc = consolidatedCages(S)
            cc = Depomod.Layout.Cage.Group;
            
            for g = 1:S.size
                for c = 1:S.group(g).size 
                    cc.cages{end+1} = S.group(g).cage(c);
                end
            end
        end
        
        function [meanE, meanN] = meanCagePosition(S)
            cumE = 0;
            cumN = 0;
            
            for i = 1:S.size
                [meanGroupE, meanGroupN] = S.group(i).meanCagePosition;
                
                cumE = cumE + meanGroupE;
                cumN = cumN + meanGroupN;
            end

            meanE = cumE/S.size;
            meanN = cumN/S.size;
        end
        
        function sizeInBytes = toFile(S, filePath)
            % this currently only tries to write 1 cage group
            
            if ~exist('filePath', 'var')
                filePath = S.path;
                warning('No file path given. Existing source file will be overwritten.')
            end
            
            % get an XML cage template
            templateCages = xmlread(NewDepomod.Project.templateProject.solidsRuns.item(1).cagesPath);

            DOM = templateCages.getDocumentElement;

            % retrieve existing cage groups
            groups = DOM.getElementsByTagName('ns2:group');

            % and delete them. Easier ro build from scratch
            for i = 1:groups.getLength
                DOM.removeChild(groups.item(0));
            end

            % create new cage group node
            group_node = templateCages.createElement('ns2:group');
            
            % add to XML doc
            templateCages.getDocumentElement.appendChild(group_node);
            
            % Create a random uuid for all cages
            indexes = [48:57, 97:102]; % ascii 0-9, a-f
            uuid = [...
                char(indexes(ceil(rand(1, 8)*length(indexes)))), ...
                '-',...
                char(indexes(ceil(rand(1, 4)*length(indexes)))), ...
                '-',...
                char(indexes(ceil(rand(1, 4)*length(indexes)))), ...
                '-',...
                char(indexes(ceil(rand(1, 4)*length(indexes)))), ...
                '-',...
                char(indexes(ceil(rand(1, 12)*length(indexes)))) ...
                ];

            % get group - this might provide group level attributes
            group = S.cageGroups{1}

            for c = 1:S.sizeCages

                cage = S.consolidatedCages.cages{c};

                cage_node = templateCages.createElement('cage');

                type_node       = templateCages.createElement('cageType');
                x_node          = templateCages.createElement('xCoordinate');
                y_node          = templateCages.createElement('yCoordinate');
                phi_node        = templateCages.createElement('phi');
                length_node     = templateCages.createElement('length');
                width_node      = templateCages.createElement('width');
                height_node     = templateCages.createElement('hieght');
                depth_node      = templateCages.createElement('depth');
                id_node         = templateCages.createElement('inputsId');
                proportion_node = templateCages.createElement('proportion');
                production_node = templateCages.createElement('inProduction');

                if isequal(class(cage), 'Depomod.Layout.Cage.Circle')
                    type_node.setTextContent('CIRCULAR');
                elseif isequal(class(cage), 'Depomod.Layout.Cage.Square')
                    type_node.setTextContent('RECTANGULAR');
                end

                x_node.setTextContent(num2str(cage.x));
                y_node.setTextContent(num2str(cage.y));
                phi_node.setTextContent(num2str(pi/2.0));

                if isequal(class(cage), 'Depomod.Layout.Cage.Circle')
                    length_node.setTextContent(num2str(cage.width));
                elseif isequal(class(cage), 'Depomod.Layout.Cage.Square')
                    length_node.setTextContent(num2str(cage.length));
                end

                width_node.setTextContent(num2str(cage.width));
                height_node.setTextContent(num2str(cage.height));
                depth_node.setTextContent(num2str(cage.height/2.0));

                if isempty(cage.inputsId)
                    id_node.setTextContent(uuid);
                else
                    id_node.setTextContent(cage.inputsId);
                end

                if isempty(cage.proportion)
                    proportion_node.setTextContent(num2str(1/S.sizeCages));
                else
                    proportion_node.setTextContent(num2str(cage.proportion));
                end

                if isempty(cage.inProduction)
                    production_node.setTextContent('true');
                else
                    if cage.inProduction
                        production_node.setTextContent('true');
                    else
                        production_node.setTextContent('false');
                    end
                end

                cage_node.appendChild(type_node);
                cage_node.appendChild(x_node);
                cage_node.appendChild(y_node);
                cage_node.appendChild(phi_node);
                cage_node.appendChild(length_node);
                cage_node.appendChild(width_node);
                cage_node.appendChild(height_node);
                cage_node.appendChild(depth_node);
                cage_node.appendChild(id_node);
                cage_node.appendChild(proportion_node);
                cage_node.appendChild(production_node);

                group_node.appendChild(cage_node)  ;  

            end

            layout_type_node    = templateCages.createElement('ns2:layoutType');
            name_node           = templateCages.createElement('ns2:name');
            origin_x_node       = templateCages.createElement('ns2:regularGridXOrigin');
            origin_y_node       = templateCages.createElement('ns2:regularGridYOrigin');
            spacing_x_node      = templateCages.createElement('ns2:regularGridXSpacing');
            spacing_y_node      = templateCages.createElement('ns2:regularGridYSpacing');
            grid_nx_node        = templateCages.createElement('ns2:regularGridNX');
            grid_ny_node        = templateCages.createElement('ns2:regularGridNY');
            grid_length_node    = templateCages.createElement('ns2:regularGridLength');
            grid_width_node     = templateCages.createElement('ns2:regularGridWidth');
            grid_height_node    = templateCages.createElement('ns2:regularGridHieght');
            grid_depth_node     = templateCages.createElement('ns2:regularGridDepth');
            grid_bearing_node   = templateCages.createElement('ns2:regularGridBearing');
            grid_cage_type_node = templateCages.createElement('ns2:regularGridCageType');

            if isempty(group.layoutType)
                layout_type_node.setTextContent(group.layoutType);
            else 
                layout_type_node.setTextContent('REGULARGRID');
            end

            name_node.setTextContent(group.name);
            origin_x_node.setTextContent(num2str(S.consolidatedCages.cages{c}.x));
            origin_y_node.setTextContent(num2str(S.consolidatedCages.cages{c}.y));
            spacing_x_node.setTextContent(num2str(group.xSpacing));
            spacing_y_node.setTextContent(num2str(group.ySpacing));
            grid_nx_node.setTextContent(num2str(group.Nx));
            grid_ny_node.setTextContent(num2str(group.Ny));
            
            if isequal(class(cage), 'Depomod.Layout.Cage.Circle')
                grid_length_node.setTextContent(num2str(S.consolidatedCages.cages{c}.width));
            elseif isequal(class(cage), 'Depomod.Layout.Cage.Square')
                grid_length_node.setTextContent(num2str(S.consolidatedCages.cages{c}.length));
            end            
            
            grid_width_node.setTextContent(num2str(S.consolidatedCages.cages{c}.width));
            grid_height_node.setTextContent(num2str(S.consolidatedCages.cages{c}.height));
            grid_depth_node.setTextContent(num2str(S.consolidatedCages.cages{c}.height/2.0));
            grid_bearing_node.setTextContent(num2str(group.bearing));
            
            if isequal(class(S.consolidatedCages.cages{c}), 'Depomod.Layout.Cage.Circle')
                grid_cage_type_node.setTextContent('CIRCULAR');
            elseif isequal(class(S.consolidatedCages.cages{c}), 'Depomod.Layout.Cage.Square')
                grid_cage_type_node.setTextContent('SQUARE');
            end

            group_node.appendChild(layout_type_node);
            group_node.appendChild(name_node);
            group_node.appendChild(origin_x_node);
            group_node.appendChild(origin_y_node);
            group_node.appendChild(spacing_x_node);
            group_node.appendChild(spacing_y_node);
            group_node.appendChild(grid_nx_node);
            group_node.appendChild(grid_ny_node);
            group_node.appendChild(grid_length_node);
            group_node.appendChild(grid_width_node);
            group_node.appendChild(grid_height_node);
            group_node.appendChild(grid_depth_node);
            group_node.appendChild(grid_bearing_node);
            group_node.appendChild(grid_cage_type_node);
            
%             xmlwrite(filePath, templateCages);   
            
            % use this method to remove annoying whitespace characters
            % added by MATLAB (https://uk.mathworks.com/matlabcentral/newsreader/view_thread/245555)
            docStr = xmlwrite(templateCages);
            docStr = regexprep(docStr,'\n\s*\n','\n');
            openDoc = fopen(filePath,'w');
            fprintf(openDoc,'%s\n',docStr);
            fclose(openDoc);            
        end
    end
    
end

