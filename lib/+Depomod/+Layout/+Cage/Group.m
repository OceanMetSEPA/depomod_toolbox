classdef Group
    
    properties
        cages = {};
        
        layoutType@char;
        name@char;
        x@double;
        y@double;
        xSpacing@double;
        ySpacing@double;
        Nx@double;
        Ny@double;
        length@double
        width@double;
        height@double;
        depth@double;
        bearing@double;
        cageType@char;
    end
    
    methods (Static = true)
       
        function group = fromXMLDOM(groupDOM)
            group = Depomod.Layout.Cage.Group;

            group.layoutType = char(groupDOM.getElementsByTagName('ns2:layoutType').item(0).getTextContent);
            group.name       = char(groupDOM.getElementsByTagName('ns2:name').item(0).getTextContent);
            group.x          = str2double(groupDOM.getElementsByTagName('ns2:regularGridXOrigin').item(0).getTextContent);
            group.y          = str2double(groupDOM.getElementsByTagName('ns2:regularGridYOrigin').item(0).getTextContent);
            group.xSpacing   = str2double(groupDOM.getElementsByTagName('ns2:regularGridXSpacing').item(0).getTextContent);
            group.ySpacing   = str2double(groupDOM.getElementsByTagName('ns2:regularGridYSpacing').item(0).getTextContent);
            group.Nx         = str2double(groupDOM.getElementsByTagName('ns2:regularGridNX').item(0).getTextContent);
            group.Ny         = str2double(groupDOM.getElementsByTagName('ns2:regularGridNY').item(0).getTextContent);
            group.length     = str2double(groupDOM.getElementsByTagName('ns2:regularGridLength').item(0).getTextContent);
            group.width      = str2double(groupDOM.getElementsByTagName('ns2:regularGridWidth').item(0).getTextContent);
            group.height     = str2double(groupDOM.getElementsByTagName('ns2:regularGridHieght').item(0).getTextContent);
            group.depth      = str2double(groupDOM.getElementsByTagName('ns2:regularGridDepth').item(0).getTextContent);
            group.bearing    = str2double(groupDOM.getElementsByTagName('ns2:regularGridBearing').item(0).getTextContent);
            group.cageType   = char(groupDOM.getElementsByTagName('ns2:regularGridCageType').item(0).getTextContent);

            cagesDOM = groupDOM.getElementsByTagName('cage');

            for j = 1:cagesDOM.getLength
                cageDOM = cagesDOM.item(j-1);
                cage = Depomod.Layout.Cage.Base.fromXMLDOM(cageDOM);
                
                group.cages{j} = cage;
            end
        end
        
    end
    
    methods
        
        function c = cage(G, number)
            c = G.cages{number};
        end
        
        function a = cageArea(G)
            a = 0;
            
            for i = 1:G.size
                cage = G.cage(i);
                a = a + cage.area;
            end            
        end
        
        function v = cageVolume(G)
            v = 0;
            
            for i = 1:G.size
                cage = G.cage(i);
                v = v + cage.volume;
            end            
        end
        
        function s = size(G)
            s = numel(G.cages);
        end         
        
        function [meanE, meanN] = meanCagePosition(G)
            cumE = 0;
            cumN = 0;
            
            for i = 1:G.size
                cage = G.cage(i);
                
                cumE = cumE + cage.x;
                cumN = cumN + cage.y;
            end

            meanE = cumE/G.size;
            meanN = cumN/G.size;
        end
        
        function m = spacingMatrix(S)
            % cage wise relative distances
            
            c = S.cages;
            
            m = zeros(numel(c), numel(c));
            
            for i = 1:numel(c)
                cagei = c{i};
                for j = 1:numel(c)
                    cagej = c{j};
                    m(i,j) = sqrt((cagei.x-cagej.x)^2 + (cagei.y-cagej.y)^2);
                end
            end
        end
        
        function s = spacing(G)
            % returns notional spacing of cages.
            % Assumes that cages are symetrically spaced and identifies
            % mean distance of each cage to nearest neighbouring cage
            
            m = G.spacingMatrix ;
            m = sort(m,2);
           
            s = mean(m(:,2));           
        end
        
    end
    
end

