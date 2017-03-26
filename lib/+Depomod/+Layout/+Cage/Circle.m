classdef Circle < Depomod.Layout.Cage.Base
    
    
    properties
    end
    
    methods
        function a = area(C)
            a = pi * (C.width / 2)^2;
        end
        
        function v = volume(C)
            v = C.area * C.height;
        end
        
        function p = perimeter(C)
            p = pi * C.width;
        end
    end
    
end

