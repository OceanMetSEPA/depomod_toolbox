classdef Circle < AutoDepomod.Layout.Cage.Base
    
    
    properties
    end
    
    methods
        function a = area(C)
            a = pi * (C.width / 2)^2;
        end
        
        function v = volume(C)
            v = C.area * C.depth;
        end
        
        function p = perimeter(C)
            p = pi * C.width;
        end
    end
    
end

