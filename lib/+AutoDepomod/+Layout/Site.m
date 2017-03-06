classdef Site
    
    properties
        cageGroups = {};
    end
    
    methods (Static = true)
        
        function site = fromXMLFile(filepath)
            xmlDOM  = xmlread(filepath);
            siteDOM = xmlDOM.getDocumentElement;
            
            site = AutoDepomod.Layout.Site.fromXMLDOM(siteDOM);
        end
        
        function site = fromXMLDOM(siteDOM)
            site = AutoDepomod.Layout.Site;
            
            groupsDOM = siteDOM.getElementsByTagName('ns2:group');
            
            for i = 1:groupsDOM.getLength
                groupDOM = groupsDOM.item(i-1);
                group = AutoDepomod.Layout.Cage.Group.fromXMLDOM(groupDOM);
                
                site.cageGroups{i} = group;
            end            
        end
        
        function site = fromCSV(filepath)
            site = AutoDepomod.Layout.Site;
            group = AutoDepomod.Layout.Cage.Group;
            
            data = readTxtFile(filepath, 'startRow', 2);
            
            for i = 1:size(data,1)
                cage = AutoDepomod.Layout.Cage.Base.fromCSVRow(data{i});
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
            cc = AutoDepomod.Layout.Cage.Group;
            
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
    end
    
end

