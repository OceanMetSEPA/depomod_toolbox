classdef (Abstract) Base
    
    properties
        x@double;
        y@double;
        length@double
        width@double;
        height@double;
        depth@double;
        inputsId@char;
        proportion@double;
        inProduction@logical;
    end
    
    methods (Static = true)
        
        function cage = fromXMLDOM(cageDOM) 
            type = char(cageDOM.getElementsByTagName('cageType').item(0).getTextContent);
            
            if isequal(type, 'CIRCULAR')
                cage = AutoDepomod.Layout.Cage.Circle;
            elseif isequal(type, 'SQUARE') | isequal(type, 'RECTANGULAR')
                cage = AutoDepomod.Layout.Cage.Square;
            end
            
            cage.x            = str2double(cageDOM.getElementsByTagName('xCoordinate').item(0).getTextContent);
            cage.y            = str2double(cageDOM.getElementsByTagName('yCoordinate').item(0).getTextContent);
            cage.length       = str2double(cageDOM.getElementsByTagName('length').item(0).getTextContent);
            cage.width        = str2double(cageDOM.getElementsByTagName('width').item(0).getTextContent);
            cage.height       = str2double(cageDOM.getElementsByTagName('hieght').item(0).getTextContent);
            cage.depth        = str2double(cageDOM.getElementsByTagName('depth').item(0).getTextContent);
            cage.inputsId     = char(cageDOM.getElementsByTagName('inputsId').item(0).getTextContent);
            cage.proportion   = str2double(cageDOM.getElementsByTagName('proportion').item(0).getTextContent);            
            cage.inProduction = logical(eval(char(cageDOM.getElementsByTagName('inProduction').item(0).getTextContent)));
        end
        
        function cage = fromCSVRow(string)
            columns = strsplit(string, ','); 
            
            if isequal(columns{4}, 'circle')
                cage = AutoDepomod.Layout.Cage.Circle;
            elseif isequal(columns{4}, 'square')
                cage = AutoDepomod.Layout.Cage.Square;
            end
            
            cage.x       = str2double(columns{1});
            cage.y       = str2double(columns{2});
            cage.length  = str2double(columns{6});
            cage.width   = str2double(columns{5});
            cage.depth   = str2double(columns{7});
        end
        
    end
    
    methods
        
       
    end
    
end

