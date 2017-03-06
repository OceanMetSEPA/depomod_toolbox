classdef Square < AutoDepomod.Layout.Cage.Base
    
    
    properties
    end
    
    methods
        function a = area(C)
            a = C.length * C.width;
        end
        
        function v = volume(C)
            v = C.area * C.height;
        end
        
        function p = perimeter(C)
            p = 2 * (C.length + C.width);
        end
    end
    
end

