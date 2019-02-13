classdef Curve < dynamicprops
    
    properties
        Parameters = []; % L, k, x_0
    end
    
    methods (Static = true)
        function y = solve(x, L, k, x_0)
            y = L./(1 + exp(-k*(x-x_0)));
        end
        
        function x = solveInverse(y, L, k, x_0)
            x = log(L/y - 1)/(-k) + x_0;
        end
    end
    
    methods
        
        function C = Curve(L, k, x_0)
            C.Parameters = [L, k, x_0];
        end
        
        function y = solution(C, x)
            y = Depomod.Stats.Logistic.Curve.solve(x, ...
                C.Parameters(1), ...
                C.Parameters(2), ...
                C.Parameters(3)...
            );
        end
        
        function x = inverseSolution(C, y)
            x = Depomod.Stats.Logistic.Curve.solveInverse(y, ...
                C.Parameters(1), ...
                C.Parameters(2), ...
                C.Parameters(3)...
            );
        end
        
        function plot(C, x, varargin)
            Colour = 'y';
            LineWidth = 1.0;
            
            for i = 1:2:length(varargin) % only bother with odd arguments, i.e. the labels
                switch varargin{i}
                    case 'Colour' % 
                        Colour = varargin{i+1};
                    case 'LineWidth' % 
                        LineWidth = varargin{i+1};
                end
            end
            
            y = C.solution(x);
            plot(x, y, [Colour, '-'], 'LineWidth', LineWidth);
        end
    end
    
end

