classdef (Abstract) Base
    
    properties
        x@double;
        y@double;
        angle@double; % TS added this property 20191209
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
                cage = Depomod.Layout.Cage.Circle;
            elseif isequal(type, 'SQUARE') || isequal(type, 'RECTANGULAR')
                cage = Depomod.Layout.Cage.Square;
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
                cage = Depomod.Layout.Cage.Circle;
            elseif isequal(columns{4}, 'square')
                cage = Depomod.Layout.Cage.Square;
            end
            
            cage.x       = str2double(columns{1});
            cage.y       = str2double(columns{2});
            cage.angle   = str2double(columns{3}); % TS changed this 20191209
            cage.length  = str2double(columns{6});
            cage.width   = str2double(columns{5});
            cage.height  = str2double(columns{7});
            
            % ensure identical dimensions if circular.
            if cage.width ~= cage.length
                val = max([cage.width, cage.length]);
               
                cage.length  = val;
                cage.width   = val;
            end
        end
        
    end
    
    methods
        function s = shape(C)
            s = 'square';
            
            if isequal(class(C), 'Depomod.Layout.Cage.Circle')
                s = 'circle';
            end
        end
        
        function bool = isCircle(C)
            bool = isequal(C.shape, 'circle');
        end
        
        function bool = isSquare(C)
            bool = isequal(C.shape, 'square');
        end
        
        function bool = isRectangular(C)
            bool = isequal(C.shape, 'square');
        end                
       
    end
    
end

